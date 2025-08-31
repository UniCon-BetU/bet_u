// lib/views/pages/community_tab/board_page.dart
import 'package:bet_u/views/pages/community_tab/post_create_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:flutter/material.dart';
import '../../widgets/searchbar_widget.dart';
import '../../widgets/postcard_widget.dart';

class BoardPage extends StatefulWidget {
  final String title;
  final List<PostCard> posts;
  final int? crewId;

  const BoardPage({
    super.key,
    required this.title,
    required this.posts,
    this.crewId,
  });

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String _q = '';

  // 내부 편집용 리스트 (삭제 반영 등)
  late List<PostCard> _items;

  @override
  void initState() {
    super.initState();
    _items = List<PostCard>.from(widget.posts);
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
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            hintText: '제목으로 검색',
            onChanged: (v) => setState(() => _q = v),
            onSubmitted: (v) => setState(() => _q = v),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      '게시물이 없어요',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = results[i];
                      return PostCardWidget(
                        post: p,
                        onTap: () async {
                          // 상세로 이동 → 되돌아올 때 결과로 삭제 여부 처리
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailPage(
                                args: PostDetailArgs(
                                  postId: p.postId,
                                  title: p.title, // ← fallback
                                  author: p.author, // ← fallback
                                  content: p.excerpt, // ← fallback
                                ),
                              ),
                            ),
                          );

                          // 상세에서 Navigator.pop(context, 'deleted') 한 경우 처리
                          if (res == 'deleted') {
                            setState(() {
                              _items.removeWhere((x) => x.postId == p.postId);
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('게시물이 삭제되었습니다')),
                              );
                            }
                          }
                        },
                      );
                    },
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
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
