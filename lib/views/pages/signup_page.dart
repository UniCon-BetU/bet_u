import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import '../../theme/app_colors.dart';

const String baseUrl = 'https://54.180.150.39.nip.io'; // ← 그대로 사용

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signup() async {
    setState(() => isLoading = true);

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // --- (옵션) 개발환경에서 인증서 이슈 우회 ---
    // nip.io 도메인이 발급 인증서와 불일치/셀프사인일 때 사용
    // 배포용에서는 반드시 제거하거나 정상 인증서로 교체하세요!
    final HttpClient native = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == '54.180.150.39.nip.io'; // 이 호스트만 허용 (DEV ONLY)
      };
    final http.Client client = IOClient(native);
    // -------------------------------------------

    try {
      final uri = Uri.parse('$baseUrl/api/user/signup');
      final res = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userName': username,
              'userEmail': email,
              'userPassword': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      // 성공 코드가 200/201 중 무엇인지 확정이 안되어 둘 다 처리
      if (res.statusCode == 200 || res.statusCode == 201) {
        // 헤더 전체 출력
        print('--- SIGNUP RESPONSE HEADERS ------------------');
        res.headers.forEach((key, value) {
          print('$key: $value');
        });
        print('----------------------------------------------');

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('가입 성공! ${res.body}')));
        // TODO: 토큰/유저정보를 받는다면 저장 후 다음 화면으로 이동
        // Navigator.of(context).pushReplacement(...);
      } else {
        // 서버에서 에러 메시지를 JSON으로 내려주면 표시
        final err = res.body.isNotEmpty ? res.body : 'status ${res.statusCode}';
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('가입 실패: $err')));
      }
    } on SocketException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('네트워크 오류: 연결을 확인해주세요')));
    } finally {
      setState(() => isLoading = false);
      client.close();
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
          borderRadius: BorderRadius.circular(11), // 둥근 모서리
          borderSide: BorderSide.none, // 테두리 없음
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ), // 포커스 시 초록 테두리
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 선택: AppBar 뒤까지 배경 보이게 하고 싶다면 주석 해제
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, 
          color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      resizeToAvoidBottomInset: false, // ← 배경 고정

      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.yellowGreen, AppColors.primaryGreen],
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
                  padding: EdgeInsets.fromLTRB(48, 24, 48, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 176,
                          height: 176,
                          child: FittedBox(
                            child: Image.asset(
                              'assets/images/BETU_mainlogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: emailController,
                          decoration: customInputDecoration("이메일"),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: customInputDecoration("비밀번호"),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: usernameController,
                          decoration: customInputDecoration("사용자 이름"),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        LongButtonWidget(text: '가입하기', onPressed: signup, backgroundColor: AppColors.primaryBlue),
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
