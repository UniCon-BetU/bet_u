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
            // 📌 [API 연동] 사용자 프로필 이미지 URL이 백엔드에서 오면 NetworkImage 등으로 교체
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/lettuce_profile.png'),
            ),
            const SizedBox(height: 10),

            // 📌 [API 연동] 사용자 이름 (예: '고연오 님') 도 서버에서 받아온 데이터로 표시
            const Text(
              '고연오 님',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // 📌 [API 연동] 진행 중인 챌린지 정보 - 백엔드에서 받아와서 유동적으로 표시
            const TossStyleCard(
              title: '진행 중인 챌린지',
              description: '운동 루틴 챌린지 (D+5)', // ← API로 대체
              icon: Icons.directions_run,
            ),
            const SizedBox(height: 15),

            // 📌 [API 연동] 내 그룹 정보 - 그룹명이랑 상태 백엔드에서 받아오기
            const TossStyleCard(
              title: '내 그룹',
              description: '헬창들의 모임', // ← API로 대체
              icon: Icons.group,
            ),
            const SizedBox(height: 15),

            // 📌 [API 연동] 포인트 정보 - 포인트 값도 서버에서 받아오기
            const TossStyleCard(
              title: '포인트',
              description: '1,200 P', // ← API로 대체
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
