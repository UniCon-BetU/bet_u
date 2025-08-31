import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import '../challenge_tab/challenge_detail_page.dart';

// ✅ 내 챌린지 전역 상태 import
import 'package:bet_u/data/my_challenges.dart';
import 'package:bet_u/services/my_challenge_loader.dart';

class MyChallengePage extends StatefulWidget {
  const MyChallengePage({super.key});

  @override
  State<MyChallengePage> createState() => _MyChallengePageState();
}

class _MyChallengePageState extends State<MyChallengePage> {
  @override
  void initState() {
    super.initState();
    // 페이지 들어올 때 최신 데이터 가져오기
    MyChallengeLoader.loadAndPublish(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('진행 중 챌린지')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<List<Challenge>>(
          valueListenable: myChallengesNotifier,
          builder: (context, challenges, _) {
            final inProgress = challenges
                .where((c) => c.status == ChallengeStatus.inProgress)
                .toList();

            if (MyChallengeLoader.isLoading && challenges.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (inProgress.isEmpty) {
              return const Center(
                child: Text(
                  '진행 중인 챌린지가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              itemCount: inProgress.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final challenge = inProgress[index];
                return ChallengeTileWidget(
                  c: challenge,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChallengeDetailPage(challenge: challenge),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
