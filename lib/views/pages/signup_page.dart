import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../theme/app_colors.dart';
import '../../utils/signup_auth_store.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

// 1+3단계 -> 2단계 -> 4단계
enum SignupStep { account, code, username }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final usernameController = TextEditingController();

  SignupStep step = SignupStep.account;
  bool isLoading = false;
  bool emailLocked = false;
  bool passwordLocked = false;
  bool showPassword = false;
  bool showPasswordConfirm = false;

  static const int kCodeSeconds = 600;
  Timer? _timer;
  int remained = kCodeSeconds;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    codeController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    usernameController.addListener(() => setState(() {}));
  }

  String get stepCaption => switch (step) {
        SignupStep.account => '계정을 만들 이메일과\n비밀번호를 입력해주세요.',
        SignupStep.code => '해당 이메일로 전송된\n인증번호를 입력해주세요.',
        SignupStep.username => '사용하실 닉네임을 입력하면\n여정을 함께할 준비가 끝나요!'
      };

  // ========= API 연동 =========

  String withBearer(String token) =>
      token.startsWith('Bearer ') ? token : 'Bearer $token';

  Future<void> sendEmailCode(String email, String password) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final HttpClient native = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host == '54.180.150.39.nip.io';
    final http.Client client = IOClient(native);

    try {
      // 1) step1
      final res1 = await client.post(
        Uri.parse('$baseUrl/api/user/signup/step1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userEmail': email, 'userPassword': password}),
      );

      if (res1.statusCode < 200 || res1.statusCode >= 300) {
        _snack('전송 실패: ${res1.statusCode} ${res1.body}');
        return;
      }

      final auth = res1.headers['authorization'];
      if (auth == null || auth.isEmpty) {
        _snack('Authorization 헤더가 없습니다');
        return;
      }
      final token = withBearer(auth);
      await SignupAuthStore.save(token);

      // 2) send-code
      final res2 = await client.post(
        Uri.parse('$baseUrl/api/email/signup/send-code'),
        headers: {'accept': '*/*', 'Authorization': token},
        body: '',
      );

      if (res2.statusCode < 200 || res2.statusCode >= 300) {
        _snack('코드 발송 실패: ${res2.statusCode} ${res2.body}');
        return;
      }

      // 성공
      _startTimer();
      setState(() {
        emailLocked = true;
        passwordLocked = true;
        step = SignupStep.code;
      });
      _snack('인증번호를 전송했어요');
    } catch (e) {
      _snack('에러: $e');
    } finally {
      client.close();
      setState(() => isLoading = false);
    }
  }

  Future<bool> verifyEmailCode(String code) async {
    setState(() => isLoading = true);

    final HttpClient native = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host == '54.180.150.39.nip.io';
    final http.Client client = IOClient(native);

    try {
      final saved = await SignupAuthStore.get();
      if (saved == null) {
        _snack('토큰 없음, 처음부터 다시 시도');
        return false;
      }
      final res = await client.post(
        Uri.parse('$baseUrl/api/email/signup/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': withBearer(saved),
        },
        body: jsonEncode({'code': code}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      } else {
        _snack('인증 실패: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      _snack('에러: $e');
      return false;
    } finally {
      client.close();
      setState(() => isLoading = false);
    }
  }

  Future<void> completeSignup({
    required String email,
    required String password,
    required String username,
  }) async {
    setState(() => isLoading = true);

    final HttpClient native = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host == '54.180.150.39.nip.io';
    final http.Client client = IOClient(native);

    try {
      final saved = await SignupAuthStore.get();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (saved != null) 'Authorization': withBearer(saved),
      };

      final res = await client.post(
        Uri.parse('$baseUrl/api/user/signup'),
        headers: headers,
        body: jsonEncode({
          'userName': username,
          'userEmail': email,
          'userPassword': password,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _snack('가입 성공!');
        await SignupAuthStore.clear();
        if (mounted) Navigator.pop(context);
      } else {
        _snack('가입 실패: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      _snack('에러: $e');
    } finally {
      client.close();
      setState(() => isLoading = false);
    }
  }

  // ========= 타이머/유틸 =========

  void _startTimer() {
    _timer?.cancel();
    setState(() => remained = kCodeSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remained <= 1) {
        t.cancel();
        setState(() => remained = 0);
      } else {
        setState(() => remained--);
      }
    });
  }

  String get mmss {
    final m = (remained ~/ 60).toString().padLeft(2, '0');
    final s = (remained % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool get _passwordsMatch =>
      passwordController.text.isNotEmpty &&
      passwordController.text == passwordConfirmController.text;

  bool get canRequestCode =>
      step == SignupStep.account &&
      !emailLocked &&
      !passwordLocked &&
      emailController.text.trim().isNotEmpty &&
      _passwordsMatch &&
      !isLoading;

  bool get canVerifyCode =>
      step == SignupStep.code &&
      codeController.text.trim().isNotEmpty &&
      remained > 0 &&
      !isLoading;

  bool get canFinish =>
      step == SignupStep.username &&
      usernameController.text.trim().isNotEmpty &&
      !isLoading;

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  // ========= UI =========

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PositionedFillGradient(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(48, 24, 48, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  Text(stepCaption,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 40),

                  if (step == SignupStep.account) ...[
                    TextField(
                      controller: emailController,
                      readOnly: emailLocked,
                      decoration: inputDeco("이메일").copyWith(
                        suffixIcon: emailLocked
                            ? const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.check, color: Colors.black),
                              )
                            : null,
                        fillColor: emailLocked
                            ? AppColors.lightBlue
                            : AppColors.lighterGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      readOnly: passwordLocked,
                      obscureText: !showPassword,
                      decoration: inputDeco("비밀번호").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),
                        fillColor:
                            passwordLocked ? AppColors.lightBlue : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordConfirmController,
                      readOnly: passwordLocked,
                      obscureText: !showPasswordConfirm,
                      decoration: inputDeco("비밀번호 확인").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPasswordConfirm
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                              showPasswordConfirm = !showPasswordConfirm),
                        ),
                        fillColor:
                            passwordLocked ? AppColors.lightBlue : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LongButtonWidget(
                      text: '인증하기',
                      onPressed: canRequestCode
                          ? () => sendEmailCode(
                                emailController.text.trim(),
                                passwordController.text,
                              )
                          : null,
                      backgroundColor: AppColors.primaryBlue,
                      isEnabled: !isLoading,
                    ),
                  ],

                  if (step == SignupStep.code) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codeController,
                            decoration: inputDeco("인증번호 입력...").copyWith(
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Center(
                                  widthFactor: 1.0,
                                  child: Text(mmss,
                                      style: TextStyle(
                                          color: remained > 0
                                              ? Colors.black
                                              : Colors.red.shade700,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: canVerifyCode
                                ? () async {
                                    final ok = await verifyEmailCode(
                                        codeController.text.trim());
                                    if (ok) {
                                      _timer?.cancel();
                                      setState(() => step = SignupStep.username);
                                      _snack('이메일 인증 완료');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('인증',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: remained == 0 && !isLoading
                              ? () => sendEmailCode(
                                  emailController.text.trim(),
                                  passwordController.text)
                              : null,
                          child: const Text('재전송'),
                        )
                      ],
                    ),
                  ],

                  if (step == SignupStep.username) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: inputDeco("닉네임"),
                    ),
                    const SizedBox(height: 20),
                    LongButtonWidget(
                      text: '회원가입 완료',
                      onPressed: canFinish
                          ? () => completeSignup(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                username: usernameController.text.trim(),
                              )
                          : null,
                      backgroundColor: AppColors.primaryBlue,
                      isEnabled: !isLoading,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: AppColors.Gray, fontSize: 17, fontWeight: FontWeight.w400),
      filled: true,
      fillColor: AppColors.lighterGreen,
      border: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide:
            const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }
}

// ===== 별도 위젯들 =====

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: FittedBox(
        child: Image.asset('assets/images/BETU_mainlogo.png',
            fit: BoxFit.contain),
      ),
    );
  }
}

class PositionedFillGradient extends StatelessWidget {
  const PositionedFillGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.yellowGreen, AppColors.primaryGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.6, 1.0],
          ),
        ),
      ),
    );
  }
}
