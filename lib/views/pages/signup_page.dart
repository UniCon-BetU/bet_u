import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../theme/app_colors.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

enum SignupStep { email, code, password, username }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // controllers
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 입력 변화 시 버튼/상태 즉시 갱신
    emailController.addListener(() => setState(() {}));
    codeController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    usernameController.addListener(() => setState(() {}));
  }

  String get stepCaption => switch (step) {
    SignupStep.email => '계정을 만들 때 사용할\n이메일을 입력해주세요.',
    SignupStep.code => '해당 이메일로 전송된\n인증번호를 입력해주세요.',
    SignupStep.password => '비밀번호를 설정하고\n다시 입력해주세요.',
    SignupStep.username => '사용하실 닉네임을 입력하면\n여정을 함께할 준비가 끝나요!'
  };

  // state
  SignupStep step = SignupStep.email;
  bool isLoading = false;

  // locks
  bool emailLocked = false;
  bool passwordLocked = false;

  // UI flags
  bool showPassword = false;
  bool showPasswordConfirm = false;

  // timer (5분 = 300초)
  static const int kCodeSeconds = 300;
  Timer? _timer;
  int remained = kCodeSeconds;

  // ====== 공통 입력 스타일 ======
  InputDecoration inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.Gray,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.lighterGreen,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }

  // ====== 백엔드 연계 자리 (TODO) ======

  Future<void> sendEmailCode(String email) async {
    setState(() => isLoading = true);
    try {
      // TODO: 실제 전송 API 붙이기
      // final client = _devClient();
      // final res = await client.post(Uri.parse('$baseUrl/api/auth/send-code'), body: jsonEncode({'email': email}), headers: {'Content-Type':'application/json'});
      await Future.delayed(const Duration(milliseconds: 600));
      // if (res.statusCode != 200) throw Exception(res.body);
      _startTimer();
      setState(() {
        step = SignupStep.code;
      });
      _snack('인증번호를 전송했어요');
    } catch (e) {
      _snack('전송 실패: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> verifyEmailCode(String email, String code) async {
    setState(() => isLoading = true);
    try {
      // TODO: 실제 인증 API 붙이기
      // final client = _devClient();
      // final res = await client.post(Uri.parse('$baseUrl/api/auth/verify-code'), ...);
      await Future.delayed(const Duration(milliseconds: 500));
      return true; // ← 실제에선 서버 응답으로 대체
    } catch (e) {
      _snack('인증 실패: $e');
      return false;
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> completeSignup({
    required String email,
    required String password,
    required String username,
  }) async {
    setState(() => isLoading = true);
    // dev 환경 인증서 우회 (필요 없으면 제거)
    final HttpClient native = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host == '54.180.150.39.nip.io';
    final http.Client client = IOClient(native);

    try {
      final uri = Uri.parse('$baseUrl/api/user/signup');
      final res = await client
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'userName': username,
                'userEmail': email,
                'userPassword': password,
              }))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        _snack('가입 성공!');
        Navigator.pop(context);
      } else {
        _snack('가입 실패: ${res.body}');
      }
    } on SocketException {
      _snack('네트워크 오류: 연결을 확인해주세요');
    } finally {
      client.close();
      setState(() => isLoading = false);
    }
  }

  http.Client _devClient() {
    final HttpClient native = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              host == '54.180.150.39.nip.io';
    return IOClient(native);
  }

  // ====== 타이머 ======
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

  // ====== helpers ======
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool get canSendCode {
    final email = emailController.text.trim();
    return email.isNotEmpty && !emailLocked;
  }

  bool get canVerifyCode {
    return codeController.text.trim().isNotEmpty && remained > 0;
  }

  bool get canGoNextFromPassword {
    final p1 = passwordController.text;
    final p2 = passwordConfirmController.text;
    return p1.isNotEmpty && p1 == p2;
  }

  bool get canFinish {
    return usernameController.text.trim().isNotEmpty;
  }

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

  // ====== UI ======
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(48, 24, 48, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 176,
                    height: 176,
                    child: FittedBox(
                      child: Image.asset('assets/images/BETU_mainlogo.png', fit: BoxFit.contain),
                    ),
                  ),
                  
                  Text(
                    stepCaption,
                    textAlign: TextAlign.center,
                    style: TextStyle (
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    )
                  ),

                  const SizedBox(height: 40),

                  // ===== 1) 이메일 입력 =====
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
                      fillColor: emailLocked ? AppColors.lightBlue : AppColors.lighterGreen
                    ),
                    style: const TextStyle(
                      color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  if (passwordLocked) ...[
                    TextField(
                      controller: passwordController,
                      readOnly: true,
                      obscureText: !showPassword,
                      decoration: inputDeco("비밀번호").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                        fillColor: AppColors.lightBlue
                      ),
                      style: const TextStyle(
                        color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],

                  if (step == SignupStep.email) ...[
                    LongButtonWidget(
                      text: '인증번호 보내기',
                      onPressed: canSendCode ? () => sendEmailCode(emailController.text.trim()) : null,
                      backgroundColor: AppColors.primaryBlue,
                      isEnabled: !isLoading,
                    ),
                  ],

                  // ===== 2) 인증번호 입력 + 타이머 =====
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
                                  child: Text(
                                    mmss,
                                    style: TextStyle(
                                      color: remained > 0 ? Colors.black : Colors.red.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: canVerifyCode && !isLoading
                                ? () async {
                                    final ok = await verifyEmailCode(
                                      emailController.text.trim(),
                                      codeController.text.trim(),
                                    );
                                    if (ok) {
                                      _timer?.cancel();
                                      setState(() {
                                        emailLocked = true;
                                        step = SignupStep.password;
                                      });
                                      _snack('이메일 인증 완료');
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('인증', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
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
                              ? () => sendEmailCode(emailController.text.trim())
                              : null,
                          child: const Text('재전송'),
                        )
                      ],
                    ),
                  ],

                  // ===== 3) 비밀번호/확인 + 다음 =====
                  if (step == SignupStep.password) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: passwordController,
                      readOnly: passwordLocked,
                      obscureText: !showPassword,
                      decoration: inputDeco("비밀번호").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordConfirmController,
                      readOnly: passwordLocked,
                      obscureText: !showPasswordConfirm,
                      decoration: inputDeco("비밀번호 확인").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(showPasswordConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => showPasswordConfirm = !showPasswordConfirm),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
                        
                    ),
                    const SizedBox(height: 24),
                    LongButtonWidget(
                      text: '다음',
                      textColor: Colors.black,
                      onPressed: (!passwordLocked && canGoNextFromPassword && !isLoading)
                          ? () {
                              setState(() {
                                passwordLocked = true;
                                step = SignupStep.username;
                              });
                            }
                          : null,
                      backgroundColor: Colors.white,
                      isEnabled: !isLoading,
                    ),
                  ],

                  // ===== 4) 닉네임 + 가입 완료 =====
                  if (step == SignupStep.username) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: inputDeco("닉네임"),
                      style: const TextStyle(
                        color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    LongButtonWidget(
                      text: '회원가입 완료',
                      onPressed: canFinish && !isLoading
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
}
