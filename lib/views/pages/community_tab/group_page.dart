import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/models/group.dart';
import 'package:bet_u/views/pages/community_tab/board_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:bet_u/views/widgets/challenge_section_widget.dart';
import 'package:bet_u/views/widgets/postcard_widget.dart';
import 'package:bet_u/views/widgets/ranking_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/board_widget.dart'; // BoardPost, BoardSectionCard
// (상세 게시글 페이지 연결하려면) import '../pages/post_page.dart';

final List<Challenge> groupChallenges = [
  Challenge(
    title: 'EBS 모의고사 5회차 풀기',
    participants: 42,
    day: 5,
    status: ChallengeStatus.notStarted,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
  ),
  Challenge(
    title: '매일 수학 N제 20개 풀이',
    participants: 31,
    day: 14,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
    type: 'time',
  ),
  Challenge(
    title: '매일 영단어 30개',
    participants: 58,
    day: 7,
    status: ChallengeStatus.notStarted,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
    type: 'time',
  ),
  Challenge(
    title: '하루 물 2L 마시기',
    participants: 26,
    day: 3,
    status: ChallengeStatus.missed,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
  ),
  Challenge(
    title: '하루 영어 단어 30개 암기',
    participants: 44,
    day: 10,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
  ),
];

final demoRanking = const [
  RankingEntry(username: '김철수', completed: 27),
  RankingEntry(username: '아름이', completed: 24),
  RankingEntry(username: '나는민수', completed: 22),
  RankingEntry(username: '대구정시파이터', completed: 19),
  RankingEntry(username: '고연오', completed: 17),
];

class GroupPage extends StatelessWidget {
  final GroupInfo group; // 그룹 카드에서 넘겨받는 정보

  const GroupPage({super.key, required this.group});

  // TODO: 실제 데이터 연결 전 임시 더미
  List<BoardPost> get _dummyPosts => [
    BoardPost(title: '그룹 공지: 인증 규칙 안내', createdAt: DateTime(2025, 8, 9)),
    BoardPost(title: '신규 멤버 환영합니다 👋', createdAt: DateTime(2025, 8, 8)),
    BoardPost(title: '이번 회차 모의고사 잘 보셨나요', createdAt: DateTime(2025, 8, 7)),
    BoardPost(title: '수학 N제 추천', createdAt: DateTime(2025, 8, 6)),
    BoardPost(title: '챌린지 인증하고 돈 버는 꿀팁', createdAt: DateTime(2025, 8, 5)),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostDetailPage(args: PostDetailArgs(postId: 5)),
                  ),
                );
              },
              onMore: () {
                final cards = _dummyPosts
                    .map(
                      (b) => PostCard(
                        title: b.title,
                        excerpt: '내용 미리보기 예시입니다.',
                        author: group.name,
                        likes: 0,
                        createdAt: b.createdAt,
                      ),
                    )
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BoardPage(title: '${group.name} 게시판', posts: cards),
                  ),
                );
              },
            ),

            const SizedBox(height: 20.0),
            ChallengeSectionWidget(
              title: '그룹 챌린지 🧩',
              items: groupChallenges, // 그룹에 속한 Challenge 리스트
            ),
            SizedBox(height: 10.0),
            RankingWidget(
              entries: demoRanking,
              title: '랭킹',
              onTap: (e) {
                // TODO: 사용자 프로필/상세로 이동
              },
            ),
          ],
        ),
      ),
    );
  }
}
