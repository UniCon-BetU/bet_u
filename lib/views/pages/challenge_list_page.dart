// 1. 챌린지 모델 가져오기
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';

import '/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  List<Challenge> challenges = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchChallenges();
  }

  Future<void> fetchChallenges() async {
    final uri = Uri.parse('https://54.180.150.39.nip.io/api/challenges');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          challenges = data.map((e) => Challenge.fromJson(e)).toList();
          loading = false;
        });
      } else {
        debugPrint('챌린지 조회 실패: ${res.statusCode}');
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('에러: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeTileWidget(c: challenge);
      },
    );
  }
}
