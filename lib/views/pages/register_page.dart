import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '이메일',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onEditingComplete: () {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onEditingComplete: () {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20.0),
                    FilledButton(
                      onPressed: () {
                        onRegisterPressed();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 40.0),
                      ),
                      child: Text('가입하기'),
                    ),
                    SizedBox(height: 50.0),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void onRegisterPressed() {
  }
}
