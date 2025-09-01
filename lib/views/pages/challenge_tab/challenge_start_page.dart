import 'package:bet_u/utils/token_util.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_detail_page.dart';
import '../../../models/challenge.dart';
import '../../widgets/long_button_widget.dart'; // LongButtonWidget 임포트

class ChallengeStartPage extends StatefulWidget {
  final int deductedPoints;
  final Challenge challenge;

  const ChallengeStartPage({
    super.key,
    required this.deductedPoints,
    required this.challenge,
  });

  @override
  State<ChallengeStartPage> createState() => _ChallengeStartPageState();
}

class _ChallengeStartPageState extends State<ChallengeStartPage> {
  int userId = 0;
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _initUserPoints();
  }

  Future<void> _initUserPoints() async {
    // 토큰에서 유저 ID 가져오기
    final id = await TokenStorage.getUserId();
    if (id != null) {
      setState(() {
        userId = id;
        // 유저의 현재 포인트 가져오기, 없으면 0
        currentPoints = widget.challenge.getUserPoints(userId);
        // 포인트 차감
        currentPoints -= widget.deductedPoints;
        widget.challenge.setUserPoints(userId, currentPoints);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.challenge.title} 도전!')),
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
              '$currentPoints 포인트가 남았습니다!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.challenge.title}\n도전을 시작합니다!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Spacer(),
            LongButtonWidget(
              text: '도전 시작',
              backgroundColor: Colors.green[600]!,
              height: 56,
              radius: 8,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        ChallengeDetailPage(challenge: widget.challenge),
                  ),
                  (route) => route.isFirst, // 맨 처음(홈)만 남김
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
