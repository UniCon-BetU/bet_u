import 'package:bet_u/views/widgets/ad_banner.dart';
import 'package:flutter/material.dart';
import '../../models/challenge.dart';
import '../widgets/challenge_section_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            MyChallengesSection(
              items: [
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
                  status: ChallengeStatus.done,
                ),
                Challenge(
                  title: '수능 국어 1일 3지문',
                  participants: 1723,
                  day: 12,
                  status: ChallengeStatus.missed,
                ),
                // 필요하면 더 추가
              ],
            ),
            AdBanner(imageUrl: 'assets/images/bet_u_bot.jpg'),
          ],
        ),
      ),
    );
  }
}
