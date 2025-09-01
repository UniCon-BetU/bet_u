import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bet_u/theme/app_colors.dart';

class BoardPost {
  final String title;
  final DateTime createdAt;
  final int likeCount;
  const BoardPost({
    required this.title,
    required this.createdAt,
    required this.likeCount,
  });
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

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: onMore ?? () {},
            child: Container(
              width: double.infinity, // ← 전체 폭
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.lightYellowGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
                  height: 200,
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
        ),
      ],
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
    final df = DateFormat('M/d hh:mm');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null ? null : () => onTap!(post),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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

            const SizedBox(width: 6),
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.primaryRed, size: 12),
                SizedBox(width: 2),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
