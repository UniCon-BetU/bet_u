import 'package:flutter/material.dart';
import '../../data/global_challenges.dart'; // betuChallenges, Challenge 모델 포함
import 'package:bet_u/views/widgets/challenge_card_widget.dart'; // 우리가 만든 ChallengeCard 위젯

class SearchResultPage extends StatelessWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // 검색어 필터링
    final results = betuChallenges.where((c) {
      final lowerQuery = query.toLowerCase();
      final inTitle = c.title.toLowerCase().contains(lowerQuery);
      final inTag = c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      return inTitle || inTag;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과: "$query"'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: results.isEmpty
            ? Center(
                child: Text(
                  '"$query"에 대한 검색 결과가 없습니다.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final challenge = results[index];
                  return ChallengeCard(
                    challenge: challenge,
                    showTags: true, // 태그 보이게 할지 선택
                  );
                },
              ),
      ),
    );
  }
}
