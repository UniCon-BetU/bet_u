import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../../models/category.dart';
import 'category_chip_widget.dart';
import 'challenge_tile_widget.dart';

class PopularSectionWidget extends StatelessWidget {
  final List<Category> categories;
  final List<Challenge> ranking; // 상위 N개

  const PopularSectionWidget({
    super.key,
    required this.categories,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: Text(
            '오늘의 인기 CHALLENGE 🔥',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),

        // 상단 카테고리 칩 (가로 스크롤)
        SizedBox(
          height: 48,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            children: [
              CategoryChipWidget(label: '수능', count: 2536),
              CategoryChipWidget(label: '토익', count: 816),
              CategoryChipWidget(label: '인강', count: 2013),
              CategoryChipWidget(label: '매일자습', count: 1723),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 하단 랭킹 타일 (기존 ChallengeTile 재활용)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          decoration: BoxDecoration(
            color: Colors.white, // 핑크 박스 느낌
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < ranking.length; i++)
                ChallengeTileWidget(
                  c: ranking[i],
                  trailingOverride: Text(
                    '#${i + 1}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              // 도트 인디케이터가 필요하면 PageView로 감싸서 동일하게 구현 가능
            ],
          ),
        ),
      ],
    );
  }
}
