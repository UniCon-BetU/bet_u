import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BoardPost {
  final String title;
  final DateTime createdAt;
  const BoardPost({required this.title, required this.createdAt});
}

/// 홈의 "My Challenges" 같은 큰 섹션 카드
class BoardSectionCard extends StatelessWidget {
  final String title; // 섹션 제목 (ex. '커뮤니티')
  final List<BoardPost> posts; // 게시물 리스트
  final void Function(BoardPost)? onTap;

  const BoardSectionCard({
    super.key,
    required this.title,
    required this.posts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('🗣️', style: TextStyle(fontSize: 14)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: 전체 게시판 페이지 이동
                },
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 리스트
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '아직 게시물이 없어요',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length > 5 ? 5 : posts.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, i) =>
                  _BoardRow(post: posts[i], onTap: onTap),
            ),
        ],
      ),
    );
  }
}

/// 섹션 안에 들어갈 한 줄짜리 게시물 행
class _BoardRow extends StatelessWidget {
  final BoardPost post;
  final void Function(BoardPost)? onTap;
  const _BoardRow({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('M/d');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null ? null : () => onTap!(post),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              df.format(post.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
