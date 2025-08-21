import 'package:flutter/material.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({Key? key}) : super(key: key);

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final TextEditingController _searchController = TextEditingController();

  // 하단 네비게이션 현재 탭 (챌린지 활성화)
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Title',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 16)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/BETU_challenge_background.jpg"),
            fit: BoxFit.cover, // 화면 전체 꽉 채우기
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // 상단 프롬프트 메시지
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'This is a prompt message.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),

              // 검색바
              _SearchBar(
                controller: _searchController,
                hintText: 'Search',
                onSubmitted: (q) {
                  // TODO: 검색 제출 동작
                },
              ),
              const SizedBox(height: 16),

              // 섹션 타이틀
              const Text(
                'BETU 제공 챌린지 모아보기 🥬',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // 카드들
              ChallengeCard(
                title: '매일 아침 7시 기상  |  수능을 위한 미라클 모닝',
                participants: '2,686',
                periodText: '30 Days',
                tags: const ['#수능', '#생활습관', '#기상'],
                bannerLines: const [
                  '챌린지 제공 기간: 7/16 ~ 11/13 (마지막 참여 10/13) ',
                  '수능 D-120, ‘수능 시간표’에 패턴을 맞히려는 수험생들을 위한 기상 챌린지!',
                ],
                onTap: () {
                  // TODO: 카드 탭 시 상세 이동
                },
              ),
              const SizedBox(height: 12),

              ChallengeCard(
                title: '가을 학기 대학 학점 4.0 도전!',
                participants: '2,686',
                periodText: '목표 달성 챌린지',
                tags: const ['#수능', '#생활습관', '#기상'],
                bannerLines: const [
                  '챌린지 제공 기간: 9/1 ~ 12/31',
                  '위처럼 간략한 챌린지 설명이 들어갈 공간입니다. ',
                ],
                onTap: () {},
              ),
              const SizedBox(height: 12),

              ChallengeCard(
                title: '휴대폰 보기를 돌 같이 하라  |  스크린타임 인증 챌린지',
                participants: '2,686',
                periodText: '14 Days',
                tags: const ['#수능', '#생활습관', '#기상'],
                bannerLines: const [
                  '챌린지 제공 기간: 상시',
                  '위처럼 간략한 챌린지 설명이 들어갈 공간입니다. ',
                ],
                onTap: () {},
              ),
              const SizedBox(height: 12),

              ChallengeCard(
                title: '챌린지 이름',
                participants: '2,686',
                periodText: '챌린지 기간',
                tags: const ['#수능', '#생활습관', '#기상'],
                bannerLines: const [
                  '챌린지 제공 기간: 상시',
                  '위처럼 간략한 챌린지 설명이 들어갈 공간입니다. ',
                ],
                onTap: () {},
              ),
              const SizedBox(height: 12),

              ChallengeCard(
                title: '휴대폰 보기를 돌 같이 하라  |  스크린타임 인증 챌린지',
                participants: '2,686',
                periodText: '14 Days',
                tags: const ['#수능', '#생활습관', '#기상'],
                bannerLines: const [
                  '챌린지 제공 기간: 상시',
                  '위처럼 간략한 챌린지 설명이 들어갈 공간입니다. ',
                ],
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      // 우측 상단 플러스(생성) 버튼 느낌을 살리고 싶으면 FAB 사용도 OK
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 실제 "챌린지 생성 폼" 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _CreateFormPage()),
          );
        },
        label: const Text('새 챌린지 만들기'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1BAB0F),
      ),

      // 하단 네비게이션 (홈/챌린지/소셜/마이페이지)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // TODO: 각 탭 이동
        },
        selectedItemColor: const Color(0xFF1BAB0F),
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: '챌린지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: '소셜',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '마이페이지',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// 검색바 위젯 (상단 Search 섹션 대응)
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;

  const _SearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6FFE9),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.search, size: 20, color: Color(0xFF3C3C43)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.mic_none,
                size: 20,
                color: Color(0xFF3C3C43),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// 챌린지 카드 (상단 라이트 패널 + 하단 그린 배너 2단 구성)
class ChallengeCard extends StatelessWidget {
  final String title;
  final String participants;
  final String periodText; // "30 Days", "목표 달성 챌린지" 등
  final List<String> tags;
  final List<String> bannerLines; // 그린 배너 텍스트 2줄
  final VoidCallback? onTap;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.participants,
    required this.periodText,
    required this.tags,
    required this.bannerLines,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1BAB0F);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단(밝은 배경)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF6FFE9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 참여자 / 기간
                        Row(
                          children: [
                            _miniStat(
                              icon: Icons.groups_2_outlined,
                              text: participants,
                            ),
                            const SizedBox(width: 12),
                            _miniStat(
                              icon: Icons.schedule_outlined,
                              text: periodText,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        // 태그
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags
                              .map(
                                (t) => Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  // 썸네일 (옵션)
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8F6D1)),
                    ),
                    child: const Icon(Icons.eco, color: green),
                  ),
                ],
              ),
            ),

            // 하단(그린 배너)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: green,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in bannerLines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF646464)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF646464)),
        ),
      ],
    );
  }
}

/// 실제 생성 폼(더미) - 플로팅 버튼 눌렀을 때 열리는 페이지
class _CreateFormPage extends StatelessWidget {
  const _CreateFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF1BAB0F);
    return Scaffold(
      appBar: AppBar(title: const Text('새 챌린지 만들기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '챌린지 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '챌린지 설명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: '기간(예: 30 Days / 목표 달성 챌린지)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: 생성 로직
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('생성하기'),
                style: ElevatedButton.styleFrom(backgroundColor: green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
