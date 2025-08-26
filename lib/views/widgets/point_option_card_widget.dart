import 'package:flutter/material.dart';

class PointOptionCard extends StatelessWidget {
  final int points; // 포인트
  final int amount; // 결제 금액
  final int? bonus; // 보너스 포인트
  final String? imagePath; // 우측 이미지
  final String? backgroundImagePath; // 배경 이미지
  final VoidCallback? onTap;
  final bool isSelected; // 선택 여부

  const PointOptionCard({
    super.key,
    required this.points,
    required this.amount,
    this.bonus,
    this.imagePath,
    this.backgroundImagePath,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white, // 기본 배경색
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFF1BAB0F), width: 2)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            image: backgroundImagePath != null
                ? DecorationImage(
                    image: AssetImage(backgroundImagePath!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Row(
            children: [
              // 좌측 텍스트 영역
              // 좌측 텍스트 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12), // 좌우 여백
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${points.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} P',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (bonus != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '+${bonus}P BONUS',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}₩',
                        style: const TextStyle(
                          color: Color(0xFF1BAB0F),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 우측 이미지 영역
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath!,
                    fit: BoxFit.cover, // 카드 높이에 꽉 차도록
                    height: double.infinity,
                    width: 88, // 필요에 따라 고정 폭
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
