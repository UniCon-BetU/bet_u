import 'package:flutter/material.dart';
import 'group_card_widget.dart';

/// 내 그룹 대시보드: 상단 섹션 카드 + (그룹 리스트 or 빈 상태) + 하단 버튼 2개
class GroupDashboardWidget extends StatelessWidget {
  final List<GroupInfo> groups; // 내가 가입한 그룹들
  final VoidCallback? onTapDiscover; // '그룹 찾기' 버튼
  final VoidCallback? onTapCreate; // '그룹 만들기' 버튼
  final void Function(GroupInfo group)? onTapGroup;

  const GroupDashboardWidget({
    super.key,
    required this.groups,
    this.onTapDiscover,
    this.onTapCreate,
    this.onTapGroup,
  });

  @override
  Widget build(BuildContext context) {
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
            children: const [_HeaderLeft(), _HeaderRight()],
          ),
          const SizedBox(height: 12),

          // 컨텐츠: 그룹 리스트 or 빈 상태 문구
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  '아직 참여한 그룹이 없어요.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, i) => GroupCardWidget(
                group: groups[i],
                onTap: onTapGroup == null ? null : () => onTapGroup!(groups[i]),
              ),
            ),

          const SizedBox(height: 16),

          // 하단 버튼 2개 (나란히)
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onTapDiscover,
                  icon: const Icon(Icons.search),
                  label: const Text('그룹 찾기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF30B14A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTapCreate,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('그룹 만들기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderLeft extends StatelessWidget {
  const _HeaderLeft();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text(
          '내 그룹',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(width: 6),
        Text('👥', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _HeaderRight extends StatelessWidget {
  const _HeaderRight();

  @override
  Widget build(BuildContext context) {
    // 오른쪽 정렬용 빈 자리(필요 시 '더보기' 등 확장 가능)
    return const SizedBox.shrink();
  }
}
