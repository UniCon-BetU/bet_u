import 'package:flutter/material.dart';

class AdBannerWidget extends StatelessWidget {
  final String imageUrl;
  const AdBannerWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // image: DecorationImage(
        //   image: AssetImage(imageUrl), // Asset 사용 시 AssetImage로 변경
        //   fit: BoxFit.cover,
        // ),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // 초록 톤 광고 느낌
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              '래피드 단기 도전 바로가기!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
