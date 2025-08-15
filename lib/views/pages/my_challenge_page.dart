import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'challenge_detail_page.dart';

class MyChallengePage extends StatelessWidget {
  final List<Challenge> myChallenges;

  const MyChallengePage({super.key, required this.myChallenges});

  @override
  Widget build(BuildContext context) {
    // 진행중 챌린지만 필터링
    final inProgress = myChallenges
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('내 진행 중 챌린지')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: inProgress.isEmpty
            ? Center(child: Text('진행 중인 챌린지가 없습니다.'))
            : ListView.separated(
                itemCount: inProgress.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final challenge = inProgress[index];
                  return ListTile(
                    title: Text(challenge.title),
                    subtitle: Text(
                      '${challenge.participants}명 참가 · ${challenge.day}일',
                    ),
                    trailing: Text(
                      '진행 중',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChallengeDetailPage(
                            challenge: challenge,
                          ),
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
