import 'package:flutter/material.dart';

class RankingEntry {
  final String username;
  final int completed; // 완료한 챌린지 수
  final String? profileUrl; // 추후 이미지 넣을 때 사용 (지금은 아이콘으로 대체)

  const RankingEntry({
    required this.username,
    required this.completed,
    this.profileUrl,
  });
}

/// 그룹 랭킹 위젯 (상위 5명)
class RankingWidget extends StatelessWidget {
  final String title; // 섹션 제목 (예: 'RANKING')
  final List<RankingEntry> entries; // 랭킹 전체 목록(상위 5명까지만 노출)
  final void Function(RankingEntry entry)? onTap;

  const RankingWidget({
    super.key,
    required this.entries,
    this.title = 'RANKING',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 상위 5명만 노출
    final items = entries.length > 5 ? entries.sublist(0, 5) : entries;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                children: const [
                  Text(
                    'RANKING',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('🏆', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  '아직 랭킹 데이터가 없어요',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, i) {
                final entry = items[i];
                return _RankingRow(rank: i + 1, entry: entry, onTap: onTap);
              },
            ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int rank; // 1-based
  final RankingEntry entry;
  final void Function(RankingEntry entry)? onTap;

  const _RankingRow({required this.rank, required this.entry, this.onTap});

  Color _medalColor(int r) {
    switch (r) {
      case 1:
        return const Color(0xFFFFD700); // gold
      case 2:
        return const Color(0xFFC0C0C0); // silver
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final accent = _medalColor(rank);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null ? null : () => onTap!(entry),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // 상위 3명 배경 살짝 강조
          color: isTop3 ? accent.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(12),
          border: isTop3
              ? Border.all(color: accent.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // 등수 배지
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop3
                    ? accent.withValues(alpha: 0.18)
                    : Colors.grey.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isTop3 ? Colors.black87 : Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 프로필 (아이콘 플레이스홀더)
            CircleAvatar(
              radius: 16,
              backgroundColor: isTop3
                  ? accent.withValues(alpha: 0.22)
                  : Colors.grey.withValues(alpha: 0.18),
              child: Icon(
                Icons.person,
                size: 18,
                color: isTop3 ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 10),

            // 이름
            Expanded(
              child: Text(
                entry.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 완료한 챌린지 수
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 18,
                  color: isTop3 ? accent : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.completed}',
                  style: const TextStyle(
                    fontSize: 14,
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
