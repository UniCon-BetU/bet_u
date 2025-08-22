import 'package:flutter/material.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../models/challenge.dart';
import 'challenge_detail_page.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';
import 'package:bet_u/views/pages/create_challenge_page.dart';

import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
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
  final FocusNode _searchFocusNode = FocusNode(); // 추가
  // 1️⃣ 상태 추가
  String selectedTag = 'all'; // 기본값: goal
  final List<String> tags = ['전체', '목표 챌린지', '기간 챌린지'];

  final LayerLink _tagLayerLink = LayerLink();
  OverlayEntry? _tagOverlayEntry;
  bool _isTagDropdownOpen = false;

  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = '전체';
  List<Challenge> recentVisitedChallenges = [];
  String selectedTab = '인기';
  String selectedType = 'all';

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

  void _onTagSelected(String tagLabel) {
    setState(() {
      if (tagLabel == '전체') {
        selectedTag = 'all';
      } else if (tagLabel == '목표 챌린지') {
        selectedTag = 'goal';
      } else if (tagLabel == '기간 챌린지') {
        selectedTag = 'time';
      }
      _closeTagDropdown(); // 드롭다운 닫기
    });
  }

  void _onSearchTap() {
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
        selectedTag = 'all'; // 검색 시작하면 태그 초기화
      });
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  List<String> recentSearches = [];
  List<Challenge> getSortedChallenges() {
    List<Challenge> baseList;

    // 1️⃣ 탭 기준으로 기본 리스트 선택
    if (selectedTab == '인기') {
      baseList = List.from(betuChallenges)
        ..sort((a, b) => b.participants.compareTo(a.participants));
    } else if (selectedTab == '추천') {
      baseList = recentVisitedChallenges;
    } else {
      baseList = betuChallenges;
    }

    // 2️⃣ 태그(selectedTag) 기준으로 필터링
    if (selectedTag == 'goal') {
      baseList = baseList.where((c) => c.type == 'goal').toList();
    } else if (selectedTag == 'time') {
      baseList = baseList.where((c) => c.type == 'time').toList();
    }
    // 'all'이면 필터 안함

    return baseList;
  }

  List<Challenge> get filteredChallenges {
    return getSortedChallenges().where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);

      // 🔽 태그 기준 필터 추가
      final matchesTag =
          selectedTag == 'all' ||
          (selectedTag == 'goal' && c.type == 'goal') ||
          (selectedTag == 'time' && c.type == 'time');

      return matchesCategory && matchesSearch && matchesTag;
    }).toList();
  }

  void _goToProcessingPage(
    Challenge challenge, {
    bool fromSearch = false,
  }) async {
    // ✅ 방문 내역 저장
    recentVisitedChallenges.remove(challenge); // 중복 제거
    recentVisitedChallenges.insert(0, challenge); // 최신이 앞으로
    if (recentVisitedChallenges.length > 10) {
      recentVisitedChallenges.removeLast(); // 최대 10개만 보관
    }

    if (fromSearch) {
      _addRecentSearch(challenge.title);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailPage(challenge: challenge),
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
      case ChallengeStatus.notStarted:
        return '-';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // FocusNode 해제

    super.dispose();
  }

  // 검색창 터치 시 호출될 메서드

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

  // 2️⃣ 드롭다운 토글
  void _toggleTagDropdown() {
    if (_isTagDropdownOpen) {
      _closeTagDropdown();
    } else {
      _openTagDropdown();
    }
  }

  void _openTagDropdown() {
    final overlay = Overlay.of(context);
    _tagOverlayEntry = _createTagOverlayEntry();
    overlay.insert(_tagOverlayEntry!);
    setState(() => _isTagDropdownOpen = true);
  }

  void _closeTagDropdown() {
    _tagOverlayEntry?.remove();
    _tagOverlayEntry = null;
    setState(() => _isTagDropdownOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: _onTapOutside,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchAndCreateRow(), // 검색창
            const SizedBox(height: 5),
            if (!_isSearching && recentSearches.isNotEmpty)
              buildRecentSearchChips(),
            const SizedBox(height: 12),

            // Expanded로 남은 영역 채우기
            Expanded(
              child: _isSearching
                  ? Stack(
                      children: [
                        // 전체 배경 이거 검색했을때 배경
                        Container(
                          color: const Color.fromRGBO(
                            246,
                            246,
                            246,
                            1,
                          ), // 원하는 색상도 가능
                        ),
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
                                child: ChallengeTileWidget(
                                  c: challenge,
                                  showTags: false,
                                  background: _isSearching
                                      ? Colors.white
                                      : null, // 🔹 검색 모드일 때 하얀색

                                  onTap: () => _goToProcessingPage(
                                    challenge,
                                    fromSearch: _isSearching,
                                  ),
                                ),
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
                          Center(child: buildCategoryGridWithBackground()),
                          const SizedBox(height: 12),
                          buildPresentedByVertical(),
                          const SizedBox(height: 12),
                          buildChallengeTabs(),
                          const SizedBox(height: 12),
                          // ✅ 남은 챌린지 리스트 + 추천 탭 비었을 경우
                          if (selectedTab == '추천' && challengesToShow.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 100,
                              ),
                              child: Center(
                                child: Text(
                                  '최근 방문한 챌린지가 없습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...challengesToShow.map(
                              (challenge) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: ChallengeTileWidget(
                                  c: challenge,
                                  showTags: true,
                                  onTap: () => _goToProcessingPage(
                                    challenge,
                                    fromSearch: _isSearching,
                                  ),
                                ),
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

  // 3️⃣ OverlayEntry 생성
  OverlayEntry _createTagOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 120,
        child: CompositedTransformFollower(
          link: _tagLayerLink,
          offset: const Offset(0, 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = selectedTag == tag;
                return ListTile(
                  title: Text(
                    tag,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.green : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    _onTagSelected(tag); // 드롭다운 선택 시 selectedTag 업데이트 및 닫기까지 처리
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1), // 👈 배경색 (원하는 색 넣어도 됨)
          borderRadius: BorderRadius.circular(20), // 👈 테두리 완만하게
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat;
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
                    borderRadius: BorderRadius.circular(40),
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
        const SizedBox(height: 24), // 상단 여유
        // 🔍 검색창 + Add 버튼
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 80,
          width: MediaQuery.of(context).size.width * 0.98,
          child: Stack(
            children: [
              // 검색창
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 28,
                right: _isSearching ? 20 : 80,
                child: Material(
                  color: const Color.fromRGBO(234, 255, 185, 1),
                  shape: const StadiumBorder(), // 완전 타원
                  child: SizedBox(
                    height: 80,
                    child: TextField(
                      controller: _searchController,
                      autofocus: _isSearching,
                      onTap: _onSearchTap,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '문제풀이 #수능 ...',
                        hintStyle: TextStyle(
                          fontSize: 20, // 원하는 크기로 조정
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade600, // 원하는 색상도 가능
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 16,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/normal_lettuce.png',
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                  color: Color.fromRGBO(158, 158, 158, 1),
                                ),
                              ),
                            const SizedBox(width: 7), // 여기를 조정하면 왼쪽으로 이동
                            GestureDetector(
                              onTap: () {
                                final query = _searchController.text.trim();
                                if (query.isNotEmpty) {
                                  // 검색 이동 처리
                                }
                              },
                              child: const Icon(
                                Icons.search,
                                size: 30,
                                color: Color.fromRGBO(
                                  117,
                                  117,
                                  117,
                                  1,
                                ), // 원하는 색상도 가능
                              ),
                            ),
                            const SizedBox(width: 15), // 오른쪽 여유
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Add 버튼 (검색 중이면 숨김)
              if (!_isSearching)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      iconSize: 24,
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateChallengePage(),
                          ),
                        );
                      },
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
                        selectedCategory = cat;
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: recentSearches.map((search) {
          final isSelected = _searchController.text == search; // 선택된 검색어
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchController.text = search;
                _isSearching = true; // 태그 클릭 시 검색 모드 유지
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                search,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildCategoryGridWithBackground() {
    return Container(
      width: 450,
      height: 250, // 전체 Grid 높이
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 255, 233),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Spacer(), // 위쪽 공간을 밀어서 아래로 붙임
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length, // '전체' 제외
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat;
                    _isSearching = true; // 👈 검색 모드로 전환
                  });
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF1BAB0F),
                      child: const Icon(Icons.school, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 21.0,
          ), // 위/아래 간격 넓히고 좌측 여유 추가
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    'BETU Challenges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6), // 아이콘과 텍스트 사이 간격 넓힘
                  Icon(Icons.eco, color: Colors.green),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
                onPressed: () {
                  // BETU 챌린지만 필터링해서 전달
                  final betuOnlyChallenges = betuChallenges
                      .where((c) => c.type == 'betu')
                      .toList();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BetuChallengesPage(
                        betuChallenges: betuOnlyChallenges,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 페이지 뷰
        SizedBox(
          height: 340, // 카드 3개 세로로 들어갈 높이
          child: PageView.builder(
            controller: pageController,
            itemCount: chunkedChallenges.length,
            itemBuilder: (context, pageIndex) {
              return Column(
                children: chunkedChallenges[pageIndex]
                    .map(
                      (challenge) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ChallengeTileWidget(
                          c: challenge,
                          showTags: false,
                          onTap: () => _goToProcessingPage(
                            challenge,
                            fromSearch: _isSearching,
                          ),
                        ),
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

  Widget buildChallengeTabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 20), // 왼쪽 여유
      child: Row(
        children: [
          _buildTabItem(
            label: '인기',
            isSelected: selectedTab == '인기',
            onTap: () {
              setState(() {
                selectedTab = '인기';
                selectedTag = 'all'; // 인기 탭 눌렀을 때 초기화
              });
            },
          ),
          const SizedBox(width: 24),
          _buildTabItem(
            label: '추천',
            isSelected: selectedTab == '추천',
            onTap: () {
              setState(() {
                selectedTab = '추천';
                selectedTag = 'all'; // 인기 탭 눌렀을 때 초기화
              });
            },
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              _buildTabItem(
                label: '전체',
                isSelected: selectedTab == '전체',
                onTap: () {
                  setState(() {
                    selectedTab = '전체';
                    selectedTag = 'all'; // 인기 탭 눌렀을 때 초기화
                  });
                },
              ),
              // 화살표 아이콘 (드롭다운용)
              CompositedTransformTarget(
                link: _tagLayerLink,
                child: GestureDetector(
                  onTap: _toggleTagDropdown,
                  child: Icon(
                    _isTagDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 28,
                    // 💡 여기에 조건 추가
                    color: selectedTab == '전체' ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.black,
            ),
          ),
          const SizedBox(height: 5), // 텍스트와 밑줄 사이 간격
          if (isSelected) // 👈 선택된 탭에만 밑줄 표시
            Container(
              height: 3, // 밑줄 높이
              width: 30, // 밑줄 너비
              color: Colors.green, // 밑줄 색상
            ),
        ],
      ),
    );
  }
}
