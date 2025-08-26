import 'package:bet_u/data/global_challenges.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'images/BETU_challenge_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. 메인 컨텐츠
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 커스텀 앱바
                Stack(
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        'images/betu_upperbar.png',
                        width: double.infinity,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                // 제목// 제목
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'BETU 제공 챌린지 모아보기 🥬',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 그라데이션 위젯

                // 리스트뷰
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: widget.betuChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = widget.betuChallenges[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: BetuChallengeCard(
                          challenge: challenge,
                          afterPop: () {
                            setState(() {}); // DetailPage에서 돌아오면 화면 갱신
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. 하단 고정 아이콘
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'images/betu_bottom_icon.png',
              fit: BoxFit.cover,
              height: 180,
            ),
          ),
        ],
      ),
    );
  }
}
