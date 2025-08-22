import 'package:flutter/material.dart';
import '/models/challenge.dart';

/// 하나로 합친 챌린지 타일 위젯:
/// - 오른쪽 영역: trailingOverride > (preferImageRight && image) > 기본 아이콘
/// - 배경색: 외부에서 주입 없으면 상태 기반(bg 게터)
/// - 태그 표시, 참여자/기간(또는 목표형) 표시
/// - 탭 동작은 onTap으로 주입 (라우팅 분리)
class ChallengeTileWidget extends StatelessWidget {
  final Challenge c;
  final VoidCallback? onTap;
  final Color? background;

  /// 오른쪽 영역에 우선적으로 렌더링할 위젯 (ex. 순위 뱃지)
  final Widget? trailingOverride;

  /// 오른쪽에 이미지 우선 표시 여부 (기본값 true)
  /// trailingOverride가 있으면 이 값과 상관없이 trailingOverride가 우선됨.
  final bool preferImageRight;

  /// 해시태그 보이기 (기본값 true)
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

  Color get bg => switch (c.status) {
    ChallengeStatus.inProgress => const Color.fromARGB(255, 246, 255, 233),
    ChallengeStatus.done => const Color.fromARGB(255, 246, 255, 233),
    ChallengeStatus.missed => const Color.fromARGB(255, 246, 255, 233),
    ChallengeStatus.notStarted => const Color.fromARGB(255, 246, 255, 233),
  };

  IconData get trailingIcon => switch (c.status) {
    ChallengeStatus.inProgress => Icons.check_box_outlined,
    ChallengeStatus.done => Icons.check_box,
    ChallengeStatus.missed => Icons.indeterminate_check_box,
    ChallengeStatus.notStarted => Icons.check_box_outline_blank,
  };

  Color get trailingColor => switch (c.status) {
    ChallengeStatus.done => Colors.redAccent,
    ChallengeStatus.inProgress => Colors.black54,
    ChallengeStatus.missed => Colors.black54,
    ChallengeStatus.notStarted => Colors.black54,
  };

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = c.imageUrl?.trim();
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // 오른쪽에 들어갈 위젯 우선순위:
    // 1) trailingOverride
    // 2) preferImageRight && hasImage => 이미지
    // 3) 기본 아이콘
    final Widget rightWidget =
        trailingOverride ??
        (preferImageRight && hasImage
            ? _imageBox(imageUrl)
            : Icon(trailingIcon, size: 24, color: trailingColor));

    return SizedBox(
      height: 100,
      child: Card(
        color: background ?? bg,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
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

                      // 참여자/기간(또는 목표형)
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
                      // 태그
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
                rightWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

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
