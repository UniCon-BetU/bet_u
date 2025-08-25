// lib/views/pages/challenge_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../models/challenge.dart';
import 'challenge_detail_page.dart';
import 'package:bet_u/views/pages/create_challenge_page.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import '../../theme/app_colors.dart';
import '../../utils/challenge_history.dart' as ch;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ChallengePage(),
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
  final FocusNode _searchFocusNode = FocusNode();
  List<Challenge> get challengesToShow => getSortedChallenges();

  // 태그 상태
  String selectedTag = 'all'; // all | goal | time
  final List<String> tags = ['전체', '목표 챌린지', '기간 챌린지'];

  final LayerLink _tagLayerLink = LayerLink();
  OverlayEntry? _tagOverlayEntry;
  bool _isTagDropdownOpen = false;

  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = '수능';
  final List<Map<String, String>> categories = [
    {"name": "수능", "image": "assets/category/suneung.png"},
    {"name": "대학", "image": "assets/category/university.png"},

    {"name": "토익", "image": "assets/category/toeic.png"},
    {"name": "자격증", "image": "assets/category/certificate.png"},

    {"name": "공무원/행시", "image": "assets/category/gongmuwon.png"},
    {"name": "회계사", "image": "assets/category/account.png"},
    {"name": "LEET", "image": "assets/category/leet.png"},
    {"name": "생활/자기계발", "image": "assets/category/self.png"},
  ];

  List<String> recentSearches = [];
  String selectedTab = '인기'; // 인기 | 추천 | 전체
  String selectedType = 'all'; // (미사용 보류)

  bool _isSearching = false;

  // ---------- utils ----------
  void _addRecentSearch(String title) {
    if (title.isEmpty) return;
    recentSearches.remove(title);
    recentSearches.insert(0, title);
    if (recentSearches.length > 5) recentSearches.removeLast();
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
      _closeTagDropdown();
    });
  }

  void _onSearchTap() {
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
        selectedTag = 'all';
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  List<Challenge> getSortedChallenges() {
    List<Challenge> baseList;

    // 탭 기준
    if (selectedTab == '인기') {
      baseList = List.from(betuChallenges)
        ..sort((a, b) => b.participants.compareTo(a.participants));
    } else if (selectedTab == '추천') {
      baseList = List.from(ch.ChallengeHistory.instance.recent.value);
    } else {
      baseList = betuChallenges;
    }

    // 태그 기준
    if (selectedTag == 'goal') {
      baseList = baseList.where((c) => c.type == 'goal').toList();
    } else if (selectedTag == 'time') {
      baseList = baseList.where((c) => c.type == 'time').toList();
    }
    return baseList;
  }

  List<Challenge> get filteredChallenges {
    return getSortedChallenges().where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);

      final matchesTag =
          selectedTag == 'all' ||
          (selectedTag == 'goal' && c.type == 'goal') ||
          (selectedTag == 'time' && c.type == 'time');

      return matchesCategory && matchesSearch && matchesTag;
    }).toList();
  }

  // 검색에서 들어온 탭 전환/최근검색어 기록만 담당
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
        builder: (context) => ChallengeDetailPage(challenge: challenge),
      ),
    );

    if (!mounted) return;
    setState(() {
      if (fromSearch) {
        selectedTab = '추천';
        _addRecentSearch(challenge.title);
      }
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
      default:
        return '-';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tagOverlayEntry?.remove();
    super.dispose();
  }

  void _onTapOutside() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && _isSearching) {
      currentFocus.unfocus();
      setState(() => _isSearching = false);
    }
  }

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

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: _onTapOutside,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchAndCreateRow(),
            const SizedBox(height: 5),
            if (!_isSearching && recentSearches.isNotEmpty)
              buildRecentSearchChips(),
            const SizedBox(height: 12),

            Expanded(
              child: _isSearching
                  // ===== 검색 모드 =====
                  ? Container(
                      color: const Color.fromRGBO(246, 246, 246, 1),
                      padding: const EdgeInsets.only(top: 12),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = filteredChallenges[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ChallengeTileWidget(
                              c: challenge,
                              showTags: false,
                              background: Colors.white,
                              onTap: () => _goToProcessingPage(
                                challenge,
                                fromSearch: true, // 검색에서 진입
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  // ===== 일반 모드 =====
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: buildCategoryGridWithBackground()),
                          const SizedBox(height: 12),

                          // BETU 섹션
                          BetuChallengeSectionWidget(
                            allChallenges: betuChallenges,
                            onTileTap: (challenge) => _goToProcessingPage(
                              challenge,
                              fromSearch: _isSearching,
                            ),
                          ),

                          const SizedBox(height: 12),
                          buildChallengeTabs(),
                          const SizedBox(height: 12),

                          // 추천 탭 자동 갱신
                          ValueListenableBuilder<List<Challenge>>(
                            valueListenable:
                                ch.ChallengeHistory.instance.recent,
                            builder: (context, _, __) {
                              final list = challengesToShow;

                              if (selectedTab == '추천' && list.isEmpty) {
                                return Padding(
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
                                );
                              }

                              return Column(
                                children: list
                                    .map(
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
                                    )
                                    .toList(),
                              );
                            },
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

  // ---------- overlays ----------
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
                // 선택 표시 정확히 매핑
                final isSelected =
                    (tag == '전체' && selectedTag == 'all') ||
                    (tag == '목표 챌린지' && selectedTag == 'goal') ||
                    (tag == '기간 챌린지' && selectedTag == 'time');

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
                  onTap: () => _onTagSelected(tag),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI parts ----------
  Widget buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat["name"];
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat["name"]!),
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
                    cat["name"]!,
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
            style: const TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: text.substring(end),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildSearchAndCreateRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 54,
            width: double.infinity,
            child: Stack(
              children: [
                // 검색바: 오른쪽 여백만 애니메이션으로 80 -> 0
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  left: 0,
                  right: _isSearching ? 0 : 80,
                  child: Material(
                    color: AppColors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: SizedBox(
                      height: 54,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: _isSearching,
                        onTap: _onSearchTap, // 여기서 _isSearching=true로
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '문제풀이, #수능 ...',
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          // height: 54이면 vertical padding을 조금 줄이는 게 좋아요
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 11,
                            horizontal: 12,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/images/normal_lettuce.png',
                                fit: BoxFit.contain,
                                width: 48,
                                height: 48,
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
                                      _searchFocusNode.unfocus();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Color.fromRGBO(158, 158, 158, 1),
                                  ),
                                ),
                              const SizedBox(width: 7),
                              GestureDetector(
                                onTap: () {
                                  final query = _searchController.text.trim();
                                  if (query.isNotEmpty) {
                                    // TODO: 검색 액션
                                  }
                                },
                                child: const Icon(
                                  Icons.search,
                                  size: 30,
                                  color: Color.fromRGBO(117, 117, 117, 1),
                                ),
                              ),
                              const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 플러스 버튼: 화면 밖으로 슬라이드 + 페이드아웃
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  right: _isSearching ? -72 : 0, // -72 정도면 완전히 사라짐
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: _isSearching ? 0.5 : 1,
                    child: IgnorePointer(
                      ignoring: _isSearching, // 사라지는 중 터치 막기
                      child: IconButton(
                        iconSize: 40,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.black,
                        ),
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
                ),
              ],
            ),
          ),

          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () => setState(
                        () => selectedCategory = cat['name']!,
                      ), // ✅ 선택도 name으로
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
                          cat['name']!, // ✅ 이렇게 수정
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
      ),
    );
  }

  Widget buildRecentSearchChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: recentSearches.map((search) {
          final isSelected = _searchController.text == search;
          return GestureDetector(
            onTap: () {
              setState(() {
                _searchController.text = search;
                _isSearching = true;
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
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 255, 233),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Spacer(),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat["name"]!;
                    _isSearching = true;
                  });
                },
                child: Column(
                  children: [
                    // CircleAvatar 대신 이미지 그대로
                    Image.asset(
                      cat["image"]!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none, // <- 픽셀 낮춤
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat["name"]!,
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

  Widget buildChallengeTabs() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _buildTabItem(
            label: '인기',
            isSelected: selectedTab == '인기',
            onTap: () => setState(() {
              selectedTab = '인기';
              selectedTag = 'all';
            }),
          ),
          const SizedBox(width: 24),
          _buildTabItem(
            label: '추천',
            isSelected: selectedTab == '추천',
            onTap: () => setState(() {
              selectedTab = '추천';
              selectedTag = 'all';
            }),
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              _buildTabItem(
                label: '전체',
                isSelected: selectedTab == '전체',
                onTap: () => setState(() {
                  selectedTab = '전체';
                  selectedTag = 'all';
                }),
              ),
              CompositedTransformTarget(
                link: _tagLayerLink,
                child: GestureDetector(
                  onTap: _toggleTagDropdown,
                  child: Icon(
                    _isTagDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 28,
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
          const SizedBox(height: 5),
          if (isSelected) Container(height: 3, width: 30, color: Colors.green),
        ],
      ),
    );
  }
}
