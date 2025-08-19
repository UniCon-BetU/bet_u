import 'package:flutter/material.dart';

class PostDetailArgs {
  final String title;
  final String author;
  final String dateString;
  final String content;
  final int likeCountInitial;

  const PostDetailArgs({
    required this.title,
    required this.author,
    required this.dateString,
    required this.content,
    this.likeCountInitial = 0,
  });
}

class PostDetailPage extends StatefulWidget {
  final PostDetailArgs args;
  const PostDetailPage({super.key, required this.args});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int _likes;
  bool _liked = false;

  final _commentCtl = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    _likes = widget.args.likeCountInitial;
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _submitComment() {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.add(text);
      _commentCtl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8), // 홈과 동일한 크림톤
      appBar: AppBar(
        title: const Text('게시물'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9E8),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 카드: 제목 / 작성자 / 좋아요
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    widget.args.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 작성자
                  Text(
                    widget.args.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // 날짜
                  Text(
                    widget.args.dateString, // ← 여기에 날짜 문자열
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),

                  const SizedBox(height: 8),

                  // 좋아요
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleLike,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          _liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: _liked
                              ? const Color(0xFFE2504C)
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_likes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 본문 내용 박스
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 200, // 최소 높이 설정
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                widget.args.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            // 댓글 리스트
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: _comments.isEmpty
                    ? Center(
                        child: Text(
                          '아직 댓글이 없어요',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 16, thickness: 1),
                        itemBuilder: (context, i) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                child: Icon(Icons.person, size: 14),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _comments[i],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),

            // 댓글 입력창
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
