import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/utils/number_extensions.dart';

class PostCard {
  final int postId;
  final String title;
  final String excerpt; // 내용 1줄
  final String author; // 게시자
  final int likes; // 좋아요 수
  final DateTime createdAt; // 작성 시각

  const PostCard({
    required this.postId,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.likes,
    required this.createdAt,
  });
}

class PostCardWidget extends StatelessWidget {
  final PostCard post;
  final VoidCallback? onTap;

  const PostCardWidget({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dfDate = DateFormat('M/d');
    final dfTime = DateFormat('HH:mm');

    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          // border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black, height: 1.05),
            ),
            const SizedBox(height: 2),
            // 내용 2줄
            Text(
              post.excerpt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.darkestGray, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            // 메타(작성자/좋아요/날짜+시간)
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    post.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.favorite, size: 16, color: AppColors.primaryRed),
                const SizedBox(width: 3),
                Text(
                  post.likes.comma,
                  style: TextStyle(fontSize: 12, color: AppColors.primaryRed),
                ),
                const SizedBox(width: 10),
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(
                  '${dfDate.format(post.createdAt)} ${dfTime.format(post.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
