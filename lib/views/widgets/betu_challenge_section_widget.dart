// lib/views/widgets/betu_challenge_section_widget.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/challenge.dart';
import '../../theme/app_colors.dart';
import '../widgets/challenge_tile_widget.dart';
import '../pages/betu_challenges_page.dart';

/// 리스트를 지정한 크기로 잘라서 chunk 리스트 반환
List<List<Challenge>> _chunk(List<Challenge> list, int size) {
  List<List<Challenge>> chunks = [];
  for (var i = 0; i < list.length; i += size) {
    final end = (i + size < list.length) ? i + size : list.length;
    chunks.add(list.sublist(i, end));
  }
  return chunks;
}

class BetuChallengeSectionWidget extends StatelessWidget {
  const BetuChallengeSectionWidget({
    super.key,
    required this.challengeFrom,
    this.title = 'BETU Challenges',
    this.leadingIcon = const Icon(Icons.eco, color: AppColors.primaryGreen),
    this.cardBackground = AppColors.lightYellowGreen,
    this.itemsPerPage = 3,
    this.onTileTap,
  });

  /// (보통 betuChallenges)
  final List<Challenge> challengeFrom;

  final String title;
  final Widget leadingIcon;
  final Color cardBackground;
  final int itemsPerPage;

  /// 카드 탭 시 실행. (null이면 ChallengeTileWidget의 기본 네비 동작)
  final void Function(Challenge challenge)? onTileTap;

  @override
  Widget build(BuildContext context) {
    // BETU 제작 챌린지만 필터링
    final betuOnly = challengeFrom.where((c) => c.WhoMadeIt == 'BETU').toList();

    // BETU 없으면 안내 문구
    if (betuOnly.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'BETU 제작 챌린지가 없습니다.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    // PageView 구성 (BETU 리스트 기준)
    final top = betuOnly.take(itemsPerPage * 3).toList();
    final chunked = _chunk(top, itemsPerPage);
    final pageController = PageController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.eco, size: 24, color: AppColors.primaryGreen),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 24,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // PageView
        SizedBox(
          height: 224,
          child: PageView.builder(
            controller: pageController,
            itemCount: chunked.length,
            itemBuilder: (context, pageIndex) {
              final pageItems = chunked[pageIndex];
              return Column(
                children: pageItems.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
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

        const SizedBox(height: 12),
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
      chunks.add(
        list.sublist(i, i + size > list.length ? list.length : i + size),
      );
    }
    return chunks;
  }
}
