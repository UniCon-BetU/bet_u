import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BoardPost {
  final String title;
  final DateTime createdAt;
  const BoardPost({required this.title, required this.createdAt});
}

/// 섹션 카드: 제목 + 게시물 리스트(최대 5개) + 더보기
class BoardSectionCard extends StatelessWidget {
  final String title;
  final List<BoardPost> posts;
  final void Function(BoardPost post)? onTap; // 게시물 클릭
  final VoidCallback? onMore; // 더보기 클릭

  const BoardSectionCard({
    super.key,
    required this.title,
    required this.posts,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = posts.length > 5 ? 5 : posts.length;

    return Container(
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
          // 헤더: 제목 - 더보기
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
                onTap: onMore ?? () {},
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
            SizedBox(
              height: 260,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleCount,
                separatorBuilder: (_, __) => Divider(
                  height: 16,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.15),
                ),
                itemBuilder: (context, i) =>
                    _BoardRow(post: posts[i], onTap: onTap),
              ),
            ),
        ],
      ),
    );
  }
}

/// 리스트 한 줄
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
