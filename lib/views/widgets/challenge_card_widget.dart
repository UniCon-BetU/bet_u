import 'package:bet_u/views/pages/processing_challenge_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool showTags;

  const ChallengeCard({Key? key, required this.challenge, this.showTags = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProcessingChallengeDetailPage(challenge: challenge),
          ),
        );
      },
      child: SizedBox(
        height: 100, // 카드 고정 높이
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // 왼쪽 정보 영역
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.participants}명',
                            style: const TextStyle(fontSize: 12, height: 1.0),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            challenge.type == 'time'
                                ? '${challenge.day}일'
                                : '목표 달성 챌린지',
                            style: const TextStyle(fontSize: 12, height: 1.0),
                          ),
                        ],
                      ),
                      if (showTags && challenge.tags.isNotEmpty)
                        const SizedBox(height: 4),
                      if (showTags && challenge.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: challenge.tags
                              .map(
                                (tag) => Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    height: 1.0,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                // 오른쪽 이미지
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(challenge.imageUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
