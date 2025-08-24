import 'package:flutter/material.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../models/challenge.dart';
import '../pages/challenge_detail_page.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';
import 'package:bet_u/views/pages/create_challenge_page.dart';

import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_colors.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class BetuChallengeSectionWidget extends StatefulWidget {
  final List<Challenge> items;

  const BetuChallengeSectionWidget({
    super.key,
    required this.items,
  });

  @override
  State<BetuChallengeSectionWidget> createState() => _BetuChallengeSectionWidgetState();
}

class _BetuChallengeSectionWidgetState extends State<BetuChallengeSectionWidget> {
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
    final top9Challenges = betuChallenges.take(9).toList();
    final PageController pageController = PageController();
    List<List<Challenge>> chunkedChallenges = [];

    for (int i = 0; i < top9Challenges.length; i += 3) {
      chunkedChallenges.add(
        top9Challenges.sublist(
          i,
          i + 3 > top9Challenges.length ? top9Challenges.length : i + 3,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24), // 위/아래 간격 넓히고 좌측 여유 추가
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () {
              final betuOnlyChallenges =
                  betuChallenges.where((c) => c.type == 'betu').toList();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BetuChallengesPage(
                    betuChallenges: betuOnlyChallenges,
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'BETU Challenges',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6), // 아이콘과 텍스트 사이 간격 넓힘
                    Icon(Icons.eco, color: AppColors.primaryGreen),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
              ],
            ),
          ),
        ),

        // 페이지 뷰
        SizedBox(
          height: 165, // 카드 3개 세로로 들어갈 높이
          child: PageView.builder(
            controller: pageController,
            itemCount: chunkedChallenges.length,
            itemBuilder: (context, pageIndex) {
              return Column(
                children: chunkedChallenges[pageIndex]
                    .map(
                      (challenge) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ChallengeTileWidget(
                          background: AppColors.lighterGreen,
                          c: challenge,
                          showTags: false,
                          onTap: () => _goToProcessingPage(
                            challenge,
                            fromSearch: _isSearching,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // . . . 점 인디케이터
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: chunkedChallenges.length,
            effect: WormEffect(
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
}