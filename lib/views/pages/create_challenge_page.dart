// 🔹 ChallengePage.dart
import 'package:flutter/material.dart';
import 'challenge.dart';

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
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = '전체';
  String sortOption = '인기'; // 기본 정렬
  List<String> categories = [
    '전체',
    '수능',
    '토익',
    '공무원/행시',
    '회계사',
    'LEET',
    '자격증',
    '생활습관',
    '자기계발',
  ];
  List<String> recentSearches = [];

  List<Challenge> get filteredChallenges {
    List<Challenge> filtered = allChallenges.where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);
      return matchesCategory && matchesSearch;
    }).toList();

    if (sortOption == '인기') {
      filtered.sort((a, b) => b.popularity.compareTo(a.popularity));
    } else if (sortOption == '최신') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return filtered;
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

  void _addRecentSearch(String query) {
    if (query.isEmpty) return;
    if (!recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 5) recentSearches.removeLast();
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
            // 🔹 검색창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/512/616/616408.png', // 배추 이미지
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '검색어를 입력하세요',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() {}),
                      onSubmitted: (value) => _addRecentSearch(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.green),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 최근 검색어
            if (_searchController.text.isEmpty && recentSearches.isNotEmpty)
              Wrap(
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
              ),
            const SizedBox(height: 12),

            // 🔹 카테고리 2x4 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: categories.length > 8 ? 8 : categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Presented by BetU
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Presented by BetU',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...globalPresentedChallenges.map(
                    (challenge) => ListTile(
                      leading: Image.network(
                        challenge.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(challenge.title),
                      subtitle: Text(
                        '${challenge.participants}명 참여 • D-${challenge.daysLeft}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text('참여'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 정렬 옵션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('인기'),
                  selected: sortOption == '인기',
                  onSelected: (_) => setState(() => sortOption = '인기'),
                ),
                ChoiceChip(
                  label: const Text('최신'),
                  selected: sortOption == '최신',
                  onSelected: (_) => setState(() => sortOption = '최신'),
                ),
                ChoiceChip(
                  label: const Text('더보기'),
                  selected: sortOption == '더보기',
                  onSelected: (_) => setState(() => sortOption = '더보기'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 챌린지 리스트
            ...filteredChallenges.map(
              (challenge) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(challenge.title),
                  subtitle: Text(
                    '${challenge.category} • ${getStatusText(challenge.status)} • D-${getDaysLeft(challenge)}',
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${challenge.participants}명'),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            challenge.participants += 1;
                          });
                        },
                        child: const Text('참여'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
