import 'package:bet_u/views/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../../models/category.dart';
import '../widgets/challenge_section_widget.dart';
import '../widgets/popular_section_widget.dart';
import 'package:bet_u/views/pages/settings_page.dart';
import '../../theme/app_colors.dart';
import '../../data/global_challenges.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = const [
      Category(label: '수능', count: 1723),
      Category(label: '토익', count: 1723),
      Category(label: '인강', count: 1723),
      Category(label: '매일자습', count: 1723),
    ];

    final myChallenges = [
      Challenge(
        title: '비문학 1일 3지문',
        participants: 153,
        day: 12,
        status: ChallengeStatus.done,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '모의고사 주요과목 4합 5달성',
        participants: 524,
        day: 12,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'goal',
      ),
      Challenge(
        title: '매일 물리 사설 모의고사 1회 풀이',
        participants: 38,
        day: 9,
        status: ChallengeStatus.missed,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.done,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
      ),
    ];

    // 1) 개수 계산
    final int totalCount = myChallenges.length;
    final int doneCount = myChallenges
        .where((c) => c.status == ChallengeStatus.done)
        .length;

    // 2) 진행률 (0.0 ~ 1.0)
    final double progress = totalCount == 0 ? 0 : doneCount / totalCount;

    final rankingChallenges = [ 
      Challenge(
        title: '하루 영단어 50개 암기',
        participants: 1263,
        day: 0,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '매일 수학 N제 20개 풀이',
        participants: 818,
        day: 0,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
    ];

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
                    width: 48, height: 48,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),

                  Image.asset(
                    'assets/images/BETU_letters.png', 
                    width: 96, height: 48,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  )
                ],
              ),

              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SettingsPage();
                      },
                    ),
                  );
                },
              )
            ],
          )
        )
      ),  
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),  
        child: SingleChildScrollView(
          child: Column(
            children: [
              ChallengeSectionWidget(items: myChallenges),
              // AdBannerWidget(imageUrl: 'assets/images/bet_u_bot.jpg'),

              SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress), // progress = doneCount / totalCount
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
                                valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 12),
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
                          Text('$doneCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            )
                          ),

                          Text('/ 전체 $totalCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: AppColors.darkestGray,
                            )
                          ),
                        ]
                      )
                    ],
                  ),

                  SizedBox(width: 12),
                  Card(
                    color: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Center(
                        child: Text('$userPoints P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ) 
                        )
                      ),
                    ),
                  ),
                ],  
              ),
              
              SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () {
                  final betuOnlyChallenges =
                      betuChallenges.where((c) => c.type == 'betu').toList();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BetuChallengesPage(
                        betuChallenges: betuOnlyChallenges,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'BETU Challenges',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6), // 아이콘과 텍스트 사이 간격 넓힘
                        Icon(Icons.eco, color: AppColors.primaryGreen),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
                  ],
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}
