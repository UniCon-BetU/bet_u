// lib/views/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/services/betu_challenge_loader.dart';

// ✅ 내 챌린지 전역 상태 & 로더
import 'package:bet_u/data/my_challenges.dart';
import 'package:bet_u/services/my_challenge_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class ChatMessage {
  final String text;
  final bool isUser; // 내가 보낸 건지, 배추(서버)에서 온 건지

  ChatMessage({required this.text, required this.isUser});
}

class _HomePageState extends State<HomePage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });

    // TODO: 여기서 백엔드 호출 → 응답 메시지를 추가
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(text: "서버 응답 예시: '$text'에 대한 답변!", isUser: false),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // 앱 첫 진입 시 챌린지 로드
    BetuChallengeLoader.loadAndPublish(context: context); // BETU 챌린지
    MyChallengeLoader.loadAndPublish(context: context); // 내 챌린지
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Challenge>>(
      valueListenable: myChallengesNotifier, // ✅ 내 챌린지 기준으로 UI 구성
      builder: (context, myChallenges, _) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 64,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/normal_lettuce.png',
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                      Image.asset(
                        'assets/images/BETU_letters.png',
                        width: 96,
                        height: 48,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: _messages.isEmpty ? _buildInitialView() : _buildChatView(),
          ),
        );
      },
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: FittedBox(
              child: Image.asset(
                'assets/images/betu_happy.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            '어디서 시작할지 모르겠나요?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen, // ✅ 배추 느낌나는 색상
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '배추에게 물어보세요!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: ElevatedButton.icon(
              onPressed: () {
                _addUserMessage("동기부여가 필요해요");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.emoji_emotions,
                color: Colors.white,
              ), // 동기부여 느낌
              label: const Text(
                '동기부여가 필요해요',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ 두 번째 버튼
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: ElevatedButton.icon(
              onPressed: () {
                _addUserMessage("챌린지 추천이 필요해요");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
              ), // 챌린지 추천 느낌
              label: const Text(
                '챌린지 추천이 필요해요',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppColors.primaryGreen
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 입력창
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "메시지를 입력하세요...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _addUserMessage(_textController.text.trim());
                    _textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}