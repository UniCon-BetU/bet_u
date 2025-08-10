import 'package:flutter/material.dart';
import '../widgets/board_widget.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  List<BoardPost> get _dummy => [
    BoardPost(title: '수능 국어 1일 3지문 팁 공유합니다', createdAt: DateTime(2025, 8, 8)),
    BoardPost(title: '영어 단어장 추천 부탁!', createdAt: DateTime(2025, 8, 7)),
    BoardPost(title: '도전 인증 규칙 변경 안내', createdAt: DateTime(2025, 8, 6)),
    BoardPost(title: '오늘의 챌린지 후기', createdAt: DateTime(2025, 8, 5)),
    BoardPost(title: '오늘의 챌린지 후기', createdAt: DateTime(2025, 8, 5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8), // 홈과 같은 크림톤
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            BoardSectionCard(
              title: '일반 게시판',
              posts: _dummy,
              onTap: (p) {
                // TODO: 상세 페이지로 이동
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('열기: ${p.title}')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
