import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // 토스 느낌 배경
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('마이페이지', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 이미지
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/lettuce_profile.png'),
            ),
            const SizedBox(height: 10),

            const Text(
              '고연오 님',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 진행 중인 챌린지
            const TossStyleCard(
              title: '진행 중인 챌린지',
              description: '운동 루틴 챌린지 (D+5)',
              icon: Icons.directions_run,
            ),
            const SizedBox(height: 15),

            // 내 그룹
            const TossStyleCard(
              title: '내 그룹',
              description: '헬창들의 모임',
              icon: Icons.group,
            ),
            const SizedBox(height: 15),

            // 포인트
            const TossStyleCard(
              title: '포인트',
              description: '1,200 P',
              icon: Icons.stars,
            ),
          ],
        ),
      ),
    );
  }
}

class TossStyleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const TossStyleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
