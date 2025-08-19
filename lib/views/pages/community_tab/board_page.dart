import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:flutter/material.dart';
import '../../widgets/searchbar_widget.dart';
import '../../widgets/postcard_widget.dart';

class BoardPage extends StatefulWidget {
  final String title;
  final List<PostCard> posts;

  const BoardPage({super.key, required this.title, required this.posts});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final results = q.isEmpty
        ? widget.posts
        : widget.posts.where((p) => p.title.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9E8),
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
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = results[i];
                      return PostCardWidget(
                        post: p,
                        onTap: () {
                          // TODO: 게시물 상세로 이동 (PostDetailPage)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailPage(
                                args: PostDetailArgs(
                                  title: "예시 게시물",
                                  author: "글쓴이", // 예시
                                  dateString:
                                      '2025.08.09', // DateFormat으로 변환해서 전달
                                  content: '본문 내용 예시',
                                  likeCountInitial: 0,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
