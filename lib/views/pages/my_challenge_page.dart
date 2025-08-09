import 'package:flutter/material.dart';

class MyChallengePage extends StatelessWidget {
  const MyChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Challenge Page')),
      body: Center(child: Text('진행 중인 챌린지 페이지입니다.')),
    );
  }
}
