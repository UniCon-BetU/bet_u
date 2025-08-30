import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import 'package:bet_u/views/widgets/profile_widget.dart';
import 'package:bet_u/views/widgets/section_widget.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import '../../../theme/app_colors.dart';
import 'package:bet_u/data/global_challenges.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 만약 서버에서 fetch하고 싶으면 여기서 호출 가능
    // fetchChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        elevation: 0,
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
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '마이페이지',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Challenge>>(
        valueListenable: allChallengesNotifier,
        builder: (context, allChallengesValue, _) {
          final myChallenges = allChallengesValue
              .where((c) => c.status == ChallengeStatus.inProgress)
              .toList();
          final totalCount = myChallenges.length;
          final doneCount = myChallenges
              .where((c) => c.todayCheck == TodayCheck.done)
              .length;
          final progress = totalCount == 0 ? 0 : doneCount / totalCount;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      ProfileWidget(
                        title: '연오 고',
                        subtitle: 'BETU와 함께한 시간 D+16',
                        stats: [
                          StatItemData(label: '진행중', value: '$totalCount'),
                          StatItemData(label: '완료/중단', value: '5'),
                          StatItemData(label: '성공', value: '5'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionWidget(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0.0,
                                end: progress.toDouble(),
                              ), // progress를 double로 변환
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
                                        valueColor:
                                            const AlwaysStoppedAnimation(
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
