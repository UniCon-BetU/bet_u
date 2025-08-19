import 'package:bet_u/views/pages/community_tab/group_info_page.dart';
import 'package:flutter/material.dart';
import '../../widgets/searchbar_widget.dart';
import '../../widgets/group_card_widget.dart';

class GroupFindPage extends StatefulWidget {
  const GroupFindPage({super.key});

  @override
  State<GroupFindPage> createState() => _GroupFindPageState();
}

class _GroupFindPageState extends State<GroupFindPage> {
  String _query = '';

  // 데모용 데이터 (실서비스에선 API/DB로 대체)
  final List<GroupInfo> _allGroups = const [
    GroupInfo(
      name: '아침기상 챌린지',
      description: '매일 6시에 일어나기',
      memberCount: 124,
      icon: Icons.wb_sunny,
    ),
    GroupInfo(
      name: '영어 스터디',
      description: '토익/토플 같이 공부해요',
      memberCount: 58,
      icon: Icons.translate,
    ),
    GroupInfo(
      name: '달리기 모임',
      description: '주 3회 러닝',
      memberCount: 92,
      icon: Icons.directions_run,
    ),
    GroupInfo(
      name: '독서 클럽',
      description: '한 달 한 권',
      memberCount: 41,
      icon: Icons.menu_book,
    ),
    GroupInfo(
      name: '코딩 인터뷰 준비',
      description: '알고리즘/CS 스터디',
      memberCount: 77,
      icon: Icons.code,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? _allGroups
        : _allGroups.where((g) => g.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8), // 홈 톤
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9E8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '그룹 찾기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // 검색창
          SearchBarWidget(
            hintText: '그룹 이름으로 검색',
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: (v) => setState(() => _query = v),
          ),

          // 결과 리스트
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        '검색 결과가 없어요',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      thickness: 1,
                      color: Colors.grey.withValues(alpha: 0.12),
                    ),
                    itemBuilder: (context, i) {
                      final g = results[i];
                      return GroupCardWidget(
                        group: g,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GroupInfoPage(
                                groupName: '영어 스터디',
                                nickname: '토익/토플',
                                createdDays: 16,
                                dailyCount: 68,
                                challengeCount: 17,
                                tags: const ['수능', '알고인증도', '국어'],
                                isPublic: false,
                                description:
                                    '매일 아침 6시에 일어나 30분 공부 인증하는 스터디입니다. 주중에는 회화, 주말에는 모의고사 풀이를 진행해요.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
