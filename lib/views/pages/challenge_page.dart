import 'package:bet_u/views/pages/search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/global_challenges.dart';
import '../../models/challenge.dart';
import 'challenge_detail_page.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  List<Challenge> get challengesToShow => getSortedChallenges();
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
  void _addRecentSearch(String title) {
    if (title.isEmpty) return;
    recentSearches.remove(title); // 중복 제거
    recentSearches.insert(0, title); // 맨 앞에 추가
    if (recentSearches.length > 5) recentSearches.removeLast(); // 최대 5개
  }

  List<String> recentSearches = [];
  List<Challenge> getSortedChallenges() {
    List<Challenge> sorted = List.from(betuChallenges);

    if (selectedTab == '인기') {
      // '인기' 탭: 참여자 순으로 정렬
      sorted.sort((a, b) => b.participants.compareTo(a.participants));
    } else if (selectedTab == '추천') {
      // '추천' 탭: 최근에 본 순서대로 정렬
      sorted.sort((a, b) {
        // recentSearches 리스트에서 각 챌린지의 순서(index)를 찾습니다.
        int aIndex = recentSearches.indexOf(a.title);
        int bIndex = recentSearches.indexOf(b.title);

        // 리스트에 없는 항목(index가 -1)은 맨 뒤로 보냅니다.
        if (aIndex == -1) aIndex = recentSearches.length;
        if (bIndex == -1) bIndex = recentSearches.length;

        // index가 작을수록(더 최신일수록) 앞으로 오도록 정렬합니다.
        return aIndex.compareTo(bIndex);
      });
    }
    return sorted;
  }

  List<Challenge> get filteredChallenges {
    return getSortedChallenges().where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _goToProcessingPage(
    Challenge challenge, {
    bool fromSearch = false,
  }) async {
    if (fromSearch) {
      _addRecentSearch(challenge.title);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChallengeDetailPage(challenge: challenge),
      ),
    );

    setState(() {
      selectedTab = fromSearch ? '추천' : '인기';
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색창 터치 시 호출될 메서드
  void _onSearchTap() {
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
    }
  }

  // 검색창 바깥 영역 터치 시 호출될 메서드
  void _onTapOutside() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    // 현재 포커스가 TextField가 아니면 해제
    if (!currentFocus.hasPrimaryFocus && _isSearching) {
      currentFocus.unfocus();
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTapOutside,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchAndCreateRow(), // 검색창
            const SizedBox(height: 12),
            if (!_isSearching && recentSearches.isNotEmpty)
              buildRecentSearchChips(),
            const SizedBox(height: 12),

            // Expanded로 남은 영역 채우기
            Expanded(
              child: _isSearching
                  ? Stack(
                      children: [
                        // 전체 배경 까맣게
                        Container(color: Colors.black.withOpacity(0.5)),

                        // 검색 결과 리스트 스크롤
                        Padding(
                          padding: const EdgeInsets.only(top: 12), // 상단 여유
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filteredChallenges.length,
                            itemBuilder: (context, index) {
                              final challenge = filteredChallenges[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: buildChallengeCard(challenge),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildCategoryGridWithBackground(),
                          const SizedBox(height: 12),
                          buildPresentedByVertical(),
                          const SizedBox(height: 12),
                          buildChallengeTabs(),
                          const SizedBox(height: 12),
                          ...challengesToShow.map(
                            (challenge) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: buildChallengeCard(challenge),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat; // 선택된 카테고리 적용
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget highlightText(String text, String query) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final start = lowerText.indexOf(lowerQuery);
    if (start == -1) return Text(text);

    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, start),
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: text.substring(end),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildSearchAndCreateRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // 상단 여유 추가
        // 🔍 검색창
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 60,
          child: Stack(
            alignment: Alignment.centerLeft,
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                opacity: _isSearching ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(child: Container()),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 0,
                right: _isSearching ? 0 : 56,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10000),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: _isSearching,
                    onTap: _onSearchTap,
                    onChanged: (value) {
                      setState(() {}); // 실시간 검색 반영
                    },
                    onSubmitted: (query) {
                      _addRecentSearch(query); // 최근 검색 저장
                      setState(() => _isSearching = true); // 닫지 말고 유지
                    },
                    decoration: InputDecoration(
                      hintText: '문제풀이 #수능 ...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 23),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/normal_lettuce.png',
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      suffixIcon: SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isSearching)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                    _isSearching = false;
                                    selectedCategory = '전체';
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final query = _searchController.text.trim();
                                if (query.isNotEmpty) {
                                  // 이동 처리
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SearchResultPage(query: query),
                                    ),
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🏷 카테고리 리스트 (검색 중일 때만 보이게)
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat; // 선택된 카테고리 적용
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                  _isSearching = true; // 태그 클릭 시 검색 모드 활성화
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
      color: Colors.grey.shade200, // 영역 전체 배경
      padding: const EdgeInsets.all(12),
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
                      : Colors.green.shade100,
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
          buildTabItem(
            '인기',
            isSelected: selectedTab == '인기',
            onTap: () {
              setState(() {
                selectedTab = '인기';
              });
            },
          ),
          const SizedBox(width: 16),
          buildTabItem(
            '추천',
            isSelected: selectedTab == '추천',
            onTap: () {
              setState(() {
                selectedTab = '추천';
              });
            },
          ),
          const SizedBox(width: 16),
          buildTabItem(
            '전체',
            isSelected: selectedTab == '전체',
            hasDropdown: true,
            onTap: () {
              setState(() {
                selectedTab = '전체';
              });
            },
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
        _goToProcessingPage(challenge);
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
