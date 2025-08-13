import 'package:bet_u/views/widgets/challenge_card_group.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/global_challenges.dart';
import 'package:bet_u/views/pages/challenge.dart';
import 'processing_challenge_detail_page.dart';
import 'package:bet_u/views/pages/betu_challenges_page.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchAndCreateRow(),
            const SizedBox(height: 12),
            if (_searchController.text.isEmpty && recentSearches.isNotEmpty)
              buildRecentSearchChips(),
            const SizedBox(height: 12),
            buildCategoryGridWithBackground(),
            buildPresentedByVertical(), // 여기 BETU 챌린지 표시
            buildChallengeTabs(),
            ...filteredChallenges
                .map((challenge) => buildChallengeCard(challenge))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchAndCreateRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    decoration: InputDecoration(
                      hintText: '문제풀이  #수능  ...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() {}),
                    onSubmitted: _addRecentSearch,
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
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.green),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
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
    final top3Challenges = betuChallenges.take(3).toList();

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
        // 세로로 카드 나열
        Column(
          children: top3Challenges
              .map(
                (challenge) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: buildChallengeCard(challenge),
                ),
              )
              .toList(),
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
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
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

  Widget buildChallengeCard(Challenge challenge) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProcessingChallengeDetailPage(challenge: challenge),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 왼쪽 텍스트 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 인원 수, 기간
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.participants}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${getDaysLeft(challenge)} Days',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 태그
                      // 태그
                      Wrap(
                        spacing: 4,
                        children:
                            (challenge.tags ?? []) // null이면 빈 리스트
                                .map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Chip(label: Text(tag)),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // 오른쪽 이미지 썸네일
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: challenge.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          challenge.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
