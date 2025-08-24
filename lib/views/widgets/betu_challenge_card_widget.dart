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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. 하단 초록색 배경
        Positioned(
          left: 12,
          right: 12,
          bottom: -20,
          height: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).copyWith(bottom: 4),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end, // ← 아래쪽으로 정렬
              children: [
                if (challenge.bannerPeriod != null)
                  Text(
                    challenge.bannerPeriod!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2), // 텍스트 간격 조금 줄임
                if (challenge.bannerDescription != null)
                  Text(
                    challenge.bannerDescription!,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1, // 최대 2줄
                    overflow: TextOverflow.ellipsis, // 넘치면 ... 처리
                  ),
              ],
            ),
          ),
        ),

        // 2. 카드 위젯
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ChallengeTileWidget(c: challenge, onTap: onTap),
        ),
      ],
    );
  }
}
