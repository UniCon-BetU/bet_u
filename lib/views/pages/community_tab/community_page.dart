// lib/views/pages/community_tab/community_page.dart
import 'dart:convert';

import 'package:bet_u/models/group.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/community_tab/board_page.dart';
import 'package:bet_u/views/pages/community_tab/group_create_page.dart';
import 'package:bet_u/views/pages/community_tab/group_find_page.dart';
import 'package:bet_u/views/pages/community_tab/group_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:bet_u/views/widgets/postcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/board_widget.dart';
import '../../widgets/group_dashboard_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 게시판 더미
  List<BoardPost> get _dummy => [
    BoardPost(title: '수능 국어 1일 3지문 팁 공유합니다', createdAt: DateTime(2025, 8, 8)),
    BoardPost(title: '영어 단어장 추천 부탁!', createdAt: DateTime(2025, 8, 7)),
    BoardPost(title: '힘들 때 보면 좋은 글', createdAt: DateTime(2025, 8, 6)),
    BoardPost(title: '요즘 토익 시험 특징', createdAt: DateTime(2025, 8, 5)),
    BoardPost(title: '이 챌린지 성공하신 분 있나요?', createdAt: DateTime(2025, 8, 5)),
  ];

  // 내가 참여한 그룹 (API로 채움)
  List<GroupInfo> _myGroups = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyGroups();
  }

  Future<void> _fetchMyGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse('$baseUrl/api/crews/me');
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty ? jsonDecode(body) : [];

        // 예상 응답:
        // [
        //   { "crewId": 1, "crewName": "string", "crewCode": "string",
        //     "isPublic": true, "myRole": "OWNER" }
        // ]
        print('response body: ${res.body}');

        final List<GroupInfo> items = (decoded as List<dynamic>).map((e) {
          final m = e as Map<String, dynamic>;
          final isPublic = m['isPublic'] == true;
          return GroupInfo(
            crewId: (m['crewId'] ?? 0) as int,
            crewCode: (m['crewCode'] ?? '').toString(),
            name: (m['crewName'] ?? '이름없음').toString(),
            description: '상세정보 예시'.toString(), // 상세 정보 미정 → 코드 노출
            memberCount: 0, // API에 없으므로 기본값
            icon: isPublic ? Icons.public : Icons.lock,
          );
        }).toList();

        if (!mounted) return;
        setState(() => _myGroups = items);
      } else {
        if (!mounted) return;
        setState(() => _error = '그룹 불러오기 실패: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '네트워크 오류: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),

            // 게시판 섹션 (그대로)
            BoardSectionCard(
              title: '일반 게시판',
              posts: _dummy,
              onTap: (post) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      args: PostDetailArgs(
                        title: post.title,
                        author: '관리자',
                        dateString: DateFormat(
                          'yyyy.MM.dd',
                        ).format(post.createdAt),
                        content: '게시물 본문 내용 예시입니다.',
                        likeCountInitial: 12,
                      ),
                    ),
                  ),
                );
              },
              onMore: () {
                final cards = _dummy
                    .map(
                      (b) => PostCard(
                        title: b.title,
                        excerpt: '내용 미리보기 예시입니다.',
                        author: '관리자',
                        likes: 0,
                        createdAt: b.createdAt,
                      ),
                    )
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardPage(title: '일반 게시판', posts: cards),
                  ),
                );
              },
            ),

            // 로딩/에러 표시
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchMyGroups,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20.0),

            // 내 그룹 대시보드 (API 결과 주입)
            GroupDashboardWidget(
              groups: _myGroups, // []면 컴포넌트가 빈 상태 문구를 보여줌
              onTapDiscover: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GroupFindPage()),
                );
              },
              onTapCreate: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GroupCreatePage()),
                );
              },
              onTapGroup: (g) {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => GroupPage(group: g)));
              },
            ),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
