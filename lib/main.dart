import 'package:bet_u/views/pages/welcome_page.dart';
import 'package:bet_u/views/pages/challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/my_challenge_page.dart';
import 'package:bet_u/views/pages/community_tab/community_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
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
