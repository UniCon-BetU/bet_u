import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, X509Certificate, SocketException;
import 'package:bet_u/views/pages/challenge_list_page.dart';
import 'package:bet_u/views/pages/home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widget_tree.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import '../../theme/app_colors.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;

  String? _stripBearer(String? auth) {
    if (auth == null) return null;
    const prefix = 'Bearer ';
    return auth.startsWith(prefix) ? auth.substring(prefix.length) : auth;
  }

  Future<http.Client> _createHttpClient() async {
    if (kIsWeb) {
      return http.Client();
    } else {
      final HttpClient native = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              debugPrint('Bad certificate callback for $host:$port');
              return host == '54.180.150.39.nip.io';
            };
      return IOClient(native);
    }
  }

  Future<void> login() async {
    final userEmail = userEmailController.text.trim();
    final userPassword = passwordController.text.trim();

    if (userEmail.isEmpty || userPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')));
      return;
    }

    setState(() => isLoading = true);
    debugPrint('로그인 시도: $userEmail');

    final client = await _createHttpClient();

    try {
      final uri = Uri.parse('$baseUrl/api/user/login');
      final res = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userEmail': userEmail,
              'userPassword': userPassword,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('타임아웃 발생');
              throw TimeoutException('서버 요청 시간 초과');
            },
          );

      debugPrint('응답 상태 코드: ${res.statusCode}');
      debugPrint('응답 바디: ${res.body}');

      if (!mounted) return;

      if (res.statusCode == 200) {
        var token = _stripBearer(res.headers['authorization']);
        if (token == null && res.body.isNotEmpty) {
          try {
            final json = jsonDecode(res.body);
            token = json['accessToken'] as String?;
          } catch (e) {
            debugPrint('토큰 파싱 실패: $e');
          }
        }

        if (token != null) {
          await TokenStorage.saveToken(token);
          debugPrint('토큰 저장 완료');
        }

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()), //원래는 위젯트리
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: status ${res.statusCode}')),
        );
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('네트워크 오류: 연결을 확인해주세요')));
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 요청 시간 초과')));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알 수 없는 오류 발생')));
    } finally {
      client.close();
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration customInputDecoration(String hint) {
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
      contentPadding: const EdgeInsets.all(12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(11)),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lightGreen, AppColors.yellowGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(48, 48, 48, 48 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/betu_happy.png',
                          width: 96,
                          height: 96,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '기다리고 있었어요,',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Text(
                          '돌아오신 걸 환영해요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: userEmailController,
                          decoration: customInputDecoration('이메일'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          decoration: customInputDecoration('비밀번호').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => setState(
                                      () => showPassword = !showPassword,
                                    ),
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          obscureText: !showPassword,
                          onSubmitted: (_) => isLoading ? null : login(),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 30),
                        LongButtonWidget(
                          text: isLoading ? '로그인 중...' : '로그인',
                          onPressed: isLoading ? null : login,
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        if (isLoading) ...[
                          const SizedBox(height: 12),
                          const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
