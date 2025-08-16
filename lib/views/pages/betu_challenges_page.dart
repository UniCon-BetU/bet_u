// lib/views/pages/betu_challenges_page.dart
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'processing_challenge_detail_page.dart';

class BetuChallengesPage extends StatelessWidget {
  final List<Challenge> betuChallenges;

  const BetuChallengesPage({super.key, required this.betuChallenges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BETU CHALLENGES'),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: betuChallenges.length,
              itemBuilder: (context, index) {
                final challenge = betuChallenges[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProcessingChallengeDetailPage(challenge: challenge),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 챌린지 제목
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 참여자 + 기간
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14),
                            const SizedBox(width: 4),
                            Text('${challenge.participants}'),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_today, size: 14),
                            const SizedBox(width: 4),
                            Text('${getDaysLeft(challenge)} Days'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 태그
                        Wrap(
                          spacing: 4,
                          children: challenge.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.green.shade50,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 하단 아이콘
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.eco, size: 40, color: Colors.green),
                SizedBox(width: 12),
                Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                SizedBox(width: 12),
                Icon(Icons.emoji_food_beverage, size: 40, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int getDaysLeft(Challenge challenge) {
    final now = DateTime.now();
    final startDate = challenge.createdAt;
    final endDate = startDate.add(Duration(days: challenge.day));
    final diff = endDate.difference(now).inDays;
    return diff >= 0 ? diff : 0;
  }
}
