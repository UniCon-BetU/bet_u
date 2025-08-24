import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/views/pages/challenge_detail_page.dart';
import 'package:bet_u/data/global_challenges.dart';

void main() {
  final Challenge challenge = betuChallenges[0]; // 예시: 첫 번째 챌린지

  runApp(MaterialApp(home: OtherCertificationPage(challenge: challenge)));
}

class OtherCertificationPage extends StatefulWidget {
  final Challenge challenge; // Challenge 객체 통째로 받기

  const OtherCertificationPage({
    super.key,
    required this.challenge, // Challenge 타입
  });

  @override
  State<OtherCertificationPage> createState() => _OtherCertificationPageState();
}

class _OtherCertificationPageState extends State<OtherCertificationPage> {
  final List<Map<String, dynamic>> submissions = [
    {
      "user": "사용자1",
      "imageUrl": "https://picsum.photos/id/1011/400/300",
      "day": 5,
    },
    {
      "user": "사용자2",
      "imageUrl": "https://picsum.photos/id/1025/400/300",
      "day": 5,
    },
    {
      "user": "사용자3",
      "imageUrl": "https://picsum.photos/id/1035/400/300",
      "day": 5,
    },
  ];

  int currentIndex = 0;

  void _handleClick(bool suspicious) {
    final current = submissions[currentIndex];

    if (suspicious) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("신고 완료! 소정의 포인트 지급")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("정상 확인, 포인트 지급")));
    }

    _nextPhoto();
  }

  void _skipReview() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailPage(
          challenge: widget.challenge, // widget.challenge로 전달
        ),
      ),
    );
  }

  void _nextPhoto() {
    setState(() {
      currentIndex++;
      if (currentIndex >= submissions.length) {
        _skipReview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= submissions.length) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    final submission = submissions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.challenge.title} 인증 확인 (${currentIndex + 1}/${submissions.length})",
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 80),

          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                "도전 인증사진인지 판단해주시면\n포인트를 드려요!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // 👉 가운데 정렬
              ),
            ),
          ),
          SizedBox(height: 30, width: 50),
          Stack(
            alignment: Alignment.center,
            children: [
              // 1️⃣ 원본 이미지 (클릭 가능)
              GestureDetector(
                onTap: _showConfirmDialog,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    submission["imageUrl"],
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2️⃣ 액자 이미지 (클릭 이벤트 무시)
              IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(20, 25), // 오른쪽 20, 아래 25
                  child: Transform.scale(
                    scale: 1.4,
                    child: Image.asset(
                      'images/frame.png',
                      width: 250,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50, width: 50),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
            child: LongButtonWidget(
              text: "건너뛰기",
              onPressed: _skipReview,
              backgroundColor: Colors.green, // 필요시 색 바꾸기
              textColor: Colors.black, // 필요시 텍스트 색 바꾸기
            ),
          ),

          SizedBox(height: 30, width: 50),
        ],
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("사진 확인"),
        content: const Text("이 사진이 의심스러운가요?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleClick(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green, // ✅ 텍스트 색 초록색
            ),
            child: const Text("의심 신고"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleClick(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green, // ✅ 텍스트 색 초록색
            ),
            child: const Text("이상 없음"),
          ),
        ],
      ),
    );
  }
}
