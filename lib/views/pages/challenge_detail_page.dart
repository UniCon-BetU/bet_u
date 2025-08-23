import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/pages/challenge_participate_page.dart';
import 'package:bet_u/views/widgets/chip_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChallengeDetailPage(challenge: betuChallenges[0]),
    ),
  );
}

class ChallengeDetailPage extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  bool isFavorite = false; // 즐겨찾기 상태

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------
            // 상단 이미지 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double totalWidth = constraints.maxWidth;
                  final double totalHeight = totalWidth * 2 / 3; // 3:2 비율
                  final double leftWidth = totalHeight; // 왼쪽 큰 정사각형 가로 = 높이
                  final double rightWidth = totalWidth - leftWidth; // 오른쪽 가로

                  return Center(
                    child: SizedBox(
                      width: totalWidth,
                      height: totalHeight,
                      child: Row(
                        children: [
                          // 왼쪽 큰 이미지 + 버튼 겹치기
                          SizedBox(
                            width: leftWidth,
                            height: totalHeight,
                            child: Stack(
                              children: [
                                Container(
                                  width: leftWidth,
                                  height: totalHeight,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image, size: 40),
                                ),
                                Positioned(
                                  top: 15,
                                  left: 15,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(
                                        0,
                                      ), // 배경 투명
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new,
                                      ),
                                      onPressed: () {
                                        // 뒤로가기 동작
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 오른쪽 레이아웃
                          SizedBox(
                            width: rightWidth,
                            height: totalHeight,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(color: Colors.grey.shade400),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: const Color.fromARGB(
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '+3',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        0,
                                                        0,
                                                        0,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 챌린지 이름 + 인원 + 태그
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "인원 ${challenge.participants}명",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: challenge.tags
                        .map((tag) => ChipWidget(text: tag))
                        .toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // 상세 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InfoRow(title: "공개 여부", value: "공개 챌린지 or 그룹 내부 챌린지"),
                  const SizedBox(height: 8),
                  const InfoRow(title: "챌린지 내용", value: "성공 조건"),
                  const SizedBox(height: 8),
                  InfoRow(title: "기간", value: "${challenge.day}일"),
                  const SizedBox(height: 8),
                  const InfoRow(title: "인증 방식", value: "사진 인증"),
                  const SizedBox(height: 16),
                  const Text(
                    "상세 설명",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(challenge.bannerDescription ?? "상세 설명이 제공되지 않았습니다."),
                ],
              ),
            ),

            const SizedBox(height: 120), // 하단 버튼과 겹치지 않도록 여백 확보
          ],
        ),
      ),

      // ----------------------------
      // 하단 즐겨찾기 + 배팅 버튼
      // ----------------------------
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? Colors.green : Colors.grey,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LongButtonWidget(
                  text: "배팅하고 참여하기",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengeParticipatePage(
                          challenge: widget.challenge,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 재사용 가능한 행 위젯
class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(child: Text(value)),
      ],
    );
  }
}
