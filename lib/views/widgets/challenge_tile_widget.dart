import 'package:flutter/material.dart';
import '/models/challenge.dart';

class ChallengeTileWidget extends StatelessWidget {
  final Challenge c;
  final Color? background;
  final Widget? trailingOverride;

  const ChallengeTileWidget({
    super.key,
    required this.c,
    this.background,
    this.trailingOverride,
  });

  Color get bg => switch (c.status) {
    ChallengeStatus.inProgress => const Color(0xFFEFFAE8),
    ChallengeStatus.done => const Color(0xFFEFFAE8),
    ChallengeStatus.missed => const Color(0xFFEFEFEF),
  };

  IconData get trailing => switch (c.status) {
    ChallengeStatus.inProgress => Icons.check_box_outlined,
    ChallengeStatus.done => Icons.check_box,
    ChallengeStatus.missed => Icons.indeterminate_check_box,
  };

  @override
  Widget build(BuildContext context) {
    // ← 우선순위
    final Widget trailing =
        trailingOverride ??
        Icon(
          c.status == ChallengeStatus.missed
              ? Icons.indeterminate_check_box
              : Icons.check_box,
          size: 24,
          color: c.status == ChallengeStatus.done
              ? Colors.redAccent
              : Colors.black54,
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${c.participants}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DAY ${c.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
