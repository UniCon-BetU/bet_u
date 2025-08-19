import 'package:bet_u/views/pages/community_tab/board_page.dart';
import 'package:bet_u/views/pages/community_tab/group_create_page.dart';
import 'package:bet_u/views/pages/community_tab/group_find_page.dart';
import 'package:bet_u/views/pages/community_tab/group_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:bet_u/views/widgets/postcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/board_widget.dart';
import '../../widgets/group_dashboard_widget.dart';
import '../../widgets/group_card_widget.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  List<BoardPost> get _dummy => [
    BoardPost(title: '수능 국어 1일 3지문 팁 공유합니다', createdAt: DateTime(2025, 8, 8)),
    BoardPost(title: '영어 단어장 추천 부탁!', createdAt: DateTime(2025, 8, 7)),
    BoardPost(title: '힘들 때 보면 좋은 글', createdAt: DateTime(2025, 8, 6)),
    BoardPost(title: '요즘 토익 시험 특징', createdAt: DateTime(2025, 8, 5)),
    BoardPost(title: '이 챌린지 성공하신 분 있나요?', createdAt: DateTime(2025, 8, 5)),
  ];

  final myGroups = <GroupInfo>[
    const GroupInfo(
      name: '팀 수능',
      description: '함께해요 정시 파이터들',
      memberCount: 124,
      icon: Icons.book_outlined,
      accent: Color(0xFF30B14A),
    ),
    const GroupInfo(
      name: '영어 스터디',
      description: '토익/토플 같이 준비해요',
      memberCount: 58,
      icon: Icons.translate,
    ),
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
              onTap: (post) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      args: PostDetailArgs(
                        title: post.title,
                        author: '관리자',
                        dateString: DateFormat(
                          'yyyy.MM.dd',
                        ).format(post.createdAt),
                        content: '게시물 본문 내용 예시입니다.',
                        likeCountInitial: 12,
                      ),
                    ),
                  ),
                );
              },
              onMore: () {
                final cards = _dummy
                    .map(
                      (b) => PostCard(
                        title: b.title,
                        excerpt: '내용 미리보기 예시입니다.',
                        author: '관리자',
                        likes: 0,
                        createdAt: b.createdAt,
                      ),
                    )
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoardPage(title: '일반 게시판', posts: cards),
                  ),
                );
              },
            ),

            SizedBox(height: 20.0),
            GroupDashboardWidget(
              groups: myGroups, // []면 빈 상태 문구 출력
              onTapDiscover: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GroupFindPage()),
                );
              },
              onTapCreate: () {
                /* 그룹 생성 페이지로 이동 */
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GroupCreatePage()),
                );
              },
              onTapGroup: (g) {
                /* 그룹 상세 페이지로 이동 */
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => GroupPage(group: g)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
