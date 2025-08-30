import 'dart:convert';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class ChallengeListPage extends StatefulWidget {
  const ChallengeListPage({super.key});

  @override
  State<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends State<ChallengeListPage> {
  late Future<List<Challenge>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _challengesFuture = _fetchChallenges();
  }

  Future<List<Challenge>> _fetchChallenges() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final url = Uri.parse('$baseUrl/api/challenges');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else {
      throw Exception(
        '챌린지 목록을 불러오지 못했습니다: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 챌린지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _challengesFuture = _fetchChallenges();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _challengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('생성된 챌린지가 없습니다.'));
          } else {
            final challengesFromApi = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemCount: challengesFromApi.length,
              itemBuilder: (context, index) {
                final challenge = challengesFromApi[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ChallengeTileWidget(
                    c: challenge,
                    onTap: () {
                      // 필요하면 타일 클릭 시 상세 페이지 이동 등 구현
                      // Navigator.push(...);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
