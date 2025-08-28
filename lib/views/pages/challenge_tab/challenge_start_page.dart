import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_detail_page.dart';
import '../../../models/challenge.dart';
import '../../widgets/long_button_widget.dart'; // LongButtonWidget 임포트

class ChallengeStartPage extends StatelessWidget {
  final int deductedPoints; // 차감된 포인트
  final String challengeTitle; // 챌린지 제목

  const ChallengeStartPage({
    super.key,
    required this.deductedPoints,
    required this.challengeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$challengeTitle 도전!'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // iOS 스타일
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/normal_lettuce.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$deductedPoints 포인트가 차감되었습니다!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '$challengeTitle\n도전을 시작합니다!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Spacer(),

            // LongButtonWidget으로 변경
            LongButtonWidget(
              text: '도전 시작',
              backgroundColor: Colors.green[600]!,
              height: 56,
              radius: 8,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeDetailPage(
                      challenge: Challenge(
                        title: challengeTitle,
                        participants: 0,
                        day: 1,
                        status: ChallengeStatus.inProgress,
                        category: '공부',
                        createdAt: DateTime.now(),
                        type: null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
