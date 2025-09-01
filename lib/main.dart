import 'dart:convert';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/utils/point_store.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/welcome_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/views/pages/community_tab/community_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 기기 로케일 쓰기 또는 고정 'ko_KR'
  final localeTag = PlatformDispatcher.instance.locale
      .toLanguageTag(); // ex) ko-KR
  Intl.defaultLocale = localeTag.replaceAll('-', '_'); // ko_KR 로 변환
  await initializeDateFormatting(Intl.defaultLocale!);

  runApp(const MyApp());
}

// 서버에서 챌린지 데이터를 가져와 allChallengesNotifier에 반영
Future<void> fetchChallenges() async {
  final token = await TokenStorage.getToken(); // ← 토큰 읽기
  if (token == null || token.isEmpty) {
    debugPrint('No token. Skip fetchChallenges');
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('https://54.180.150.39.nip.io/api/challenges'),
      headers: {'Authorization': 'Bearer $token'},
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

Future<void> _bootstrap() async {
  final token = await TokenStorage.getToken();
  if (token != null && token.isNotEmpty) {
    await Future.wait([fetchChallenges(), PointStore.instance.ensureLoaded()]);
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
    _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: allChallengesNotifier,
      builder: (context, challenges, _) {
        return MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
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
            '/my_challenge': (context) => MyChallengePage(),
            '/challenge': (context) => const ChallengePage(),
            '/community': (context) => CommunityPage(),
          },
        );
      },
    );
  }
}
