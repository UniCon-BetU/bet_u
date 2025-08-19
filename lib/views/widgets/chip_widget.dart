import 'package:flutter/material.dart';

/// 재사용 가능한 초록 칩
class ChipWidget extends StatelessWidget {
  const ChipWidget({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFF1BAB0F),
    this.foregroundColor = const Color(0xFFEFFAE8),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
