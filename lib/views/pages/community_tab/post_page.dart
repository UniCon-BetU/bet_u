// lib/views/pages/post_page.dart
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/community_tab/post_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://54.180.150.39.nip.io';

/// ------------------------------
/// API 모델
/// ------------------------------
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
  final int likeCount; // 서버 키: postLikeCnt(우선) or likeCount(백업)
  final bool? liked;
  final List<String> imageUrls;
  final List<PostComment> comments;
  final String? createdAt; // 서버가 내려주면 표시용

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
    this.createdAt,
  });

  factory PostDetailDto.fromJson(Map<String, dynamic> j) => PostDetailDto(
    postId: j['postId'] ?? 0,
    crewId: j['crewId'],
    authorId: j['authorId'],
    authorName: (j['authorName'] ?? j['author'] ?? j['userName'] ?? '')
        .toString(),
    title: (j['title'] ?? j['postTitle'] ?? '').toString(),
    content: (j['content'] ?? j['postContent'] ?? j['body'] ?? '').toString(),
    likeCount: (j['postLikeCnt'] ?? j['likeCount'] ?? 0) as int, // ★ 핵심
    liked: j['liked'] == true,
    imageUrls:
        (j['imageUrls'] as List?)?.map((e) => '$e').toList() ?? <String>[],
    comments: ((j['comments'] as List?) ?? (j['commentTree'] as List?) ?? [])
        .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: j['createdAt']?.toString(),
  );
}

/// ------------------------------
/// 라우트 인자
/// ------------------------------
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

/// ------------------------------
/// 상세 페이지
/// ------------------------------
class PostDetailPage extends StatefulWidget {
  final PostDetailArgs args;
  const PostDetailPage({super.key, required this.args});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // 좋아요 상태
  late int _likes;
  bool _liked = false;
  bool _liking = false;

  // 댓글 입력
  final _commentCtl = TextEditingController();
  bool _commenting = false;

  // 상세 데이터
  PostDetailDto? _post;
  bool _loading = true;
  String? _errorMessage;

  // 유저 체크 (작성자 판별/삭제권한)
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _likes = widget.args.likeCountInitial;
    _initUser();
    _fetchPost();
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  // 현재 로그인 사용자 id
  Future<void> _initUser() async {
    final uid = await TokenStorage.getUserId();
    if (!mounted) return;
    setState(() => _currentUserId = uid);
    // ignore: avoid_print
    print('현재 로그인 유저 ID: $_currentUserId');
  }

  /// ------------------------------
  /// 상세 조회
  /// GET /api/community/posts/{postId}
  /// ------------------------------
  Future<void> _fetchPost() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorage.getToken();
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

      if (res.statusCode == 200) {
        final data =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        // ignore: avoid_print
        print('POST DETAIL MAP: $data');

        final dto = PostDetailDto.fromJson(data);
        if (!mounted) return;
        setState(() {
          _post = dto;
          _likes = dto.likeCount; // ★ postLikeCnt에서 온 값
          _liked = dto.liked ?? false;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorMessage = '불러오기 실패: ${res.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = '오류: $e';
      });
    }
  }

  /// ------------------------------
  /// 좋아요 토글
  /// POST /api/community/posts/{postId}/like
  /// 응답: liked, postLikeCnt(우선) / likeCount(백업)
  /// ------------------------------
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
        },
      );

      // ignore: avoid_print
      print('LIKE TOGGLE BODY: ${res.body}');

      if (res.statusCode == 200) {
        final body =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final bool liked = body['liked'] == true;
        final int likeCount =
            (body['postLikeCnt'] ?? body['likeCount'] ?? _likes) as int; // ★
        if (!mounted) return;
        setState(() {
          _liked = liked;
          _likes = likeCount;
        });
      } else {
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

  /// ------------------------------
  /// 루트 댓글 작성  ✅ 변경됨
  /// POST /api/community/root
  /// body: { "postId": number, "content": string }
  /// 응답: 200 OK (예: 신규 commentId 정수)
  /// ------------------------------
  Future<void> _submitComment() async {
    if (_commenting || _loading) return;

    final text = _commentCtl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글 내용을 입력해 주세요')));
      return;
    }

    setState(() => _commenting = true);

    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse('$baseUrl/api/community/root'); // ★ 엔드포인트 변경

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: json.encode({'postId': widget.args.postId, 'content': text}),
      );

      // ignore: avoid_print
      print('COMMENT CREATE STATUS=${res.statusCode} BODY=${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        _commentCtl.clear();
        FocusScope.of(context).unfocus();
        await _fetchPost(); // 최신 댓글 목록 갱신
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('댓글이 등록되었습니다')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('댓글 등록 실패: ${res.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    } finally {
      if (mounted) setState(() => _commenting = false);
    }
  }

  /// ------------------------------
  /// 삭제
  /// DELETE /api/community/posts/{postId}
  /// ------------------------------
  Future<void> _deletePost() async {
    if (_post == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제하시겠어요?'),
        content: const Text('삭제 후에는 되돌릴 수 없어요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse('$baseUrl/api/community/posts/${_post!.postId}');

      final res = await http.delete(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시물이 삭제되었습니다')));
        Navigator.pop(context, 'deleted'); // 이전 화면에서 처리 가능
      } else {
        final body = res.body.isNotEmpty
            ? res.body
            : 'status ${res.statusCode}';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('삭제 실패: $body')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    }
  }

  /// 간단한 날짜 문자열 (ISO → yyyy-MM-dd HH:mm)
  String? _formatCreatedAt(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      String two(int v) => v.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostEditPage(
                      postId: _post!.postId,
                      initialTitle: _post!.title,
                      initialContent: _post!.content,
                    ),
                  ),
                );
                if (updated == true) {
                  _fetchPost();
                }
              } else if (value == 'delete') {
                await _deletePost();
              } else if (value == 'report') {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('신고하기 준비 중입니다')));
              }
            },
            itemBuilder: (context) {
              final isAuthor =
                  (_post?.authorId != null &&
                  _currentUserId != null &&
                  _post!.authorId == _currentUserId);

              if (isAuthor) {
                return const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('삭제'),
                      ],
                    ),
                  ),
                ];
              } else {
                return const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, size: 18),
                        SizedBox(width: 8),
                        Text('신고'),
                      ],
                    ),
                  ),
                ];
              }
            },
          ),
        ],
      ),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 28,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _fetchPost,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            : dto == null
            ? const Center(child: Text('게시물을 찾을 수 없습니다'))
            : RefreshIndicator(
                onRefresh: _fetchPost,
                child: Column(
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
                          // 제목
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

                          // 작성자 / 날짜
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dto.authorName.isNotEmpty
                                      ? dto.authorName
                                      : (widget.args.author ?? ''),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if ((dto.createdAt ??
                                      widget.args.dateString ??
                                      '')
                                  .isNotEmpty)
                                Text(
                                  _formatCreatedAt(dto.createdAt) ??
                                      widget.args.dateString!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          // 좋아요
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _toggleLike,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _liked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
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
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              readOnly: false,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: '댓글을 입력하세요',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _commenting ? null : _submitComment,
                            icon: _commenting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
