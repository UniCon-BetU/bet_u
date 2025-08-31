import 'package:bet_u/models/group.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/theme/app_colors.dart';

/// 재사용 가능한 그룹 카드 (그룹 찾기 페이지에서도 재사용)
class GroupCardWidget extends StatefulWidget {
  final GroupInfo group;
  final VoidCallback? onTap;

  const GroupCardWidget({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  State<GroupCardWidget> createState() => _GroupCardWidgetState();
}

class _GroupCardWidgetState extends State<GroupCardWidget> {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.97); // 살짝 줄이기
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.group.icon == Icons.public ? AppColors.primaryGreen : AppColors.primaryRed;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘 배지
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.group.icon, color: accent, size: 26),
              ),
              const SizedBox(width: 12),

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      widget.group.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkerGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 멤버 수
            Column(              
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.group.memberCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                
              ],
            )
          ],
        ),
      ),
    ),
  );
}
}
