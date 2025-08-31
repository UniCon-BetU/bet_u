// lib/views/pages/challenge_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/data/global_challenges.dart';
import '../../../models/challenge.dart';
import 'challenge_detail_page.dart';
import 'package:bet_u/views/pages/challenge_tab/create_challenge_page.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:bet_u/views/widgets/betu_challenge_section_widget.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/utils/challenge_history.dart' as ch;
import 'package:bet_u/views/widgets/search_bar_widget.dart';
import 'package:bet_u/views/widgets/search_tag_chip_widget.dart';

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Challenge Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChallengePage(), // 여기서 ChallengePage 보여줌
    );
  }
}
*/
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
  String selectedCategory = '전체';
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

  List<String> get searchCategories => [
    '전체',
    ...categories.map((c) => c["name"]!),
  ];

  List<String> recentSearches = [];
  String selectedTab = '인기'; // 인기 | 최근 | 전체
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
    setState(() {
      if (!_isSearching) {
        selectedTag = 'all';
        selectedCategory = '전체';

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _searchFocusNode.requestFocus();
        });
      }
    });
  }

  List<Challenge> getSortedChallenges() {
    List<Challenge> baseList;

    // 탭 기준
    if (selectedTab == '인기') {
      baseList = List.from(allChallenges)
        ..sort((a, b) => b.participants.compareTo(a.participants));
    } else if (selectedTab == '최근') {
      baseList = List.from(ch.ChallengeHistory.instance.recent.value);
    } else {
      baseList = allChallenges;
    }

    // 태그 기준
    if (selectedTag == 'goal') {
      baseList = baseList.where((c) => c.type == 'goal').toList();
    } else if (selectedTag == 'time') {
      baseList = baseList.where((c) => c.type == 'time').toList();
    }
    return baseList;
  }

  List<Challenge> get _searchBaseList => allChallenges;

  List<Challenge> get filteredChallenges {
    // ✅ 검색 중이면 '탭 영향 없음' → 전체 목록에서 필터
    // ✅ 일반 모드이면 기존처럼 탭/태그 정렬 반영
    final base = _isSearching ? _searchBaseList : getSortedChallenges();

    return base.where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;

      final query = _searchController.text.trim();
      final matchesSearch =
          query.isEmpty || c.title.contains(query) || c.tags.contains(query);

      // 검색 모드에선 selectedTag를 강제로 'all'로 운용하지만
      // 혹시 UI에서 태그를 쓰게 될 확장 대비해서 조건은 유지
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
        selectedTab = '최근';
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
      // 3) ChallengePage의 AppBar에 적용
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: _isSearching ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        centerTitle: false,
        titleSpacing: 0,
        // 검색바 높이 + 살짝 여유
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
          }
        ),

        title: Padding(
          // toolbarHeight 64에서 세로 패딩 12면 살짝 넘칠 수 있어요 → 6 정도로 줄이거나, toolbarHeight를 늘리세요
          padding: const EdgeInsets.fromLTRB(6, 0, 24, 0),
          child: SearchBarOnly(
            controller: _searchController,
            focusNode: _searchFocusNode,
            isSearching: _isSearching,
            onSearchingChanged: (v) => setState(() => _isSearching = v),
            onTapSearch: _onSearchTap,
            onPlusPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateChallengePage()),
              );
            },
            decoration: InputDecoration(
              hintText: '문제풀이, #수능 ...',
              hintStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkerGray,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 11,
                horizontal: 12,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/normal_lettuce.png',
                  width: 48,
                  height: 48,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // _searchController.clear();
                          // _isSearching = false;
                          // selectedCategory = '전체';
                          // _searchFocusNode.unfocus();
                          _searchController.clear();
                        });
                        _searchFocusNode.requestFocus();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkerGray,
                      ),
                    ),
                  const SizedBox(width: 7),
                  const Icon(Icons.search, size: 30, color: Colors.black),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
        ),

        // ✅ bottom은 항상 유지하고, 높이만 0↔44로 애니메이션
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearching ? 44 : 0),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _isSearching
                ? Container(
                    color: Colors.white,
                    child: CategoryChipsBar(
                      categories: searchCategories,
                      selected: selectedCategory,
                      onSelect: (cat) => setState(() => selectedCategory = cat),
                    ),
                  )
                : const SizedBox(height: 0),
          ),
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: _onTapOutside,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (!_isSearching && recentSearches.isNotEmpty)
            //  buildRecentSearchChips(),
            Expanded(
              child: _isSearching
                  // ===== 검색 모드 =====
                  ? Container(
                      color: AppColors.lightGray,
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '검색 결과 필터링',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                buildSearchTagDropdown(),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: filteredChallenges.length,
                              itemBuilder: (context, index) {
                                final challenge = filteredChallenges[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ChallengeTileWidget(
                                    c: challenge,
                                    showTags: true,
                                    background: Colors.white,
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
                      ),
                    )
                  // ===== 일반 모드 =====
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: buildCategoryGridWithBackground(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: BetuChallengeSectionWidget(
                              challengeFrom: allChallenges,
                              onTileTap: (challenge) => _goToProcessingPage(
                                challenge,
                                fromSearch: _isSearching,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          buildChallengeTabs(),

                          // 최근 탭 자동 갱신
                          ValueListenableBuilder<List<Challenge>>(
                            valueListenable:
                                ch.ChallengeHistory.instance.recent,
                            builder: (context, _, __) {
                              final list = challengesToShow;

                              if (selectedTab == '최근' && list.isEmpty) {
                                return Container(
                                  color: AppColors.lightGray,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 100,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '최근 방문한 챌린지가 없습니다.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Container(
                                constraints: BoxConstraints(minHeight: 160),
                                color: AppColors.lightGray,
                                child: Column(
                                  children: list
                                      .map(
                                        (challenge) => Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            8,
                                            24,
                                            0,
                                          ),
                                          child: ChallengeTileWidget(
                                            c: challenge,
                                            background: Colors.white,
                                            showTags: true,
                                            onTap: () => _goToProcessingPage(
                                              challenge,
                                              fromSearch: _isSearching,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
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
  String _currentTagLabel() {
    switch (selectedTag) {
      case 'time':
        return '기간 챌린지';
      case 'goal':
        return '목표 챌린지';
      case 'all':
      default:
        return '전체';
    }
  }

  /// 검색 모드용: 우측에 붙는 드롭다운 버튼
  Widget buildSearchTagDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 8),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        onSelected: (value) {
          setState(() {
            selectedTag = value; // 'all' | 'time' | 'goal'
          });
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            height: 30,
            value: 'all',
            child: Row(
              children: const [
                Icon(Icons.open_in_full_rounded, size: 18),
                SizedBox(width: 8),
                Text('전체'),
              ],
            ),
          ),
          PopupMenuItem(
            height: 30,
            value: 'time',
            child: Row(
              children: const [
                Icon(Icons.schedule, size: 18),
                SizedBox(width: 8),
                Text('기간 챌린지'),
              ],
            ),
          ),
          PopupMenuItem(
            height: 30,
            value: 'goal',
            child: Row(
              children: const [
                Icon(Icons.flag, size: 18),
                SizedBox(width: 8),
                Text('목표 챌린지'),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list, size: 18),
              const SizedBox(width: 6),
              Text(
                _currentTagLabel(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
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
              return StatefulBuilder(
                builder: (context, setLocalState) {
                  double scale = 1.0;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat["name"]!;
                        _isSearching = true;
                      });
                    },
                    onTapDown: (_) => setLocalState(() => scale = 0.9),
                    onTapUp: (_) => setLocalState(() => scale = 1.0),
                    onTapCancel: () => setLocalState(() => scale = 1.0),
                    child: AnimatedScale(
                      scale: scale,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Column(
                        children: [
                          Image.asset(
                            cat["image"]!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                          Text(
                            cat["name"]!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
            label: '최근',
            isSelected: selectedTab == '최근',
            onTap: () => setState(() {
              selectedTab = '최근';
              selectedTag = 'all';
            }),
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
