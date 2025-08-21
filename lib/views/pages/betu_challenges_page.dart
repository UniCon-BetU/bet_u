import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/views/widgets/betu_challenge_card_widget.dart';
import 'package:bet_u/views/widgets/challenge_card_widget.dart';

import 'package:bet_u/views/pages/challenge_detail_page.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BETU 제공 챌린지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/BETU_challenge_background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: widget.betuChallenges.length,
            itemBuilder: (context, index) {
              final challenge = widget.betuChallenges[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BetuChallengeCard(
                  challenge: challenge,
                  onTap: () {
                    // 카드 탭 시 동작 (선택 사항)
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
