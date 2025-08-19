import 'package:bet_u/views/widgets/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../../models/category.dart';
import '../widgets/challenge_section_widget.dart';
import '../widgets/popular_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = const [
      Category(label: '수능', count: 1723),
      Category(label: '토익', count: 1723),
      Category(label: '인강', count: 1723),
      Category(label: '매일자습', count: 1723),
    ];

    final myChallenges = [
      Challenge(
        title: '비문학 1일 3지문',
        participants: 153,
        day: 12,
        status: ChallengeStatus.done,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '모의고사 주요과목 4합 5달성',
        participants: 524,
        day: 12,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'goal',
      ),
      Challenge(
        title: '매일 물리 사설 모의고사 1회 풀이',
        participants: 38,
        day: 9,
        status: ChallengeStatus.missed,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.done,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
      ),
    ];

    final rankingChallenges = [
      Challenge(
        title: '하루 영단어 50개 암기',
        participants: 1263,
        day: 0,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
      Challenge(
        title: '매일 수학 N제 20개 풀이',
        participants: 818,
        day: 0,
        status: ChallengeStatus.inProgress,
        category: '수능',
        createdAt: DateTime(2025, 7, 1),
        type: 'time',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            ChallengeSectionWidget(items: myChallenges),
            AdBannerWidget(imageUrl: 'assets/images/bet_u_bot.jpg'),
            PopularSectionWidget(
              categories: categories,
              ranking: rankingChallenges,
            ),
          ],
        ),
      ),
    );
  }
}
