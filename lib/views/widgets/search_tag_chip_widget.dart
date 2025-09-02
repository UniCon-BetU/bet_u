import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// 2) 칩만 그리는 위젯
class CategoryChipsBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Map<String, String>> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const CategoryChipsBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Size get preferredSize => const Size.fromHeight(44); // 칩 높이

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final isSelected = selected == cat["tag"];
            return GestureDetector(
              onTap: () => onSelect(cat["tag"]!),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat["name"]!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
