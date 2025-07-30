import 'package:flutter/material.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 100),
              SizedBox(height: 20),
              Text('페이지 예시입니다.'),
            ],
          ),
        ),
      ),
    );
  }
}
