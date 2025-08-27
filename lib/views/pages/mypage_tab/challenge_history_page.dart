import 'package:flutter/material.dart';

class ChallengeHistoryPage extends StatelessWidget {
  const ChallengeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('챌린지 내역 확인')),
      body: const Center(
        child: Text(
          '참여한 챌린지 내역을 확인할 수 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
