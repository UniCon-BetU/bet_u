// lib/views/pages/challenge_tab/challenge_start_page.dart
import 'package:bet_u/utils/point_store.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_detail_page.dart';
import '../../../models/challenge.dart';
import '../../widgets/long_button_widget.dart';

class ChallengeStartPage extends StatefulWidget {
  final int deductedPoints; // 이전 화면에서 이미 차감된 금액(정보용)
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
  @override
  void initState() {
    super.initState();
    // ⚠️ 여기서 포인트 차감/갱신 하지 않습니다.
    // 차감은 참여 단계(ParticipatePage)에서 하고 PointStore에 반영 완료.
  }

  void _onStartPressed() {
    // 서버에서 이미 IN_PROGRESS로 전환됨
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ChallengeDetailPage(challenge: widget.challenge),
        ),
        (route) => route.isFirst, // 모든 기존 라우트 제거
      );
    });
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

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

            // 전역 포인트 구독해서 남은 포인트 보여주기
            ValueListenableBuilder<int>(
              valueListenable: PointStore.instance.points,
              builder: (_, p, _) {
                return Text(
                  '${_fmt(p)} 포인트가 남았습니다!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            Text(
              '${widget.challenge.title}\n도전을 시작합니다!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            const Spacer(),
            LongButtonWidget(
              text: '도전 시작',
              backgroundColor: Colors.green[600]!,
              height: 56,
              radius: 8,
              onPressed: _onStartPressed,
            ),
          ],
        ),
      ),
    );
  }
}
