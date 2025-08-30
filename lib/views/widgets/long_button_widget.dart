import 'package:flutter/material.dart';

/// 화면 하단에 자주 쓰는 가로로 긴 기본 버튼
class LongButtonWidget extends StatefulWidget {
  const LongButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 44,
    this.radius = 11,
    this.leading,
    this.trailing,
    this.isEnabled = true,
    this.pressedScale = 0.97, // 눌렀을때 작아지기
    this.pressedAnimDuration = const Duration(milliseconds: 80),
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double radius;
  final Widget? leading;
  final Widget? trailing;
  final bool isEnabled;
  final VoidCallback? onPressed; // ← 여기

  final double pressedScale;
  final Duration pressedAnimDuration;

  @override
  State<LongButtonWidget> createState() => _LongButtonWidgetState();
}

class _LongButtonWidgetState extends State<LongButtonWidget> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (!widget.isEnabled || widget.onPressed == null) return; // ← 비활성일 땐 무시
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.isEnabled && widget.onPressed != null
        ? widget.backgroundColor
        : widget.backgroundColor.withValues(alpha: 0.4);
    
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.pressedAnimDuration,
        curve: Curves.easeOut,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: FilledButton(
            // isEnabled && onPressed != null 일 때만 활성화
            onPressed: (widget.isEnabled ? widget.onPressed : null),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(effectiveColor),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (!widget.isEnabled || widget.onPressed == null) return null;

                if (states.contains(WidgetState.pressed)) {
                  return Colors.black.withValues(alpha: 0.06);
                }

                if (states.contains(WidgetState.hovered)) {
                  return Colors.black.withValues(alpha: 0.04);
                }

                return null;
              }),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
