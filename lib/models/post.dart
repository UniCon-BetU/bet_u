/// 커뮤니티 게시글 요약 모델
/// /api/community/posts 응답 매핑
class Post {
  final int postId;
  final int? crewId;
  final int? authorId;
  final String authorName;
  final String title;
  final String preview;
  final int likeCount;
  final int commentCount;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  Post({
    required this.postId,
    this.crewId,
    this.authorId,
    required this.authorName,
    required this.title,
    required this.preview,
    required this.likeCount,
    required this.commentCount,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> j) {
    DateTime? created;
    final rawCreated = j['createdAt'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      created = DateTime.tryParse(rawCreated);
    }

    return Post(
      postId: j['postId'] ?? 0,
      crewId: j['crewId'],
      authorId: j['authorId'],
      authorName: (j['authorName'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      preview: (j['preview'] ?? '').toString(),
      likeCount: j['likeCount'] ?? 0,
      commentCount: j['commentCount'] ?? 0,
      thumbnailUrl: j['thumbnailUrl']?.toString(),
      createdAt: created,
    );
  }
}
