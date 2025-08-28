import 'package:flutter/material.dart';
import '/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import '../../theme/app_colors.dart';

class ChallengeSectionWidget extends StatefulWidget {
  final List<Challenge> items;
  final String title;

  const ChallengeSectionWidget({
    super.key,
    required this.items,
    this.title = 'MY CHALLENGE 🥇',
  });

  @override
  State<ChallengeSectionWidget> createState() => _ChallengeSectionWidgetState();
}

class _ChallengeSectionWidgetState extends State<ChallengeSectionWidget> {
  final _pc = PageController(viewportFraction: 1.0);
  int _page = 0;

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
    return Container(
      //margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),

          SizedBox(
            height: 240,
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 6,
                  ),
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
    );
  }
}
