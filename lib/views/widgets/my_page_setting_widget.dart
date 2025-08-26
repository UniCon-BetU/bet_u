import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MyPageSettingWidget extends StatelessWidget {
  const MyPageSettingWidget({
    super.key,
    required this.title,
    this.icon, // Material Icon
    this.image, // ImageProvider
    this.point,
    this.onTap,
  });

  final String title;
  final IconData? icon;
  final ImageProvider? image;
  final String? point;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, size: 24, color: Colors.black)
            else if (image != null)
              Image(image: image!, width: 24, height: 24),
            if (icon != null || image != null) const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            if (point != null)
              Card(
                color: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Center(
                    child: Text(
                      point!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
