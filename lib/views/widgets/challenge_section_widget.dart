import 'package:flutter/material.dart';
import '/models/challenge.dart';
import 'challenge_tile_widget.dart';

class ChallengeSectionWidget extends StatefulWidget {
  final List<Challenge> items;
  final String title;

  const ChallengeSectionWidget({
    super.key,
    required this.items,
    this.title = '챌린지 목록 🥇',
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          SizedBox(
            height: 270,
            child: PageView.builder(
              controller: _pc,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, idx) => Column(
                children: _pages[idx]
                    .map((c) => ChallengeTileWidget(c: c))
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
                  width: active ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.grey[800] : Colors.grey[400],
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
