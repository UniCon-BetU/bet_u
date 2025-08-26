import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SearchBarOnly extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<bool> onSearchingChanged;
  final InputDecoration decoration;
  final VoidCallback? onPlusPressed;
  final VoidCallback? onTapSearch;

  const SearchBarOnly({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onSearchingChanged,
    required this.decoration,
    this.onPlusPressed,
    this.onTapSearch,
  });

  static const double _plusHitWidth = 48;     // IconButton 최소 터치 폭
  static const double _gapBetween  = 8;       // 검색바-플러스 간격
  static const _anim = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final double reservedRight = isSearching ? 0 : (_plusHitWidth + _gapBetween);

    return SizedBox(
      height: 54,
      child: Stack(
        children: [
          // ▼ 검색바: 오른쪽 여백을 애니메이션으로  (fill 금지!)
          AnimatedPositioned(
            duration: _anim,
            curve: Curves.easeOut,
            left: 0,
            right: reservedRight,
            top: 0,
            bottom: 0,
            child: Material(
              color: AppColors.lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                onTap: () {
                  onTapSearch?.call();
                  if (!isSearching) onSearchingChanged(true);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (focusNode.canRequestFocus && !focusNode.hasFocus) focusNode.requestFocus();
                  });
                },
                decoration: decoration,
              ),
            ),
          ),

          // ▼ + 아이콘: 검색 중이면 바깥으로 슬라이드 아웃
          // 기존 AnimatedPositioned 블록 대신
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: _anim,
              curve: Curves.easeOut,
              width: isSearching ? 0 : _plusHitWidth,
              child: IgnorePointer(
                ignoring: isSearching,
                child: Padding(
                  padding: EdgeInsets.only(left: _gapBetween),
                  child: SizedBox(
                    height: 54,
                    child: IconButton(
                      iconSize: 24,
                      icon: const Icon(Icons.add_rounded, color: Colors.black),
                      onPressed: onPlusPressed,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
