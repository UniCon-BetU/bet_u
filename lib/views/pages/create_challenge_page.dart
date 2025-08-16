import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/global_challenges.dart';
import '../../models/challenge.dart'; // Challenge 클래스 임포트 (필요시)

// 챌린지 생성 페이지 (예시)
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
  final startDate = challenge.createdAt; // 또는 사용자가 참여한 시작일
  final endDate = startDate.add(Duration(days: challenge.day));
  final diff = endDate.difference(now).inDays;
  return diff >= 0 ? diff : 0;
}

class _ChallengePageState extends State<ChallengePage> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = '전체';
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
    return betuChallenges.where((c) {
      final matchesCategory =
          selectedCategory == '전체' || c.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          c.title.contains(_searchController.text);
      return matchesCategory && matchesSearch;
    }).toList();
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
            // 🔹 검색창 및 챌린지 생성 버튼
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 박스 왼쪽 아이콘 (임의의 이미지로 대체)
                        // 'assets/placeholder.png' 경로의 이미지를 사용하세요.
                        // 이 부분을 실제 이미지 위젯으로 교체해야 합니다.
                        // 예시: Image.asset('assets/placeholder.png', width: 24, height: 24),
                        const Icon(Icons.person, color: Colors.green), // 임시 아이콘
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: false,
                            decoration: InputDecoration(
                              // 연한 색상의 힌트 텍스트
                              hintText: '문제풀이  #수능  ...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            onSubmitted: (value) {
                              _addRecentSearch(value);
                            },
                          ),
                        ),
                        // 박스 오른쪽 돋보기 아이콘
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.green),
                          onPressed: () {
                            _addRecentSearch(_searchController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 챌린지 생성 연필 아이콘 버튼
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
            const SizedBox(height: 12),

            // 🔹 최근 검색어 표시
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
            ), // <- 여기에 .toList()가 추가되었습니다.

            const SizedBox(height: 20),

            // 🔹 Presented by BetU
            Center(
              child: Text(
                'Presented by BetU',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
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
