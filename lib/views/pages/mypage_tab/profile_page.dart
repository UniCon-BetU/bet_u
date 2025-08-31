import 'dart:convert';

import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/mypage_tab/challenge_history_page.dart';
import 'package:bet_u/views/pages/mypage_tab/point_page.dart';
import 'package:bet_u/views/pages/mypage_tab/scrap_page.dart';
import 'package:bet_u/views/pages/mypage_tab/security_page.dart';
import 'package:bet_u/views/widgets/my_page_setting_widget.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import '../../widgets/challenge_section_widget.dart';
import '../../../theme/app_colors.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../widgets/profile_widget.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int userPoints = 0;

  @override
  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // 페이지 열리면 바로 최신 포인트 가져오기
  }

  Future<int> _fetchUserPoints() async {
    final token = await TokenStorage.getToken(); // 저장된 토큰 가져오기

    final url = Uri.parse('https://54.180.150.39.nip.io/api/user/points');

    final response = await http.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 서버에서 {"points": 50000} 이런 구조로 내려준다고 가정
      return data['points'] ?? 0;
    } else {
      throw Exception('포인트 조회 실패: ${response.statusCode}');
    }
  }

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
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Image.asset(
                'assets/images/normal_lettuce.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text(
                '마이페이지',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                children: [
                  ProfileWidget(
                    title: '연오 고',
                    subtitle: 'BETU와 함께한 시간 D+16',
                    stats: [
                      StatItemData(label: '진행중', value: '12'),
                      StatItemData(label: '완료/중단', value: '5'),
                      StatItemData(label: '성공', value: '5'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ChallengeSectionWidget(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyPageSettingWidget(
                  title: '포인트 결제',
                  image: const AssetImage('assets/images/point_icon.png'),
                  point: '$userPoints P',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PointPage()),
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
                        builder: (_) =>
                            MyChallengePage(myChallenges: allChallenges),
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
