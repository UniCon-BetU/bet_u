import 'package:bet_u/views/pages/point_page.dart';
import 'package:flutter/material.dart';

class PointbuttonWidget extends StatelessWidget {
  const PointbuttonWidget({super.key, required this.point});

  final int point;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PointPage();
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent, // 연한 연두색 배경
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$point P',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
