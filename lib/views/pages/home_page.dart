// lib/views/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_section_widget.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/services/betu_challenge_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 앱 첫 진입 시 챌린지 로드
    BetuChallengeLoader.loadAndPublish(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: allChallengesNotifier,
      builder: (context, allChallengesValue, _) {
        // 진행중인 챌린지 (UI 용)
        final List<Challenge> myChallenges = allChallengesValue
            .where((c) => c.status == ChallengeStatus.inProgress)
            .toList();

        final int totalCount = myChallenges.length;
        final int doneCount =
            myChallenges.where((c) => c.todayCheck == TodayCheck.done).length;

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
                  // 내 챌린지 섹션
                  ChallengeSectionWidget(
                    items: myChallenges,
                    onSectionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyChallengePage(
                            myChallenges: allChallengesValue,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 오늘 인증 진행바
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

                  // BETU 챌린지 섹션 (전역 노티파이어 구독으로 자동 갱신)
                  ValueListenableBuilder<List<Challenge>>(
                    valueListenable: allChallengesNotifier,
                    builder: (context, challenges, __) {
                      final betuOnly = challenges
                          .where((c) => c.WhoMadeIt == 'BETU')
                          .toList();

                      // 로딩 중 & 비어있을 때 스켈레톤/로딩 처리하고 싶으면 아래 주석 해제
                      // final isLoading = BetuChallengeLoader.isLoading;
                      // if (betuOnly.isEmpty && isLoading) {
                      //   return const Padding(
                      //     padding: EdgeInsets.symmetric(vertical: 24),
                      //     child: Center(
                      //       child: SizedBox(
                      //         height: 24, width: 24,
                      //         child: CircularProgressIndicator(strokeWidth: 2),
                      //       ),
                      //     ),
                      //   );
                      // }

                      return BetuChallengeSectionWidget(
                        challengeFrom: betuOnly,
                        // onRefresh: () => BetuChallengeLoader.loadAndPublish(context: context), // 원하면 새로고침 버튼 달기
                        // isRefreshing: isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
