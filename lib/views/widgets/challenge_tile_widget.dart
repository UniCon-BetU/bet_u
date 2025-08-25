import 'package:flutter/material.dart';
import '/models/challenge.dart';
import '../../theme/app_colors.dart';
import '../../utils/challenge_history.dart';
import '../../views/pages/challenge_detail_page.dart';

/// 챌린지 타일 위젯
/// - 탭 시: 어디서든 ChallengeHistory 기록 → onTap 있으면 실행, 없으면 상세 페이지로 이동
/// - 길게/짧게 누를 때: 살짝 축소되는 프레스 애니메이션(AnimatedScale)
class ChallengeTileWidget extends StatefulWidget {
  const ChallengeTileWidget({
    super.key,
    required this.c,
    this.onTap,
    this.background,
    this.trailingOverride,
    this.preferImageRight = true,
    this.showTags = true,
    this.pressedScale = 0.97,
    this.pressedAnimDuration = const Duration(milliseconds: 90),
  });

  final Challenge c;
  final VoidCallback? onTap;
  final Color? background;
  final Widget? trailingOverride;
  final bool preferImageRight;
  final bool showTags;

  /// 눌렀을 때 축소 비율
  final double pressedScale;

  /// 프레스 애니메이션 지속시간
  final Duration pressedAnimDuration;

  @override
  State<ChallengeTileWidget> createState() => _ChallengeTileWidgetState();
}

class _ChallengeTileWidgetState extends State<ChallengeTileWidget> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  Color get _bg => switch (widget.c.status) {
    ChallengeStatus.inProgress => AppColors.lightYellow,
    ChallengeStatus.done => AppColors.lightGreen,
    ChallengeStatus.missed => AppColors.lightRed,
    ChallengeStatus.notStarted => Colors.white,
  };

  IconData get _trailingIcon => switch (widget.c.status) {
    ChallengeStatus.inProgress => Icons.check_box_outlined,
    ChallengeStatus.done => Icons.check_box,
    ChallengeStatus.missed => Icons.indeterminate_check_box,
    ChallengeStatus.notStarted => Icons.check_box_outline_blank,
  };

  Color get _trailingColor => switch (widget.c.status) {
    ChallengeStatus.done => Colors.redAccent,
    ChallengeStatus.inProgress => Colors.black54,
    ChallengeStatus.missed => Colors.black54,
    ChallengeStatus.notStarted => Colors.black54,
  };

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.c.imageUrl?.trim();
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // 오른쪽에 들어갈 위젯 우선순위:
    // 1) trailingOverride
    // 2) preferImageRight && hasImage => 이미지
    // 3) 기본 아이콘
    final Widget rightWidget =
        widget.trailingOverride ??
        (widget.preferImageRight && hasImage
            ? _imageBox(imageUrl!)
            : Icon(_trailingIcon, size: 24, color: _trailingColor));

    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: widget.pressedAnimDuration,
      curve: Curves.easeOut,
      child: Card(
        color: widget.background ?? _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Listener(
          onPointerDown: (_) => _setPressed(true),
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: InkWell(
            onTap: () async {
              // 1) 어디서든 기록
              ChallengeHistory.instance.record(widget.c);

              // 2) 라우팅: onTap 제공 시 우선, 아니면 기본 상세페이지 이동
              if (widget.onTap != null) {
                widget.onTap!();
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChallengeDetailPage(challenge: widget.c),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          widget.c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),

                        // 참여자/기간(또는 목표형)
                        Row(
                          children: [
                            const Icon(
                              Icons.people_alt_rounded,
                              size: 12,
                              color: AppColors.darkerGray,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.c.participants}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.darkerGray,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.today_rounded,
                              size: 12,
                              color: AppColors.darkerGray,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.c.type == 'time'
                                  ? '${widget.c.day} Days'
                                  : '목표 달성 챌린지',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.darkerGray,
                              ),
                            ),
                          ],
                        ),

                        // 태그
                        if (widget.showTags && widget.c.tags.isNotEmpty)
                          const SizedBox(height: 4),
                        if (widget.showTags && widget.c.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: -2,
                            children: widget.c.tags
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
      ),
    );
  }

  Color get _bgColor => const Color.fromARGB(255, 246, 255, 233);

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
