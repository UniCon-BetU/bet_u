import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stats,
  });

  static const primaryGreen = Color(0xFF1BAB0F);

  final String title; // 닉네임
  final String subtitle; // 코멘트/하위 텍스트
  final List<StatItemData> stats; // 통계 리스트

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ 타이틀 블록
          Expanded(
            child: _TitleBlock(title: title, subtitle: subtitle),
          ),
          if (stats.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  _StatItem(label: stats[i].label, value: stats[i].value),
                  if (i != stats.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            height: 1.05
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.1
          ),
        ),
      ],
    );
  }
}

// ✅ 통계 아이템 데이터 클래스
class StatItemData {
  final String label;
  final String value;

  StatItemData({required this.label, required this.value});
}
