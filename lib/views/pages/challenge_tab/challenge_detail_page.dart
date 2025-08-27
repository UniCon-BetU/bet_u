import 'package:bet_u/views/pages/challenge_tab/challenge_certification_page.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import 'package:bet_u/data/global_challenges.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_participate_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_page.dart';

import 'package:bet_u/views/widgets/chip_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import '../../../theme/app_colors.dart';

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
      body: Column(
        children: [
          // ----------------------------
          // 상단 좌우 이미지 섹션 (고정 높이)
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Row(
              children: [
                // 왼쪽 큰 이미지
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withAlpha(0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽 2x2 그리드 + +3 표시
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(color: Colors.grey.shade400),
                            ),
                            Expanded(
                              child: Container(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(color: Colors.grey.shade400),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                child: const Center(
                                  child: Text(
                                    '+3',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
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

          // ----------------------------
          // 상세 정보 영역 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "인원 ${challenge.participants}명",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: challenge.tags
                        .map(
                          (tag) => ChipWidget(
                            text: tag,
                            backgroundColor: Colors.green,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  InfoRow(title: "공개 여부", value: "공개 챌린지 or 그룹 내부 챌린지"),
                  const SizedBox(height: 6),
                  InfoRow(title: "챌린지 내용", value: "성공 조건"),
                  const SizedBox(height: 6),
                  InfoRow(title: "기간", value: "${challenge.day}일"),
                  const SizedBox(height: 6),
                  InfoRow(title: "인증 방식", value: "사진 인증"),
                  const SizedBox(height: 6),
                  const Text(
                    "상세 설명",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    challenge.bannerDescription ?? "상세 설명이 제공되지 않았습니다.",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 120), // 하단 버튼 여백 확보
                ],
              ),
            ),
          ),
        ],
      ),

      // ----------------------------
      // 하단 즐겨찾기 + 참여/인증 버튼
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
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
                    if (challenge.status == ChallengeStatus.inProgress) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChallengeCertificationPage(challenge: challenge),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChallengeParticipatePage(challenge: challenge),
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
    );
  }
}

// 진행도 위젯
class ProgressStatusBar extends StatelessWidget {
  final double percent;
  final int day;
  final int totalDay;
  final int remainDay;

  const ProgressStatusBar({
    super.key,
    required this.day,
    required this.totalDay,
  }) : percent = day / totalDay,
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
