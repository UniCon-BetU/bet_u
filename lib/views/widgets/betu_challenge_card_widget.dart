import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';

class BetuChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;

  const BetuChallengeCard({super.key, required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1BAB0F);

    // Stack을 사용하여 ChallengeCard 위에 초록색 배경을 추가합니다.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. 하단 초록색 배경을 먼저 깔아줍니다.
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // 2. 그 위에 ChallengeCard 위젯을 배치합니다.
        // ChallengeCard에 필요한 데이터를 전달합니다.
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ChallengeTileWidget(
            c: challenge, // 'challenge' 변수를 'c' 파라미터에 전달
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
