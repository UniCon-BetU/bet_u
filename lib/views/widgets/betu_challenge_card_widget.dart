import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:bet_u/views/pages/challenge_detail_page.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/pages/challenge_page.dart';
import 'package:bet_u/utils/recent_challenges.dart';

// ✅ StatelessWidget으로 변경
class BetuChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? afterPop; // DetailPage에서 돌아왔을 때 실행할 콜백

  const BetuChallengeCard({super.key, required this.challenge, this.afterPop});

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
              mainAxisAlignment: MainAxisAlignment.end,
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
                const SizedBox(height: 2),
                if (challenge.bannerDescription != null)
                  Text(
                    challenge.bannerDescription!,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),

        // 2. ChallengeTileWidget
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ChallengeTileWidget(
            c: challenge,
            onTap: () {
              addRecentVisitedChallenge(challenge);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengeDetailPage(challenge: challenge),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
