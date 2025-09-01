import 'package:flutter/material.dart';
import '/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import '../../theme/app_colors.dart';

import 'package:bet_u/services/my_challenge_loader.dart';
import 'package:bet_u/data/my_challenges.dart';

class ChallengeSectionWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onSectionTap;

  /// 눌렀을 때 축소 비율 (예: 0.97)
  final double pressedScale;
  /// 프레스 애니메이션 시간
  final Duration pressedAnimDuration;

  const ChallengeSectionWidget({
    super.key,
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

  @override
  void initState() {
    super.initState();
    MyChallengeLoader.loadAndPublish(context: context); // 위젯 생성 시 API 호출
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  List<List<Challenge>> _chunk(List<Challenge> src) {
    final chunk = <List<Challenge>>[];
    for (var i = 0; i < src.length; i += 3) {
      chunk.add(src.sublist(i, (i + 3).clamp(0, src.length)));
    }
    return chunk.isEmpty ? [[]] : chunk;
  }

  Widget _buildBody(List<Challenge> items) {
    if (MyChallengeLoader.isLoading && items.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _chunk(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          SizedBox(
            height: 210,
            child: Center(
              child: Text(
                '진행 중인 챌린지가 없습니다.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pc,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, idx) => Column(
                children: pages[idx]
                    .map((c) => ChallengeTileWidget(c: c, showTags: false))
                    .toList(),
              ),
            ),
          ),

        const SizedBox(height: 4),
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
                  color: active ? AppColors.primaryGreen : AppColors.gray,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onSectionTap,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: AnimatedScale(
                scale: _pressed ? widget.pressedScale : 1.0,
                duration: widget.pressedAnimDuration,
                alignment: Alignment.center,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<List<Challenge>>(
                        valueListenable: myChallengesNotifier,
                        builder: (_, items, _) => _buildBody(items),
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
