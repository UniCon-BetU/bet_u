import 'package:bet_u/views/pages/challenge_certification_page.dart';
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/pages/challenge_participate_page.dart';
import 'package:bet_u/views/widgets/chip_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';

import 'package:bet_u/views/widgets/goal_bubble_widget.dart';

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

    // 👉 ChallengeStatus에 따른 색상 분기
    Color statusColor;
    switch (challenge.status) {
      case ChallengeStatus.notStarted:
        statusColor = Colors.green;
        break;
      case ChallengeStatus.inProgress:
        statusColor = Colors.red;
        break;
      case ChallengeStatus.missed:
        statusColor = Colors.grey; // 임시
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 160), // 하단바 높이만큼 여백 확보
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
                  final double leftWidth = totalHeight;
                  final double rightWidth = totalWidth - leftWidth;

                  return Center(
                    child: SizedBox(
                      width: totalWidth,
                      height: totalHeight,
                      child: Row(
                        children: [
                          // 왼쪽 큰 이미지
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
                                      color: Colors.white.withOpacity(0),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new,
                                      ),
                                      onPressed: () {
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
                                                color: Colors.transparent,
                                                child: const Center(
                                                  child: Text(
                                                    '+3',
                                                    style: TextStyle(
                                                      color: Colors.black,
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
                    children: challenge.tags
                        .map(
                          (tag) => ChipWidget(
                            text: tag,
                            backgroundColor: Colors.green, // 상태별 색상
                          ),
                        )
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
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),

      // ----------------------------
      // 하단 진행도 + 즐겨찾기/배팅 버튼
      // ----------------------------
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (challenge.status == ChallengeStatus.inProgress)
            ProgressStatusBar(day: 1, totalDay: challenge.day),
          SafeArea(
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
                      color: statusColor,
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
                      text: challenge.status == ChallengeStatus.inProgress
                          ? "인증하기"
                          : "배팅하고 참여하기",
                      backgroundColor: statusColor,
                      onPressed: () {
                        if (widget.challenge.status ==
                            ChallengeStatus.inProgress) {
                          // 👉 진행중이면 인증 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChallengeCertificationPage(
                                challenge: challenge, // 객체 그대로 전달
                              ),
                            ),
                          );
                        } else {
                          // 👉 진행중이 아니면 참여 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChallengeParticipatePage(
                                challenge: widget.challenge,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 진행도 위젯
class ProgressStatusBar extends StatelessWidget {
  final double percent;
  final int day;
  final int totalDay;
  final int remainDay;

  const ProgressStatusBar({super.key, required this.day, required this.totalDay})
    : percent = day / totalDay,
      remainDay = totalDay - day;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ), // 기존 12 -> 8 등으로 줄임
      decoration: const BoxDecoration(
        color: Colors.white, // 1. 하얀 배경
        border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Column(
        children: [
          // 상단 퍼센트 + 말풍선
          const SizedBox(height: 1),

          // 2. 이미지 뒤, 3. 진행 바 앞으로
          SizedBox(
            height: 130, // Stack 높이를 이미지 높이에 맞춤
            child: Stack(
              children: [
                // 이미지 (뒤쪽)
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    // percent * 100로 0~100 기준 계산
                    percent * 100 <= 30
                        ? 'images/normal_lettuce.png'
                        : percent * 100 <= 70
                        ? 'images/happy_lettuce.png'
                        : 'images/red_lettuce.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                // 퍼센트 + 챌린지 진행도 텍스트
                Stack(
                  children: [
                    // 퍼센트 텍스트 (위쪽 고정)
                    Positioned(
                      top: 38,
                      left: 16,
                      child: Text(
                        "${(percent * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),

                    // 챌린지 진행도 컬럼 (퍼센트보다 아래)
                    Positioned(
                      top: 60, // 퍼센트보다 아래로
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "챌린지 진행도",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "Day $day/$totalDay",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 16,
                  child: GoalBubbleWidget(
                    text: '성공까지 D-$remainDay',
                    color: Colors.red,
                    pointerHeight: 10,
                    pointerWidth: 15,
                    borderRadius: 100,
                  ),
                ),
                // 진행 바 (아래쪽)
                Positioned(
                  bottom: 6,
                  left: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 17,
                      width: double.infinity, // 화면 폭 전체
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
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

class TopPointerBubble extends StatelessWidget {
  final String text;

  const TopPointerBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TopBubblePainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TopBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;
    final path = Path();

    double pointerHeight = 8; // 포인터 높이
    double pointerWidth = 12; // 포인터 너비
    double radius = 8;
    double pointerGap = -100; // 포인터와 본체 사이 간격

    // 위쪽 포인터 시작
    path.moveTo(size.width / 2 + pointerWidth / 2, pointerHeight + pointerGap);
    path.lineTo(size.width / 2, 0); // 포인터 꼭짓점
    path.lineTo(size.width / 2 - pointerWidth / 2, pointerHeight + pointerGap);

    // 본체
    path.lineTo(radius, pointerHeight + pointerGap);
    path.quadraticBezierTo(
      0,
      pointerHeight + pointerGap,
      0,
      pointerHeight + radius + pointerGap,
    );
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radius,
    );
    path.lineTo(size.width, pointerHeight + radius + pointerGap);
    path.quadraticBezierTo(
      size.width,
      pointerHeight + pointerGap,
      size.width - radius,
      pointerHeight + pointerGap,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
