import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/views/widgets/betu_challenge_card_widget.dart';

class BetuChallengesPage extends StatefulWidget {
  final List<Challenge> betuChallenges;

  const BetuChallengesPage({super.key, required this.betuChallenges});

  @override
  State<BetuChallengesPage> createState() => _BetuChallengesPageState();
}

class _BetuChallengesPageState extends State<BetuChallengesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white, // 흰색 배경
        elevation: 2, // 그림자 없애고 싶으면 0
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, // 기본 back 버튼 제거

        title: Stack(
          children: [
            Opacity(
              opacity: 0.9,
              child: Image.asset(
                'assets/images/betu_upperbar.png',
                width: double.infinity,
                height: kToolbarHeight, // AppBar 기본 높이
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. 화면 전체를 덮는 배경 이미지 (스크롤되지 않음)
          Positioned.fill(
            child: Image.asset(
              'assets/images/BETU_challenge_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. 스크롤 가능한 콘텐츠
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // 이미지 배너 (스크롤과 함께 움직임)
                SliverToBoxAdapter(
                  child: Image.asset(
                    'assets/images/betu_bottom_icon.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),

                // 카드 리스트
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final challenge = widget.betuChallenges[index];
                    // 카드 간격을 없앱니다.
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                      child: BetuChallengeCard(
                        challenge: challenge,
                        afterPop: () => setState(() {}),
                      ),
                    );
                  }, childCount: widget.betuChallenges.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
