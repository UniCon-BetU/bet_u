// lib/views/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/services/betu_challenge_loader.dart';

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
                  const SizedBox(height: 80),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: Image.asset(
                        'assets/images/betu_happy.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '어디서 시작할지 모르겠나요?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen, // ✅ 배추 느낌나는 색상
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '배추에게 물어보세요!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ✅ 첫 번째 버튼
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 기능 구현 예정
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ), // 동기부여 느낌
                      label: const Text(
                        '동기부여가 필요해요',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ 두 번째 버튼
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 기능 구현 예정
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ), // 챌린지 추천 느낌
                      label: const Text(
                        '챌린지 추천이 필요해요',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // ✅ 입력창 (비활성화)
                  TextField(
                    enabled: false, // 버튼 누르기 전까지 비활성화
                    decoration: InputDecoration(
                      hintText: '먼저 버튼을 눌러주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
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
