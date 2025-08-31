import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import '../../../data/global_challenges.dart'; // ValueNotifier 사용
import '../challenge_tab/challenge_detail_page.dart';

class ScrapPage extends StatelessWidget {
  const ScrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스크랩'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<List<Challenge>>(
        valueListenable: allChallengesNotifier, // <- reactive 전역 리스트
        builder: (context, allChallenges, _) {
          final scrapped = allChallenges.where((c) => c.isFavorite).toList();

          if (scrapped.isEmpty) {
            return const Center(
              child: Text(
                '스크랩한 챌린지가 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: scrapped.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final challenge = scrapped[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(challenge.title),
                  subtitle: Text(
                    '${challenge.participants}명 참가 · ${challenge.day}일',
                  ),
                  trailing: Icon(
                    Icons.bookmark,
                    color: challenge.status == ChallengeStatus.inProgress
                        ? Colors.red
                        : challenge.status == ChallengeStatus.notStarted
                        ? Colors.green
                        : Colors.blue,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChallengeDetailPage(challenge: challenge),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
