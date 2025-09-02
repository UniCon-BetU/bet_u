import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bet_u/utils/token_util.dart';
import '../../../models/challenge.dart';
import '../challenge_tab/challenge_detail_page.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class MyChallengePage extends StatefulWidget {
  const MyChallengePage({super.key});

  @override
  State<MyChallengePage> createState() => _MyChallengePageState();
}

class _MyChallengePageState extends State<MyChallengePage> {
  bool _loading = false;
  String? _error;
  List<Challenge> _all = [];

  @override
  void initState() {
    super.initState();
    _fetchMyChallenges();
  }

  Future<void> _fetchMyChallenges() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _all = [];
            _error = '로그인이 필요해요';
          });
        }
        return;
      }

      final uri = Uri.parse('$baseUrl/api/challenges/me');
      final res = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final List<dynamic> decoded = body.isNotEmpty
            ? jsonDecode(body) as List<dynamic>
            : <dynamic>[];

        final mine = decoded.map((e) {
          final m = e as Map<String, dynamic>;

          // 스웨거 응답 매핑
          final int id = (m['challengeId'] ?? 0) as int;
          final String title = (m['challengeName'] ?? '제목 없음') as String;
          final int duration = (m['challengeDuration'] ?? 0) as int;
          final int participants = (m['participantCount'] ?? 0) as int;
          final String? type = m['challengeType'] as String?;
          final List<String> tags = (m['challengeTags'] as List<dynamic>? ?? [])
              .map((x) => x.toString())
              .toList();
          final String? imageUrl = m['imageUrl'] as String?;
        
          return Challenge(
            // 기본 식별
            id: id,

            // 범위/크루
            scope: 'PUBLIC', // 필요시 'CREW' 등 실제 값으로 교체
            crew: null,

            // 타입 표준화: DURATION/TARGET → duration/target
            type: (() {
              final t = type.toString().trim().toUpperCase();
              if (t == 'DURATION') return 'duration';
              if (t == 'TARGET') return 'target';
              return t.toLowerCase();
            })(),

            // 태그
            tags: tags,
            customTags: const <String>[],

            // 표시 텍스트
            title: title,
            description: '',

            // 이미지
            imageUrls: (imageUrl != null && imageUrl.isNotEmpty)
                ? [imageUrl]
                : const <String>[],
            imageUrl: (imageUrl != null && imageUrl.isNotEmpty)
                ? imageUrl
                : null,

            // 수치
            day: duration == 0 ? 1 : duration,
            participants: participants,
            favoriteCount: 0,
            progressDays: 0,

            // 상태
            participating: true,
            status: ChallengeStatus.inProgress, // 내 참여 목록이면 진행중 가정
            todayCheck: TodayCheck.notStarted, // 오늘 인증 정보 없으니 기본값
            liked: false,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _all = mine;
          });
        }
      } else if (res.statusCode == 401) {
        if (mounted) {
          setState(() {
            _all = [];
            _error = '인증이 만료됐어요. 다시 로그인 해주세요';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = '서버 오류: ${res.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '네트워크 오류: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inProgress = _all
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('진행 중 챌린지')),
      body: RefreshIndicator(
        onRefresh: _fetchMyChallenges,
        child: _loading && _all.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton(
                      onPressed: _fetchMyChallenges,
                      child: const Text('다시 시도'),
                    ),
                  ),
                ],
              )
            : inProgress.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 48),
                  Center(
                    child: Text(
                      '진행 중인 챌린지가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: inProgress.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final challenge = inProgress[index];
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChallengeDetailPage(challenge: challenge),
                        ),
                      );
                      // 상세에서 돌아왔을 때 새로고침 하고 싶다면 주석 해제
                      // await _fetchMyChallenges();
                    },
                    child: ChallengeTileWidget(c: challenge),
                  );
                },
              ),
      ),
    );
  }
}
