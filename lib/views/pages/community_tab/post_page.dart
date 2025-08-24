// lib/views/pages/post_page.dart
import 'package:bet_u/utils/token_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://54.180.150.39.nip.io';

// --- API 모델 ---
class PostComment {
  final int commentId;
  final int userId;
  final String userName;
  final String content;
  PostComment({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.content,
  });
  factory PostComment.fromJson(Map<String, dynamic> j) => PostComment(
    commentId: j['commentId'] ?? 0,
    userId: j['userId'] ?? 0,
    userName: j['userName'] ?? '',
    content: j['content'] ?? '',
  );
}

class PostDetailDto {
  final int postId;
  final int? crewId;
  final int? authorId;
  final String authorName;
  final String title;
  final String content;
  final int likeCount;
  final bool? liked;
  final List<String> imageUrls;
  final List<PostComment> comments;

  PostDetailDto({
    required this.postId,
    this.crewId,
    this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.likeCount,
    this.liked,
    required this.imageUrls,
    required this.comments,
  });

  factory PostDetailDto.fromJson(Map<String, dynamic> j) => PostDetailDto(
    postId: j['postId'] ?? 0,
    crewId: j['crewId'],
    authorId: j['authorId'],
    authorName: j['authorName'] ?? '',
    title: j['title'] ?? '',
    content: j['content'] ?? '',
    likeCount: j['likeCount'] ?? 0,
    liked: j['liked'],
    imageUrls: (j['imageUrls'] as List?)?.map((e) => '$e').toList() ?? [],
    comments:
        (j['comments'] as List?)
            ?.map((e) => PostComment.fromJson(e))
            .toList() ??
        [],
  );
}

class PostDetailArgs {
  final int postId;
  final String? title;
  final String? author;
  final String? dateString;
  final String? content;
  final int likeCountInitial;

  const PostDetailArgs({
    required this.postId,
    this.title,
    this.author,
    this.dateString,
    this.content,
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
  bool _liking = false;

  final _commentCtl = TextEditingController();

  PostDetailDto? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _likes = widget.args.likeCountInitial;
    _fetchPost();
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_liking || _loading) return;
    _liking = true;

    final prevLiked = _liked;
    final prevLikes = _likes;

    // 낙관적 업데이트
    setState(() {
      _liked = !prevLiked;
      _likes += _liked ? 1 : -1;
    });

    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse(
        '$baseUrl/api/community/posts/${widget.args.postId}/like',
      );

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          // 'Accept': 'application/json', // 필요시
        },
      );

      // ignore: avoid_print
      print('LIKE TOGGLE BODY: ${res.body}');

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        // 서버가 최종 상태를 내려줌 → 그 값으로 동기화
        final bool liked = body['liked'] == true;
        final int likeCount = (body['likeCount'] ?? _likes) as int;

        if (!mounted) return;
        setState(() {
          _liked = liked;
          _likes = likeCount;
        });
      } else {
        // 실패 → 원복
        if (!mounted) return;
        setState(() {
          _liked = prevLiked;
          _likes = prevLikes;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 실패: ${res.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _liked = prevLiked;
        _likes = prevLikes;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    } finally {
      _liking = false;
    }
  }

  Future<void> _fetchPost() async {
    try {
      final token = await TokenStorage.getToken(); // ★ 토큰
      final uri = Uri.parse(
        '$baseUrl/api/community/posts/${widget.args.postId}',
      );
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      // 디버그: 응답 바디 출력
      // ignore: avoid_print
      print('POST DETAIL BODY: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final dto = PostDetailDto.fromJson(data);
        if (!mounted) return;
        setState(() {
          _post = dto;
          _likes = dto.likeCount;
          _liked = dto.liked ?? false;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('불러오기 실패: ${res.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dto = _post;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8),
      appBar: AppBar(
        title: const Text('게시물'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9E8),
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : dto == null
            ? const Center(child: Text('게시물을 찾을 수 없습니다'))
            : Column(
                children: [
                  // 상단 카드
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
                        Text(
                          dto.title.isNotEmpty
                              ? dto.title
                              : (widget.args.title ?? ''),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dto.authorName.isNotEmpty
                              ? dto.authorName
                              : (widget.args.author ?? ''),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if ((widget.args.dateString ?? '').isNotEmpty)
                          Text(
                            widget.args.dateString!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 8),
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

                  // 이미지 섹션
                  if (dto.imageUrls.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      padding: const EdgeInsets.all(12),
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
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dto.imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final url = dto.imageUrls[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // 본문
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 200),
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
                      (dto.content.isNotEmpty
                              ? dto.content
                              : (widget.args.content ?? ''))
                          .toString(),
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),

                  // 댓글 리스트 (서버에서 온 것만 표시)
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
                      child: dto.comments.isEmpty
                          ? Center(
                              child: Text(
                                '아직 댓글이 없어요',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.separated(
                              itemCount: dto.comments.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 16, thickness: 1),
                              itemBuilder: (context, i) {
                                final c = dto.comments[i];
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
                                        '${c.userName}: ${c.content}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),

                  // 댓글 입력창 (UI만, 전송 X)
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
                            readOnly: true, // 아직 백엔드 미연결이므로 입력만 막아둠(원하면 제거)
                            decoration: const InputDecoration(
                              hintText: '댓글 작성은 곧 연결될 예정입니다',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('댓글 작성 API 준비 중입니다'),
                              ),
                            );
                          },
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
