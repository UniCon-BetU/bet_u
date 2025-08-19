import 'package:flutter/material.dart';

/// 화면 하단에 자주 쓰는 가로로 긴 기본 버튼
class LongButtonWidget extends StatelessWidget {
  const LongButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF1BAB0F),
    this.textColor = Colors.white,
    this.height = 52,
    this.radius = 14,
    this.leading,
    this.trailing,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double radius;
  final Widget? leading;
  final Widget? trailing;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isEnabled
        ? backgroundColor
        : backgroundColor.withValues(alpha: 0.4);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
