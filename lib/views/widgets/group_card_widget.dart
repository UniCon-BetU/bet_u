import 'package:bet_u/models/group.dart';
import 'package:flutter/material.dart';

/// 재사용 가능한 그룹 카드 (그룹 찾기 페이지에서도 재사용)
class GroupCardWidget extends StatelessWidget {
  final GroupInfo group;
  final VoidCallback? onTap;

  const GroupCardWidget({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF30B14A);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(color: accent.withValues(alpha: 0.12), width: 1),
        ),
        child: Row(
          children: [
            // 아이콘 배지
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(group.icon, color: accent, size: 26),
            ),
            const SizedBox(width: 12),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 멤버 수
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
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
