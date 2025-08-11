import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/pages/post_page.dart';
import 'package:bet_u/views/widgets/challenge_section_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/board_widget.dart'; // BoardPost, BoardSectionCard
import '../widgets/group_card_widget.dart'; // GroupInfo (이 타입을 전달받음)
// (상세 게시글 페이지 연결하려면) import '../pages/post_page.dart';

final List<Challenge> groupChallenges = [
  Challenge(
    title: '매일 아침 6시 기상',
    participants: 42,
    day: 5,
    status: ChallengeStatus.inProgress,
  ),
  Challenge(
    title: '주 3회 러닝 5km',
    participants: 31,
    day: 14,
    status: ChallengeStatus.done,
  ),
  Challenge(
    title: '매일 1시간 독서',
    participants: 58,
    day: 7,
    status: ChallengeStatus.inProgress,
  ),
  Challenge(
    title: '하루 물 2L 마시기',
    participants: 26,
    day: 3,
    status: ChallengeStatus.missed,
  ),
  Challenge(
    title: '하루 영어 단어 30개 암기',
    participants: 44,
    day: 10,
    status: ChallengeStatus.inProgress,
  ),
];

class GroupPage extends StatelessWidget {
  final GroupInfo group; // 그룹 카드에서 넘겨받는 정보

  const GroupPage({super.key, required this.group});

  // TODO: 실제 데이터 연결 전 임시 더미
  List<BoardPost> get _dummyPosts => [
    BoardPost(title: '그룹 공지: 이번 주 일정 안내', createdAt: DateTime(2025, 8, 9)),
    BoardPost(title: '신규 멤버 환영합니다 👋', createdAt: DateTime(2025, 8, 8)),
    BoardPost(title: '주간 러닝 인증 스레드', createdAt: DateTime(2025, 8, 7)),
    BoardPost(title: '장비 추천 토론', createdAt: DateTime(2025, 8, 6)),
    BoardPost(title: '첫 모임 회고', createdAt: DateTime(2025, 8, 5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9E8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            BoardSectionCard(
              title: '그룹 게시판',
              posts: _dummyPosts,
              onTap: (post) {
                // TODO: 그룹 게시글 상세로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      args: PostDetailArgs(
                        title: post.title,
                        author: group.name, // 예시
                        dateString: '2025.08.09', // DateFormat으로 변환해서 전달
                        content: '본문 내용 예시',
                        likeCountInitial: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0),
            ChallengeSectionWidget(
              title: '그룹 챌린지 🧩',
              items: groupChallenges, // 그룹에 속한 Challenge 리스트
            ),
          ],
        ),
      ),
    );
  }
}
