import 'package:flutter/material.dart';
import 'global_challenges.dart'; // 글로벌 챌린지 리스트 임포트
import 'challenge.dart'; // Challenge 클래스 임포트 (필요시)

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  String selectedCategory = '전체';
  String searchQuery = '';
  bool sortByPopularity = false;

  final List<String> categories = ['전체', '공부', '운동', '생활습관'];

  List<Challenge> get filteredChallenges {
    List<Challenge> filtered = allChallenges;

    if (selectedCategory != '전체') {
      filtered = filtered.where((c) => c.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.title.contains(searchQuery) ||
                c.category.contains(searchQuery),
          )
          .toList();
    }

    if (sortByPopularity) {
      filtered.sort((a, b) => b.popularity.compareTo(a.popularity));
    } else {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  Color getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.inProgress:
        return Colors.blueAccent;
      case ChallengeStatus.done:
        return Colors.green;
      case ChallengeStatus.missed:
        return Colors.redAccent;
    }
  }

  String getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.inProgress:
        return '진행 중';
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 검색창
            TextField(
              decoration: InputDecoration(
                hintText: '챌린지를 검색하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // 카테고리 선택 가로 리스트
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 정렬 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      sortByPopularity = false;
                    });
                  },
                  icon: Icon(
                    Icons.new_releases,
                    color: sortByPopularity ? Colors.grey : Colors.blueAccent,
                  ),
                  label: Text(
                    '최신순',
                    style: TextStyle(
                      color: sortByPopularity ? Colors.grey : Colors.blueAccent,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      sortByPopularity = true;
                    });
                  },
                  icon: Icon(
                    Icons.thumb_up,
                    color: sortByPopularity ? Colors.blueAccent : Colors.grey,
                  ),
                  label: Text(
                    '인기순',
                    style: TextStyle(
                      color: sortByPopularity ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 챌린지 리스트
            Expanded(
              child: filteredChallenges.isEmpty
                  ? Center(
                      child: Text(
                        '조건에 맞는 챌린지가 없습니다.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredChallenges.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final challenge = filteredChallenges[index];
                        return InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${challenge.title} 선택됨')),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 상태 원
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(challenge.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 텍스트 영역
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        challenge.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${challenge.participants}명 참가 · ${challenge.day}일',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 상태 텍스트
                                Text(
                                  getStatusText(challenge.status),
                                  style: TextStyle(
                                    color: getStatusColor(challenge.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
