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
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.done,
      ),
      Challenge(
        title: '수능 영어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.missed,
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.done,
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
      ),
    ];

    final rankingChallenges = [
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
      ),
      Challenge(
        title: '수능 국어 1일 3지문',
        participants: 1723,
        day: 12,
        status: ChallengeStatus.inProgress,
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
