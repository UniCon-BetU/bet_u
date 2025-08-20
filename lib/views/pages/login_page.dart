// lib/views/pages/login_page.dart
import 'package:bet_u/views/widget_tree.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

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
        String message = '로그인 성공!';
        try {
          final json = jsonDecode(res.body);
          if (json is Map && json['message'] is String) {
            message = json['message'];
          }
        } catch (_) {
          if (res.body.isNotEmpty) message = res.body;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

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
      hintStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.grey.shade200,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: userNameController,
              decoration: customInputDecoration('아이디'),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: customInputDecoration('비밀번호'),
              style: const TextStyle(color: Colors.black),
              onSubmitted: (_) => login(),
            ),
            const SizedBox(height: 30),
            LongButtonWidget(text: '로그인', onPressed: login),
          ],
        ),
      ),
    );
  }
}
