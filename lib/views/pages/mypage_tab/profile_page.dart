import 'package:bet_u/views/pages/mypage_tab/challenge_history_page.dart';
import 'package:bet_u/views/pages/mypage_tab/group_management_page.dart';
import 'package:bet_u/views/pages/mypage_tab/point_page.dart';
import 'package:bet_u/views/pages/mypage_tab/scrap_page.dart';
import 'package:bet_u/views/pages/mypage_tab/security_page.dart';
import 'package:bet_u/views/widgets/ad_banner_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:bet_u/views/widgets/my_page_setting_widget.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import '../../../models/category.dart';
import '../../widgets/challenge_section_widget.dart';
import '../../widgets/popular_section_widget.dart';
import 'package:bet_u/views/pages/settings_page.dart';
import '../../../theme/app_colors.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';

import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import 'package:bet_u/views/widgets/profile_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                  SizedBox(width: 8),
                  Text(
                    '마이페이지',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              /*
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              */
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ 프로필/챌린지/진행률: 패딩 적용
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                children: [
                  ProfileWidget(
                    title: '연오 고', // 닉네임
                    subtitle: 'BETU와 함께한 시간 D+16', // 하위 코멘트
                    stats: [
                      StatItemData(label: '진행중', value: '12'),
                      StatItemData(label: '완료/중단', value: '5'),
                      StatItemData(label: '성공', value: '5'),
                      // 필요한 만큼 더 추가 가능
                    ],
                  ),
                  const SizedBox(height: 16),
                  ChallengeSectionWidget(items: myChallenges),
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 세팅 위젯만 좌우 끝까지
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyPageSettingWidget(
                  title: '포인트 결제',
                  image: AssetImage('assets/images/point_icon.png'),
                  point: '$userPoints P', // userPoints 변수 사용
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PointPage(), // 실제 포인트 페이지로 교체
                      ),
                    );
                  },
                ),
                MyPageSettingWidget(
                  title: '개인 및 보안',
                  icon: Icons.lock,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityPage()),
                    );
                  },
                ),
                MyPageSettingWidget(
                  title: '진행 중인 챌린지',
                  icon: Icons.stars,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyChallengePage(myChallenges: []),
                      ),
                    );
                  },
                ),
                MyPageSettingWidget(
                  title: '챌린지 내역 확인',
                  icon: Icons.check_circle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChallengeHistoryPage(),
                      ),
                    );
                  },
                ),
                MyPageSettingWidget(
                  title: '그룹 관리',
                  icon: Icons.groups,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GroupManagementPage(),
                      ),
                    );
                  },
                ),
                MyPageSettingWidget(
                  title: '스크랩',
                  icon: Icons.bookmark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScrapPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
