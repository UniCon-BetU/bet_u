import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_detail_page.dart';
import 'package:bet_u/utils/recent_challenges.dart';
import 'package:bet_u/theme/app_colors.dart';

// ✅ StatelessWidget으로 변경
class BetuChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? afterPop;

  const BetuChallengeCard({super.key, required this.challenge, this.afterPop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Stack 전체 높이 지정
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 하단 초록색 배경
          Positioned(
            left: 12,
            right: 12,
            bottom: 25,
            height: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ).copyWith(bottom: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
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
                  const SizedBox(height: 0),
                  if (challenge.bannerDescription != null)
                    Text(
                      challenge.bannerDescription!,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 2),
                ],
              ),
            ),
          ),

          // 2. ChallengeTileWidget
          Positioned(
            left: 0,
            right: 0,

            // bottom: 15, // 기존 bottom 속성 제거
            top: 0, // 타일을 Stack의 맨 위로 올림
            child: ChallengeTileWidget(
              c: challenge,
              onTap: () {
                addRecentVisitedChallenge(challenge);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeDetailPage(challenge: challenge),
                  ),
                ).then((_) {
                  if (afterPop != null) afterPop!();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
