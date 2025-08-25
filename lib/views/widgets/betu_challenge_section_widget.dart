// lib/views/widgets/betu_challenge_section_widget.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/challenge.dart';
import '../../theme/app_colors.dart';
import '../widgets/challenge_tile_widget.dart';
import '../pages/betu_challenges_page.dart';

class BetuChallengeSectionWidget extends StatelessWidget {
  const BetuChallengeSectionWidget({
    super.key,
    required this.allChallenges,
    this.title = 'BETU Challenges',
    this.leadingIcon = const Icon(Icons.eco, color: AppColors.primaryGreen),
    this.cardBackground = AppColors.lighterGreen,
    this.itemsPerPage = 3,
    this.onTileTap,
  });

  /// (보통 betuChallenges)
  final List<Challenge> allChallenges;

  final String title;
  final Widget leadingIcon;
  final Color cardBackground;
  final int itemsPerPage;

  /// 카드 탭 시 실행. (null이면 ChallengeTileWidget의 기본 네비 동작)
  final void Function(Challenge challenge)? onTileTap;

  @override
  Widget build(BuildContext context) {
    // 원 코드: top9 (= itemsPerPage * 3)
    final top = allChallenges.take(itemsPerPage * 3).toList();
    final chunked = _chunk(top, itemsPerPage);
    final pageController = PageController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
          InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () {
              final betuOnly = allChallenges.where((c) => c.type == 'betu').toList();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BetuChallengesPage(betuChallenges: betuOnly),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    leadingIcon,
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
              ],
            ),
        ),
        const SizedBox(height: 6),

        // 3개 세로 PageView
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: chunked.length,
            itemBuilder: (context, pageIndex) {
              final pageItems = chunked[pageIndex];
              return Column(
                children: pageItems.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ChallengeTileWidget(
                      background: cardBackground,
                      c: c,
                      showTags: false,
                      onTap: onTileTap == null ? null : () => onTileTap!(c),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: chunked.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: AppColors.yellowGreen,
              dotColor: AppColors.darkerGray,
            ),
          ),
        ),
      ],
    );
  }

  List<List<Challenge>> _chunk(List<Challenge> list, int size) {
    final chunks = <List<Challenge>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
}
