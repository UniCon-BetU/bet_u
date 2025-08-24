// challenge_tile_widget.dart

import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../pages/challenge_detail_page.dart';
import 'package:bet_u/data/global_challenges.dart';
// ✨ 새로 만든 전역 유틸리티 함수를 import합니다.
import 'package:bet_u/utils/recent_challenges.dart';

class ChallengeTileWidget extends StatelessWidget {
  final Challenge c;
  final VoidCallback? onTap;
  final Color? background;
  final Widget? trailingOverride;
  final bool preferImageRight;
  final bool showTags;

  const ChallengeTileWidget({
    super.key,
    required this.c,
    this.onTap,
    this.background,
    this.trailingOverride,
    this.preferImageRight = true,
    this.showTags = true,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = c.imageUrl?.trim();
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final Widget rightWidget =
        trailingOverride ??
        (preferImageRight && hasImage
            ? _imageBox(imageUrl!)
            : Icon(_trailingIcon, size: 24, color: _trailingColor));

    return SizedBox(
      height: 100,
      child: Card(
        color: background ?? _bgColor,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // ✨ 이제 onTap에서는 직접 로직을 쓰는 대신,
            // ✨ 외부에서 주입된 onTap 콜백이 있으면 그걸 실행하고
            // ✨ 없으면 기본 동작을 수행하도록 합니다.
            if (onTap != null) {
              onTap!();
            } else {
              // 기본 동작: 전역 유틸 함수 호출
              addRecentVisitedChallenge(c);

              // 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengeDetailPage(challenge: c),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
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
                            c.type == 'time' ? '${c.day}일' : '목표 달성 챌린지',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (showTags && c.tags.isNotEmpty)
                        const SizedBox(height: 4),
                      if (showTags && c.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: -2,
                          children: c.tags
                              .map(
                                (tag) => Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    height: 1.0,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (hasImage) rightWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _bgColor => const Color.fromARGB(255, 246, 255, 233);
  IconData get _trailingIcon => Icons.check_box_outline_blank;
  Color get _trailingColor => Colors.black54;

  Widget _imageBox(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => Container(
            color: const Color(0xFFF3F3F3),
            child: const Icon(
              Icons.image_not_supported,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
