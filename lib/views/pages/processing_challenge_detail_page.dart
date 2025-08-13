import 'package:flutter/material.dart';
import 'challenge.dart';
import 'package:bet_u/views/pages/challenge_participate_page.dart';

class ProcessingChallengeDetailPage extends StatelessWidget {
  final Challenge challenge;

  const ProcessingChallengeDetailPage({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isInProgress = challenge.status == ChallengeStatus.inProgress;
    final isMissed = challenge.status == ChallengeStatus.missed;

    return Scaffold(
      appBar: AppBar(title: Text(challenge.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 이미지 or 이미지 박스 자리 (이미지는 임의 색상박스로 대체)
            Container(
              height: 150,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              challenge.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              '인원 ${challenge.participants}명',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'freesentation',
              ),
            ),
            const SizedBox(height: 8),

            // 태그들 (예시로 category 위주, 필요시 추가)
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text(challenge.category)),
                Chip(label: const Text('인강진도')),
                Chip(label: const Text('국어')),
              ],
            ),
            const SizedBox(height: 16),

            // 진행도 표시 (예: 37% 등)
            if (isInProgress) ...[
              Text('챌린지 진행도', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: 0.37, // 실제 데이터 기반으로 수정 가능
                color: Colors.red,
                backgroundColor: Colors.grey.shade300,
                minHeight: 8,
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '성공까지 D-${challenge.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // 공개 여부, 기간, 인증 방식 등 텍스트
              Text('공개 여부: 공개 챌린지'),
              Text('챌린지 행동: 성공 조건'),
              Text('기간: ${challenge.day}일'),
              Text('인증 방식: 인증 방식'),

              const SizedBox(height: 12),

              // 상세 설명 (더미 텍스트)
              const Text(
                '상세 설명\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              ),

              const Spacer(),

              // 인증하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('인증하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // 인증하기 버튼 클릭 시 동작 카메라 창 구현
                  },
                ),
              ),
            ] else if (isMissed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),

              // 공개 여부, 기간, 인증 방식 등 텍스트
              Text('공개 여부: 공개 챌린지'),
              Text('챌린지 행동: 성공 조건'),
              Text('기간: ${challenge.day}일'),
              Text('인증 방식: 인증 방식'),

              const SizedBox(height: 12),

              // 상세 설명 (더미 텍스트)
              const Text('상세 설명: 이건 누가 만들었으며 상시모집이고 기간 인증은 24시 기준으로 돌아간다.'),

              const Spacer(),

              // 인증하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('도전하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChallengeParticipatePage(challenge: challenge),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // 상태가 done 등 다른 경우 처리 가능
              const Text('챌린지가 완료되었습니다.'),
            ],
          ],
        ),
      ),
    );
  }
}
