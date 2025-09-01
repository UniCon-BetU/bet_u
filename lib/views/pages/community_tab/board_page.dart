// lib/views/pages/community_tab/board_page.dart
import 'package:bet_u/views/pages/community_tab/post_create_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:flutter/material.dart';
import '../../widgets/postcard_widget.dart';
import 'package:bet_u/views/widgets/search_bar_widget.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class BoardPage extends StatefulWidget {
  final String title;
  final List<PostCard> posts;
  final int? crewId;

  const BoardPage({
    super.key,
    required this.title,
    required this.posts,
    this.crewId = 0,
  });

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String _q = '';

  // 내부 편집용 리스트 (삭제 반영 등)
  late List<PostCard> _items;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _loading = false;
  String? _error;

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await TokenStorage.getToken();
    try {
      // 필요 시 crewId 필터를 쿼리로: /api/community/posts?crewId=123
      final uri = widget.crewId == null
          ? Uri.parse('$baseUrl/api/community/posts')
          : Uri.parse('$baseUrl/api/community/posts?crewId=${widget.crewId}');

      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty
            ? jsonDecode(body) as List<dynamic>
            : <dynamic>[];

        // JSON → PostCard 매핑 (키 이름은 백엔드 스키마에 맞게 조정)
        final latest = decoded.map((e) {
          final m = e as Map<String, dynamic>;
          return PostCard(
            postId: (m['postId'] ?? m['id'] ?? 0) as int,
            title: (m['title'] ?? '').toString(),
            excerpt: (m['content'] ?? m['preview'] ?? '').toString(),
            author: (m['authorName'] ?? m['author'] ?? '익명').toString(),
            likes: (m['likeCount'] ?? 0) as int,
            createdAt:
                DateTime.tryParse((m['createdAt'] ?? '').toString()) ??
                DateTime.now(),
            // thumbnailUrl: m['thumbnailUrl'] as String?,
          );
        }).toList();

        // crewId 없을 때는 일반게시판만(crewId가 null/0) 필터링
        final filtered = widget.crewId == null
            ? latest.where((p) {
                final rawCrewId =
                    (decoded.firstWhere(
                          (e0) =>
                              (e0 as Map<String, dynamic>)['postId'] ==
                              p.postId,
                          orElse: () => const {},
                        )
                        as Map?)?['crewId'];
                final cid = (rawCrewId is int)
                    ? rawCrewId
                    : (rawCrewId == null ? 0 : 0);
                return cid == 0 || rawCrewId == null;
              }).toList()
            : latest;

        if (!mounted) return;
        setState(() {
          _items = filtered;
        });
      } else {
        if (!mounted) return;
        setState(() => _error = '불러오기 실패: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _items = List<PostCard>.from(widget.posts);

    // 텍스트 변화 → _q 갱신
    _searchController.addListener(() {
      final v = _searchController.text;
      if (_q != v) {
        setState(() => _q = v);
      }
    });
    _fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 부모에서 새로운 posts로 다시 push되는 경우 동기화
  @override
  void didUpdateWidget(covariant BoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.posts, widget.posts)) {
      _items = List<PostCard>.from(widget.posts);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();

    // 제목/요약/작성자 기준으로 검색 (필요 없으면 title만 남겨도 됨)
    final results = q.isEmpty
        ? _items
        : _items.where((p) {
            final inTitle = p.title.toLowerCase().contains(q);
            final inExcerpt = (p.excerpt).toLowerCase().contains(q);
            final inAuthor = (p.author).toLowerCase().contains(q);
            return inTitle || inExcerpt || inAuthor;
          }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBarOnly(
              icon: Icons.refresh,
              controller: _searchController,
              focusNode: _searchFocusNode,
              isSearching: _isSearching,
              onSearchingChanged: (isOn) => setState(() => _isSearching = isOn),
              onTapSearch: () {
                // 필요 시 최근검색어/필터 패널 표시 등
              },
              onPlusPressed: _fetchPosts,
              // + 버튼 동작 (원하면 글쓰기 진입 등으로 연결 가능)
              // Navigator.push(... PostCreatePage ...);
              decoration: InputDecoration(
                hintText: '제목 및 내용으로 검색',
                hintStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkerGray,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 12,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/normal_lettuce.png',
                    width: 48,
                    height: 48,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 지우기
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear(); // <- _query는 리스너로 자동 반영
                          _isSearching = true; // 유지하거나 false로 바꿔도 됨
                        });
                        _searchFocusNode.requestFocus();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkerGray,
                      ),
                    ),
                    const SizedBox(width: 7),
                    // 검색(엔터 대신 아이콘 눌러 실행하고 싶을 때)
                    GestureDetector(
                      onTap: () {
                        // 필요 시 포커스 내려주기
                        _searchFocusNode.unfocus();
                        // _query는 이미 최신값, 여기서 필터링은 자동 반영됨
                        // 서버 검색 트리거가 필요하면 호출
                        // _fetchGroups();
                      },
                      child: const Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // 빈 공간 탭도 인식
              onTap: () {
                setState(() => _isSearching = false);
                FocusScope.of(context).unfocus(); // 키보드 내려주기
              },
              child: RefreshIndicator(
                onRefresh: _fetchPosts,
                child: Container(
                  color: AppColors.lightGray, // 원하는 배경색
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : (_error != null)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: _fetchPosts,
                                child: const Text('다시 시도'),
                              ),
                            ),
                          ],
                        )
                      : (results.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 24),
                                  Center(
                                    child: Text(
                                      '게시물이 없어요',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final p = results[i];
                                  return PostCardWidget(
                                    post: p,
                                    onTap: () async {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PostDetailPage(
                                            args: PostDetailArgs(
                                              postId: p.postId,
                                              title: p.title,
                                              author: p.author,
                                              content: p.excerpt,
                                            ),
                                          ),
                                        ),
                                      );
                                      if (res == 'deleted') {
                                        setState(() {
                                          _items.removeWhere(
                                            (x) => x.postId == p.postId,
                                          );
                                        });
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('게시물이 삭제되었습니다'),
                                            ),
                                          );
                                        }
                                        // 필요하면 서버 갱신
                                        // await _fetchPosts();
                                      }
                                    },
                                  );
                                },
                              )),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade600,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => widget.crewId == null
                  ? PostCreatePage()
                  : PostCreatePage(crewId: widget.crewId),
            ),
          );

          // 글 작성 후 돌아오면 간단 피드백 (목록 재조회는 부모 페이지에서 해주세요)
          if (res == 'created' && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다')));
          }
          _fetchPosts();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
