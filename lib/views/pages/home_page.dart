// lib/views/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_section_widget.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/services/betu_challenge_loader.dart';
import 'package:bet_u/data/global_challenges.dart';

// ✅ 내 챌린지 전역 상태 & 로더
import 'package:bet_u/data/my_challenges.dart';
import 'package:bet_u/services/my_challenge_loader.dart';

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
    BetuChallengeLoader.loadAndPublish(context: context); // BETU 챌린지
    MyChallengeLoader.loadAndPublish(context: context); // 내 챌린지
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: myChallengesNotifier, // ✅ 내 챌린지 기준으로 UI 구성
      builder: (context, myChallenges, _) {
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
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(children: [
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
