import 'package:bet_u/views/pages/processing_challenge_detail_page.dart';
import 'package:flutter/material.dart';
import 'challenge.dart';

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
      appBar: AppBar(title: Text('$challengeTitle 도전!'), leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/normal_lettuce.png', // 기존 이미지 재사용
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$deductedPoints 포인트가 차감되었습니다!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '$challengeTitle 도전을 시작합니다!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Processing 페이지로 이동, day 1부터 시작
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProcessingChallengeDetailPage(
                        challenge: Challenge(
                          title: challengeTitle, // 생성자에서 받은 제목
                          participants: 0, // 필요하면 실제 값 전달
                          day: 1,
                          status: ChallengeStatus.inProgress,
                          category: '공부', // 필요하면 전달
                          createdAt: DateTime.now(),
                          type: null, // 필요하면 전달
                        ),
                      ),
                    ),
                  );

                  // 차감 알림
                },
                child: Text(
                  '도전 시작',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
