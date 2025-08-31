import 'dart:convert';

import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/challenge.dart';
import '../widgets/challenge_section_widget.dart';
import '../../theme/app_colors.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';

Future<void> fetchAllChallenges() async {
  try {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('https://54.180.150.39.nip.io/api/challenges'),
      headers: {
        'Authorization': 'Bearer $token', // 필요 시
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final challenges = data.map((e) => Challenge.fromJson(e)).toList();
      allChallengesNotifier.value = challenges;
    } else {
      print('API error: ${response.statusCode}');
    }
  } catch (e) {
    print('Fetch failed: $e');
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: allChallengesNotifier,
      builder: (context, allChallengesValue, _) {
        final List<Challenge> myChallenges = allChallengesValue
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                  // myChallenges 리스트가 비어있을 때 메시지 표시
                  if (myChallenges.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          '진행 중인 챌린지가 없습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    // myChallenges가 있을 때만 SectionWidget 표시
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
                  BetuChallengeSectionWidget(
                    challengeFrom: allChallengesValue
                        .where((c) => c.category == 'BETU')
                        .toList(),
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
