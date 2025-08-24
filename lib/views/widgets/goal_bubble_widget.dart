import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Center(
          child: GoalBubbleWidget(
            text: '성공까지 D-4',
            color: Colors.red,
            pointerHeight: 8,
            pointerWidth: 16,
            borderRadius: 100,
          ),
        ),
      ),
    );
  }
}

/// 재사용 가능한 Goal Bubble 위젯 (수정됨)
class GoalBubbleWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double pointerHeight;
  final double pointerWidth;
  final double borderRadius;

  const GoalBubbleWidget({
    super.key,
    required this.text,
    this.color = Colors.red,
    this.pointerHeight = 6,
    this.pointerWidth = 9,
    this.borderRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter, // 포인터를 아래쪽으로 정렬
      clipBehavior: Clip.none,
      children: [
        // 말풍선 본체
        Container(
          padding: EdgeInsets.symmetric(horizontal: pointerWidth, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(40), // 모서리 거의 없는 직사각형
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // 아래쪽 정삼각형 포인터
        Positioned(
          bottom: -pointerHeight, // 말풍선 본체 아래로 배치
          child: CustomPaint(
            size: Size(pointerWidth, pointerHeight),
            painter: _TrianglePainter(color: color),
          ),
        ),
      ],
    );
  }
}

/// 삼각형 포인터 그리는 Painter (수정됨)
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0); // 왼쪽 위
    path.lineTo(size.width / 2, size.height); // 꼭짓점
    path.lineTo(size.width, 0); // 오른쪽 위
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
