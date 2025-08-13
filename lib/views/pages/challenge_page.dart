import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/global_challenges.dart';
import 'challenge.dart'; // Challenge 클래스 임포트 (필요시)
import 'processing_challenge_detail_page.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  String selectedCategory = '전체';
  String searchQuery = '';
  bool sortByPopularity = false;

  final List<String> categories = [
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
            // 상단 검색 + 해시태그 + 챌린지 만들기 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 배추 아이콘
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade700,
                    ), // 임시 아이콘
                  ),
                  const SizedBox(width: 8),

                  // 해시태그 예시
                  Expanded(
                    child: Text(
                      '매일 아침 7시 기상 #수능 #토익',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 돋보기 버튼
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.green),
                    onPressed: () {
                      // 검색창 열기 or 검색 페이지 이동
                    },
                  ),

                  // 챌린지 만들기 버튼
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      // 챌린지 생성 페이지로 이동
                    },
                  ),
                ],
              ),
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
            const SizedBox(height: 16),

            // Presented by BETU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Presented by BETU 🍃',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    // 전체 presented 리스트 페이지 이동
                  },
                ),
              ],
            ),

            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: globalPresentedChallenges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final pc = globalPresentedChallenges[index];
                  return Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            pc.imageUrl,
                            width: double.infinity,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pc.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${pc.participants}명 · D-${pc.daysLeft}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (pc.isParticipated)
                                const Text(
                                  '참여 중',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProcessingChallengeDetailPage(
                                  challenge: challenge,
                                ),
                              ),
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
                                          fontFamily: 'freesentation',
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
                                    fontFamily: 'freesentation',
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
