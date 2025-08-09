import 'package:flutter/material.dart';

class CategoryChipWidget extends StatelessWidget {
  final String label;
  final int count;
  const CategoryChipWidget({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2DBA41),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.people, size: 14, color: Colors.white),
          Text(
            ' $count',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}