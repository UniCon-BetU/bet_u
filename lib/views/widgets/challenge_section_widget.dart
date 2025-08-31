import 'package:flutter/material.dart';
import '/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import '../../theme/app_colors.dart';

class ChallengeSectionWidget extends StatefulWidget {
  final List<Challenge> items;
  final String title;

  /// 섹션 전체 탭 동작
  final VoidCallback? onSectionTap;

  /// 눌렀을 때 축소 비율 (예: 0.97)
  final double pressedScale;

  /// 프레스 애니메이션 시간
  final Duration pressedAnimDuration;

  const ChallengeSectionWidget({
    super.key,
    required this.items,
    this.title = 'MY CHALLENGE 🥇',
    this.onSectionTap,
    this.pressedScale = 0.97,
    this.pressedAnimDuration = const Duration(milliseconds: 90),
  });

  @override
  State<ChallengeSectionWidget> createState() => _ChallengeSectionWidgetState();
}

class _ChallengeSectionWidgetState extends State<ChallengeSectionWidget> {
  final _pc = PageController(viewportFraction: 1.0);
  int _page = 0;
  bool _pressed = false;

  List<List<Challenge>> get _pages {
    final chunk = <List<Challenge>>[];
    for (var i = 0; i < widget.items.length; i += 3) {
      chunk.add(widget.items.sublist(i, (i + 3).clamp(0, widget.items.length)));
    }
    return chunk.isEmpty ? [[]] : chunk;
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11);

    return Padding(
      // 그림자가 잘리지 않도록 살짝 여백(필요 시 조절)
      padding: const EdgeInsets.all(0),
      child: DecoratedBox(
        // ← 그림자/배경은 "고정" 레이어
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000), // == Colors.black.withOpacity(0.25)
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          // 리플 클리핑
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onSectionTap,
              // 눌림 상태로 스케일 토글
              onHighlightChanged: (v) => setState(() => _pressed = v),

              // ✅ 내용만 스케일 (카드/그림자는 고정)
              child: AnimatedScale(
                scale: _pressed ? widget.pressedScale : 1.0,
                duration: widget.pressedAnimDuration,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          'MY CHALLENGE 🥇', // widget.title 써도 됨
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 210,
                        child: PageView.builder(
                          controller: _pc,
                          itemCount: _pages.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, idx) => Column(
                            children: _pages[idx]
                                .map((c) => ChallengeTileWidget(c: c, showTags: false))
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_pages.length, (i) {
                            final active = i == _page;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                              width: active ? 12 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active ? AppColors.primaryGreen : AppColors.Gray,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}