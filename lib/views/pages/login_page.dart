// lib/views/pages/login_page.dart
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widget_tree.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import '../../theme/app_colors.dart';

// (SignupPage와 동일)
const String baseUrl = 'https://54.180.150.39.nip.io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final userName = userNameController.text.trim();
    final userPassword = passwordController.text.trim();

    if (userName.isEmpty || userPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요')));
      return;
    }

    // --- 개발환경 인증서 이슈 우회 (배포시 제거하세요) ---
    final HttpClient native = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == '54.180.150.39.nip.io'; // DEV ONLY
      };
    final http.Client client = IOClient(native);

    try {
      final uri = Uri.parse('$baseUrl/api/user/login');
      final res = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': userName, 'userPassword': userPassword}),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = res.headers['authorization'];

        if (token != null) {
          await TokenStorage.saveToken(token);
          print('>>> 저장된 accessToken: $token');
        }

        if (!mounted) return;
        // 이동
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WidgetTree()),
          (route) => false,
        );
      } else {
        final errText = res.body.isNotEmpty
            ? res.body
            : 'status ${res.statusCode}';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $errText')));
      }
    } on SocketException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('네트워크 오류: 연결을 확인해주세요')));
    } finally {
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 로고
                        Image.asset(
                          'assets/images/betu_happy.png',
                          width: 96, height: 96, fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        const Text('기다리고 있었어요,',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                        const Text('돌아오신 걸 환영해요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 32),

                        // 아이디/비번
                        TextField(
                          controller: userNameController,
                          decoration: customInputDecoration('아이디'),
                          style: const TextStyle(                            
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          decoration: customInputDecoration('비밀번호'),
                          style: const TextStyle(                            
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,),
                          obscureText: true,
                          onSubmitted: (_) => login(),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                        ),

                        const SizedBox(height: 30),
                        LongButtonWidget(
                          text: '로그인',
                          onPressed: login,
                          backgroundColor: AppColors.primaryGreen,
                        ),
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
