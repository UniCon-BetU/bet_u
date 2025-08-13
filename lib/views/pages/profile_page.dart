import 'package:bet_u/views/pages/global_challenges.dart';
import 'package:bet_u/views/pages/my_challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/point_page.dart';

class ProfilePage extends StatelessWidget {
  final bool hasChallenge = true;
  final bool hasGroup = false;
  final String currentChallenge = '공부 루틴 챌린지 등 1건';
  final String currentGroup = '강대 5반';
  final int points = 1200;

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileHeader(
              points: points,
              userName: '고연오 님',
              ongoingChallengesCount: hasChallenge ? 1 : 0,
              onChargePressed: () {
                Navigator.pushNamed(context, '/charge'); // 충전소 이동 경로
              },
            ),
            const SizedBox(height: 30),

            if (hasChallenge)
              TossStyleCard(
                title: '진행 중인 챌린지',
                description: currentChallenge,
                icon: Icons.directions_run,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyChallengePage(
                        myChallenges: betuChallenges,
                      ), // 전역 리스트 or 진행중 필터링한 리스트 넣기
                    ),
                  );
                },
              )
            else
              Column(
                children: [
                  const Text('아직 진행중인 챌린지가 없어요'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/challenge');
                    },
                    child: const Text('챌린지 시작하기'),
                  ),
                ],
              ),
            const SizedBox(height: 30),

            if (hasGroup)
              TossStyleCard(
                title: '내 그룹',
                description: currentGroup,
                icon: Icons.group,
                onTap: () {
                  Navigator.pushNamed(context, '/community');
                },
              )
            else
              Column(
                children: [
                  const Text('아직 그룹이 없어요'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/community');
                    },
                    child: const Text('그룹 찾기'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final int points;
  final String userName;
  final int ongoingChallengesCount;
  final VoidCallback onChargePressed;

  const ProfileHeader({
    super.key,
    required this.points,
    required this.userName,
    required this.ongoingChallengesCount,
    required this.onChargePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/lettuce_profile.png'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '참여중인 챌린지 $ongoingChallengesCount개',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text('포인트: $points P', style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PointPage()),
                );
              },
              tooltip: '포인트 충전',
            ),
          ],
        ),
      ],
    );
  }
}

class TossStyleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const TossStyleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
