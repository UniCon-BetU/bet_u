import 'package:bet_u/views/pages/welcome_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/views/pages/community_tab/community_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 기존 TextTheme 가져오기
    final baseTextTheme = ThemeData.light().textTheme;

    // 전체 폰트만 변경
    final customTextTheme = baseTextTheme.apply(
      fontFamily: 'freesentation', // 여기 원하는 폰트 이름
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: const Color.fromARGB(255, 255, 255, 255),
        ),
        // 아래 코드를 추가하여 폰트 적용
        fontFamily: 'Freesentation',
      ),
      home: const WelcomePage(),
      routes: {
        '/my_challenge': (context) => const MyChallengePage(myChallenges: []),
        '/challenge': (context) => const ChallengePage(),
        '/community': (context) => CommunityPage(),
      },
    );
  }
}
