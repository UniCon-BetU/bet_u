import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';

import '../challenge_tab/challenge_detail_page.dart';

class MyChallengePage extends StatelessWidget {
  final List<Challenge> myChallenges; // 👈 필드 선언

  const MyChallengePage({
    super.key,
    required this.myChallenges, // 👈 생성자에서 필드에 저장
  });

  @override
  Widget build(BuildContext context) {
    // 이제 외부에서 넘겨준 myChallenges를 활용
    final inProgress = myChallenges
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('진행 중 챌린지')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: inProgress.isEmpty
            ? const Center(
                child: Text(
                  '진행 중인 글로벌 챌린지가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.separated(
                itemCount: inProgress.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final challenge = inProgress[index];
                  return ChallengeTileWidget(
                    c: challenge,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChallengeDetailPage(challenge: challenge),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
