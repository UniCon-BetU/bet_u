import 'package:flutter/material.dart';
import '/models/challenge.dart';
import '../../theme/app_colors.dart';
import '../../utils/challenge_history.dart';
import '../pages/challenge_tab/challenge_detail_page.dart';

/// 챌린지 타일 위젯
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
  final double pressedScale;
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

  /// 카드 배경색
  Color get _bg {
    if (widget.c.status != ChallengeStatus.inProgress) { return Colors.white; }
    else {
      if (widget.c.type == 'time') {
        return switch (widget.c.todayCheck) {
          TodayCheck.notStarted => AppColors.lightRed,
          TodayCheck.waiting => AppColors.lightYellow,
          TodayCheck.done => AppColors.lighterGreen,
        };
      } else { return AppColors.lighterGreen; }
    }
  
    // if (widget.c.type == 'goal') {
    //   return switch (widget.c.status) {
    //     ChallengeStatus.notStarted => AppColors.lighterGreen,
    //     ChallengeStatus.inProgress => const Color(0xFFEAFFB9),
    //     ChallengeStatus.done => AppColors.lighterGreen, //지워
    //     ChallengeStatus.missed => AppColors.lightRed, //지워
    //   };
    // }

    // if (widget.c.type == 'time') {
    //   return switch (widget.c.status) {
    //     ChallengeStatus.notStarted => AppColors.lighterGreen,
    //     ChallengeStatus.inProgress => const Color(0xFFEAFFB9),
    //     ChallengeStatus.done => AppColors.lighterGreen, //지워
    //     ChallengeStatus.missed => AppColors.lightRed, //지워
    //   };
    // }
    // if (widget.c.type == 'time') {
    //   return switch (widget.c.todayCheck) {
    //     TodayCheck.notStarted => AppColors.lightRed,
    //     TodayCheck.waiting => AppColors.yellowGreen,
    //     TodayCheck.done => const Color(0xFFEAFFB9), //지워
    //   };
    // }
    // return const Color.fromRGBO(234, 255, 185, 1);
  }

  /// 참여자/기간 칸 색상

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.c.imageUrl?.trim();
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final int day = widget.c.progressDays ?? 0;
    final int totalDay = widget.c.day ?? 1;
    final double percent = totalDay > 0 ? day / totalDay : 0;

    final Widget? lettuceImage =
        widget.c.status == ChallengeStatus.notStarted && widget.c.type == 'time'
        ? null
        : Image.asset(
            percent * 100 <= 30
                ? 'assets/images/normal_lettuce.png'
                : percent * 100 <= 70
                ? 'assets/images/happy_lettuce.png'
                : 'assets/images/red_lettuce.png',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          );

    final Widget rightWidget =
        widget.trailingOverride ??
        (() {
          if (widget.c.type == 'time') {
            // time 타입: 진행중이면 배추, 시작 전이면 빈 박스
            return widget.c.status == ChallengeStatus.notStarted
                ? const SizedBox.shrink()
                : lettuceImage ?? const SizedBox.shrink();
          } else if (widget.c.type == 'goal') {
            // goal 타입: 시작 전이면 빈 박스, 진행중/완료/놓친 경우 트로피
            return widget.c.status == ChallengeStatus.notStarted
                ? const SizedBox.shrink()
                : Image.asset(
                    'assets/images/trophy.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
          } else {
            return const SizedBox.shrink();
          }
        })();

    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: widget.pressedAnimDuration,
      curve: Curves.easeOut,
      child: Card(
        color: widget.background ?? _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onHighlightChanged: (isDown) => _setPressed(isDown),
          onTap: () async {
            ChallengeHistory.instance.record(widget.c);
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
          child: SizedBox(
            height: widget.showTags ? 70 : 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Row(
                          children: [
                            // 참여자
                            // 참여자
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // ← 고정 회색
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.people_alt_rounded,
                                    size: 12,
                                    color: Color.fromARGB(255, 75, 75, 75),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.c.participants}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 75, 75, 75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // 기간/목표
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // ← 고정 회색
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.today_rounded,
                                    size: 12,
                                    color: Color.fromARGB(255, 75, 75, 75),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.c.type == 'time'
                                        ? '${widget.c.day} Days'
                                        : '목표 달성 챌린지',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 75, 75, 75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // ← 고정 회색
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    widget.c.todayCheck == 'notstarted'
                                        ? Icons.hourglass_empty
                                        : widget.c.todayCheck == 'waiting'
                                        ? Icons.access_time
                                        : Icons.check_circle,
                                    size: 12,
                                    color: const Color.fromARGB(
                                      255,
                                      75,
                                      75,
                                      75,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.c.todayCheck == 'notstarted'
                                        ? '인증 전'
                                        : widget.c.todayCheck == 'waiting'
                                        ? '대기중'
                                        : '인증완료',

                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 75, 75, 75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.showTags && widget.c.tags.isNotEmpty)
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
                ),
                if (rightWidget is! SizedBox)
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(11),
                        bottomRight: Radius.circular(11),
                      ),
                      child: rightWidget,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageBox(String url) {
    return Image.network(
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
    );
  }
}
