import 'package:bet_u/models/group.dart';
import 'package:flutter/material.dart';
import 'group_card_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:bet_u/theme/app_colors.dart';

/// 내 그룹 대시보드: 상단 섹션 카드 + (그룹 리스트 or 빈 상태) + 하단 버튼 2개
class GroupDashboardWidget extends StatefulWidget {
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
  State<GroupDashboardWidget> createState() => _GroupDashboardWidgetState();
}

class _GroupDashboardWidgetState extends State<GroupDashboardWidget> {
  final PageController _pc = PageController();
  int _page = 0;

  // 리스트를 n개씩 청크로 자르기
  List<List<T>> _chunk<T>(List<T> list, int size) {
    if (list.isEmpty) return const [];
    final pages = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      pages.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    final pages = _chunk(groups, 3); // 한 페이지에 3개

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_HeaderLeft(), _HeaderRight()],
          ),
          const SizedBox(height: 12),

          // 컨텐츠: 그룹 리스트 or 빈 상태 문구
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  '아직 참여한 그룹이 없어요.',
                  style: TextStyle(color: AppColors.darkerGray, fontSize: 14),
                ),
              ),
            )
          else ...[
            // PageView: 3개씩 묶어 좌우 스와이프
            SizedBox(
              // 카드 높이(약 80~88) x 3 + 간격(=12 * 2) 여유로 240 정도
              height: 240,
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: _pc,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, idx) {
                  final pageItems = pages[idx];
                  return Column(
                    children: List.generate(pageItems.length, (i) {
                      final g = pageItems[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: i == pageItems.length - 1 ? 0 : 12),
                        child: GroupCardWidget(
                          group: g,
                          onTap: widget.onTapGroup == null ? null : () => widget.onTapGroup!(g),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            // 페이지 인디케이터
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    width: active ? 12 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryGreen : (AppColors.gray), // Gray 없으면 Colors.grey.shade400
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 하단 버튼 2개 (나란히)
          Row(
            children: [
              Expanded(
                child: LongButtonWidget(
                  text: '그룹 찾기',
                  fontsize: 16,
                  leading: const Icon(Icons.search),
                  onPressed: widget.onTapDiscover,
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LongButtonWidget(
                  text: '그룹 만들기',
                  textColor: Colors.black,
                  fontsize: 16,
                  leading: const Icon(Icons.add_circle_outline_rounded, color: Colors.black),
                  onPressed: widget.onTapCreate,
                  backgroundColor: Colors.white,
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
    return const Row(
      children: [
        Text(
          '내 그룹',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
