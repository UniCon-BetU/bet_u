import 'package:bet_u/views/widgets/challenge_card_group.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/global_challenges.dart';
import 'package:bet_u/views/pages/challenge.dart';
import 'processing_challenge_detail_page.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CreateChallengePage extends StatelessWidget {
  const CreateChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('챌린지 만들기')),
      body: const Center(child: Text('여기는 챌린지 생성 페이지입니다.')),
    );
  }
}

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

int getDaysLeft(Challenge challenge) {
  final now = DateTime.now();
  final startDate = challenge.createdAt;
  final endDate = startDate.add(Duration(days: challenge.day));
  final diff = endDate.difference(now).inDays;
  return diff >= 0 ? diff : 0;
}

class _ChallengePageState extends State<ChallengePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = '전체';
  String selectedTab = '인기';
  bool _isSearching = false;

  List<String> categories = [
    '전체',
    '수능',
    '토익',
    '공무원/행시',
    '회계사',
    'LEET',
    '자격증',
    '자기계발',
  ];
  List<String> recentSearches = [];

  List<Challenge> get filteredChallenges {
    return betuChallenges.where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addRecentSearch(String query) {
    if (query.isEmpty) return;
    if (!recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
        if (recentSearches.length > 5) recentSearches.removeLast();
      });
    }
  }

  String getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.inProgress:
        return '진행중';
      case ChallengeStatus.done:
        return '완료';
      case ChallengeStatus.missed:
        return '미참여';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('챌린지')),
      body: _isSearching
          ? Column(
              children: [
                buildSearchAndCreateRow(),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: filteredChallenges
                        .map((challenge) => buildChallengeCard(challenge))
                        .toList(),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSearchAndCreateRow(),
                  const SizedBox(height: 12),

                  if (_searchController.text.isEmpty &&
                      recentSearches.isNotEmpty)
                    buildRecentSearchChips(),
                  const SizedBox(height: 12),

                  buildCategoryGridWithBackground(),
                  const SizedBox(height: 12),

                  buildPresentedByVertical(), // 배추 챌린지 3개
                  const SizedBox(height: 12),

                  buildChallengeTabs(), // ✅ 여기로 옮김
                  const SizedBox(height: 12),

                  ...filteredChallenges.map(
                    (challenge) => buildChallengeCard(challenge),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildSearchAndCreateRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                width: _isSearching ? MediaQuery.of(context).size.width : null,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/normal_lettuce.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: _isSearching,
                        onTap: () {
                          setState(() {
                            _isSearching = true; // 클릭 시 검색 모드 ON
                          });
                        },
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '문제풀이  #수능  ...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            if (!_isSearching) const SizedBox(width: 8),
            if (!_isSearching)
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.create, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateChallengePage(),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        if (_isSearching)
          if (_isSearching)
            SizedBox(
              height: 40, // Chip 높이에 맞춤
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(categories[index]),
                      backgroundColor: Colors.green.shade100,
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget buildRecentSearchChips() {
    return Wrap(
      spacing: 8,
      children: recentSearches
          .map(
            (e) => GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.text = e;
                });
              },
              child: Chip(label: Text(e)),
            ),
          )
          .toList(),
    );
  }

  Widget buildCategoryGridWithBackground() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50, // 연한 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected
                      ? Colors.green
                      : Colors.green.shade100, // 조금 연하게
                  radius: 24,
                  child: Icon(
                    Icons.school,
                    color: isSelected ? Colors.white : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.green : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPresentedByVertical() {
    final top9Challenges = betuChallenges.take(9).toList();
    final PageController pageController = PageController();
    List<List<Challenge>> chunkedChallenges = [];
    final pages = (betuChallenges.length / 3).ceil();

    for (int i = 0; i < top9Challenges.length; i += 3) {
      chunkedChallenges.add(
        top9Challenges.sublist(
          i,
          i + 3 > top9Challenges.length ? top9Challenges.length : i + 3,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    'BETU Challenges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.eco, color: Colors.green),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          BetuChallengesPage(betuChallenges: betuChallenges),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 페이지 뷰
        SizedBox(
          height: 400, // 카드 3개 세로로 들어갈 높이
          child: PageView.builder(
            controller: pageController,
            itemCount: chunkedChallenges.length,
            itemBuilder: (context, pageIndex) {
              return Column(
                children: chunkedChallenges[pageIndex]
                    .map(
                      (challenge) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: buildChallengeCard(challenge, showTags: false),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // . . . 점 인디케이터
        Center(
          child: SmoothPageIndicator(
            controller: pageController,
            count: chunkedChallenges.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: const Color.fromARGB(255, 206, 244, 103),
              dotColor: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // 인기, 추천, 전체 탭
  Widget buildChallengeTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          buildTabItem('인기', isSelected: selectedTab == '인기'),
          const SizedBox(width: 16),
          buildTabItem('추천', isSelected: selectedTab == '추천'),
          const SizedBox(width: 16),
          buildTabItem(
            '전체',
            isSelected: selectedTab == '전체',
            hasDropdown: true,
          ),
        ],
      ),
    );
  }

  Widget buildTabItem(
    String label, {
    bool isSelected = false,
    bool hasDropdown = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18, // 좀 더 크게
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.black87,
            ),
          ),
          if (hasDropdown)
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }

  Widget buildChallengeCard(Challenge challenge, {bool showTags = true}) {
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
