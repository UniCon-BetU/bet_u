import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/utils/point_store.dart';
import 'package:bet_u/utils/token_util.dart';

import 'package:bet_u/views/pages/welcome_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_page.dart';
import 'package:bet_u/views/pages/mypage_tab/my_challenge_page.dart';
import 'package:bet_u/views/pages/community_tab/community_page.dart';
import 'dart:io' show File; // 모바일용
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 임시 비활성화
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Intl.defaultLocale = PlatformDispatcher.instance.locale.toLanguageTag();
  runApp(const MyApp());
}

// ===== 서버에서 챌린지 목록 가져오기 (토큰 헤더 포함 + 예외 방어) =====
Future<void> fetchChallenges() async {
  try {
    final token = await TokenStorage.getToken(); // 없으면 null
    final res = await http.get(
      Uri.parse('https://54.180.150.39.nip.io/api/challenges'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // 혹시 빈 본문/HTML 섞여 들어오는 경우 방어
      final body = res.body.trim();
      if (body.isEmpty) {
        allChallengesNotifier.value = <Challenge>[];
        return;
      }
      final ct = (res.headers['content-type'] ?? '').toLowerCase();
      if (!ct.contains('application/json')) {
        debugPrint('Unexpected content-type: $ct');
        allChallengesNotifier.value = <Challenge>[];
        return;
      }

      final decoded = jsonDecode(body);
      if (decoded is List) {
        final backendChallenges = decoded
            .map((e) => Challenge.fromJson(e))
            .toList();
        allChallengesNotifier.value = backendChallenges;
      } else {
        debugPrint('JSON is not a list');
        allChallengesNotifier.value = <Challenge>[];
      }
    } else {
      debugPrint('Failed to fetch challenges: ${res.statusCode} ${res.body}');
      allChallengesNotifier.value = <Challenge>[];
    }
  } catch (e, st) {
    debugPrint('Error fetching challenges: $e\n$st');
    allChallengesNotifier.value = <Challenge>[];
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? bootError;
  bool _loading = true;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();

    // 기존 WidgetsBinding.instance.addPostFrameCallback 코드 교체
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _hasToken = await PointStore.instance.hasToken(); // 토큰 있는지 확인
        await fetchChallenges(); // 서버에서 챌린지 가져오기
      } catch (e, st) {
        debugPrint('BOOT INIT ERROR: $e\n$st');
        if (mounted) setState(() => bootError = e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (bootError != null) {
      return MaterialApp(
        home: Scaffold(body: Center(child: Text('부팅 실패: $bootError'))),
      );
    }

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
        fontFamily: 'Freesentation',
        textTheme: baseTextTheme.apply(fontFamily: 'Freesentation'),
      ),
      home: _hasToken ? const ChallengePage() : const WelcomePage(),
      routes: {
        '/my_challenge': (_) => const MyChallengePage(),
        '/challenge': (_) => const ChallengePage(),
        '/community': (_) => const CommunityPage(),
      },
    );
  }
}
