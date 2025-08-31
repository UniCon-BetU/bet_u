import 'dart:convert';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/pages/welcome_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/views/pages/community_tab/community_page.dart';
import 'theme/app_colors.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  // 숫자 포맷할 때 사용할 기본 로케일
  Intl.defaultLocale = PlatformDispatcher.instance.locale.toLanguageTag();
  runApp(const MyApp());
}

// 서버에서 챌린지 데이터를 가져와 allChallengesNotifier에 반영
Future<void> fetchChallenges() async {
  try {
    final response = await http.get(
      Uri.parse('https://54.180.150.39.nip.io/api/challenges'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final backendChallenges = data
          .map((json) => Challenge.fromJson(json))
          .toList();

      allChallengesNotifier.value = backendChallenges;
    } else {
      debugPrint('Failed to fetch challenges: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching challenges: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    fetchChallenges(); // 앱 시작 시 데이터 불러오기
  }

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: allChallengesNotifier,
      builder: (context, challenges, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              surface: Color.fromARGB(255, 255, 255, 255),
            ),
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
            fontFamily: 'Freesentation', // 폰트 적용
            textTheme: baseTextTheme.apply(fontFamily: 'Freesentation'),
          ),
          home: const WelcomePage(),
          routes: {
            '/my_challenge': (context) =>
                MyChallengePage(myChallenges: challenges),
            '/challenge': (context) => const ChallengePage(),
            '/community': (context) => CommunityPage(),
          },
        );
      },
    );
  }
}
