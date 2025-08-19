// lib/views/widgets/field_card_widget.dart
import 'package:flutter/material.dart';

/// 제목 + (선택) 부제목 + 내용 위젯을 감싸는 재사용 카드
class FieldCardWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool required;

  const FieldCardWidget({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F8), // 배경
        borderRadius: BorderRadius.circular(14),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 10,
        //     offset: Offset(0, 6),
        //   ),
        // ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 라인
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                height: 1.2,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 입력 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAE8), // 텍스트필드 배경색
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
