// lib/views/pages/community_tab/community_page.dart
import 'dart:convert';
import 'package:bet_u/models/post.dart';
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

import '../../widgets/board_widget.dart';
import '../../widgets/group_dashboard_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 내가 참여한 그룹 (API로 채움)
  List<GroupInfo> _myGroups = [];
  bool _loading = false;
  String? _error;
  String? _fmtDate(DateTime? dt) {
    if (dt == null) return null;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  // 게시글
  List<Post> _posts = [];
  bool _loadingPosts = false;
  String? _postError;

  @override
  void initState() {
    super.initState();
    _fetchMyGroups();
    _fetchPosts();
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
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- API: 커뮤니티 게시글 목록 ---
  Future<void> _fetchPosts() async {
    setState(() {
      _loadingPosts = true;
      _postError = null;
    });

    final token = await TokenStorage.getToken(); // 인증 필요 없으면 생략됨
    try {
      final uri = Uri.parse('$baseUrl/api/community/posts');
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty
            ? jsonDecode(body) as List<dynamic>
            : <dynamic>[];

        final list = decoded
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();

        if (!mounted) return;
        setState(() => _posts = list);

        // 디버그
        for (final p in list) {
          print('[POST] id=${p.postId} title=${p.title} likes=${p.likeCount}');
        }
      } else {
        if (!mounted) return;
        setState(
          () =>
              _postError = '게시글 불러오기 실패: ${res.statusCode} ${res.reasonPhrase}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _postError = '네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 표시용: Post → BoardPost
    final boardList = List<BoardPost>.generate(
      _posts.length,
      (i) => BoardPost(
        title: _posts[i].title,
        createdAt: _posts[i].createdAt ?? DateTime.now(),
      ),
    );
    // 같은 순서의 postId 배열
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
                  const SizedBox(width: 12),
                  const Text(
                    '소셜',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // 게시판 섹션
            BoardSectionCard(
              title: '일반 게시판',
              posts: boardList,
              onTap: (bp) {
                final idx = boardList.indexOf(bp);
                if (idx < 0) return;

                final p = _posts[idx];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      args: PostDetailArgs(
                        postId: p.postId,
                        title: p.title, // ← 제목 fallback
                        author: p.authorName, // ← 작성자 fallback
                        content: p.preview, // ← 내용(미리보기) fallback
                        likeCountInitial: p.likeCount, // ← 좋아요 초기값
                        dateString: _fmtDate(p.createdAt), // ← 날짜 표시용
                      ),
                    ),
                  ),
                );
              },
              onMore: () {
                // BoardPage로 이동할 카드 생성 (postId 포함)
                final cards = List.generate(_posts.length, (i) {
                  final p = _posts[i];
                  return PostCard(
                    postId: p.postId, // ← 중요
                    title: p.title,
                    excerpt: p.preview.isNotEmpty
                        ? p.preview
                        : '내용 미리보기 예시입니다.',
                    author: p.authorName.isNotEmpty ? p.authorName : '관리자',
                    likes: p.likeCount,
                    createdAt: p.createdAt ?? DateTime.now(),
                  );
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardPage(title: '일반 게시판', posts: cards),
                  ),
                );
              },
            ),

            // 게시글 로딩/에러
            if (_loadingPosts)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_postError != null)
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
                        _postError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchPosts,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20.0),

            // 내 그룹 대시보드
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
