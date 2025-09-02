import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/mypage_tab/challenge_history_page.dart';
import 'package:bet_u/views/pages/mypage_tab/point_page.dart';
import 'package:bet_u/views/pages/mypage_tab/scrap_page.dart';
import 'package:bet_u/views/pages/mypage_tab/security_page.dart';
import 'package:bet_u/views/widgets/my_page_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../models/challenge.dart';
import '../../widgets/challenge_section_widget.dart';
import '../../../theme/app_colors.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../widgets/profile_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? userPoints;

  Future<void> fetchUserPoints() async {
    final token = await TokenStorage.getToken();

    final url = Uri.parse('$baseUrl/api/user/points');
    final res = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        userPoints = int.tryParse(res.body); // body = "5000"
      });
    } else {
      print('포인트 불러오기 실패: ${res.statusCode} ${res.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserPoints();
  }

  @override
  Widget build(BuildContext context) {
    // 1) 내가 참여한 챌린지(진행중/시작전 모두 포함)
    final List<Challenge> myChallenges = allChallengesNotifier.value
        .where((c) => c.participating)
        .toList();

    // 2) 진행 중 카운트/리스트
    final inProgressList = myChallenges
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList();
    final int inProgressCount = inProgressList.length;

    // 3) 오늘 인증 완료/전체(내가 참여한 것 기준)
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
                '마이 페이지',
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
                    title: '사용자님 안녕하세요!', // TODO: 사용자 이름을 추가하자
                    subtitle: 'BETU와 함께한 오늘',
                    stats: [
                      StatItemData(label: '진행중', value: '$inProgressCount'),
                      StatItemData(
                        label: '내 그룹',
                        value: '5',
                      ), //TODO: 그룹 개수를 추가하자
                    ],
                  ),
                  const SizedBox(height: 16),
                  ChallengeSectionWidget(
                    onSectionTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyChallengePage()),
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
                  point: userPoints != null ? '${userPoints!} P' : '불러오는 중...',
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
