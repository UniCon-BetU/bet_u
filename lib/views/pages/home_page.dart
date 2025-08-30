import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/views/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../widgets/section_widget.dart';
import '../widgets/popular_section_widget.dart';
import 'package:bet_u/views/pages/settings_page.dart';
import '../../theme/app_colors.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Challenge> myChallenges = allChallenges
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList();

    final int totalCount = myChallenges.length;
    final int doneCount = myChallenges
        .where((c) => c.todayCheck == TodayCheck.done)
        .length;

    final double progress = totalCount == 0 ? 0 : doneCount / totalCount;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/normal_lettuce.png',
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/BETU_letters.png',
                    width: 96,
                    height: 48,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              // 알림 버튼 제거
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            children: [
              SectionWidget(
                items: myChallenges,
                onSectionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyChallengePage(myChallenges: allChallenges),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 18,
                                backgroundColor: AppColors.darkestGray,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '오늘의 인증 완료',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$doneCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Text(
                            '/ 전체 $totalCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: AppColors.darkestGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              BetuChallengeSectionWidget(challengeFrom: allChallenges),
            ],
          ),
        ),
      ),
    );
  }
}
