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
        image: DecorationImage(
          image: AssetImage(imageUrl), // Asset 사용 시 AssetImage로 변경
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
