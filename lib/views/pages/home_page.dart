// lib/views/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/theme/app_colors.dart';
import 'package:bet_u/services/betu_challenge_loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';

// ✅ 내 챌린지 전역 상태 & 로더
import 'package:bet_u/data/my_challenges.dart';
import 'package:bet_u/services/my_challenge_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

const String kBaseHost = '54.180.150.39';
const bool kUseHttps = false; // HTTPS면 true로 바꾸세요

enum FlowStep {
  idle,
  awaitingMotivationPrompt, // 동기부여: 사용자 상태 입력 대기
  awaitingChallengeTag, // 챌린지: 태그 선택 대기
  awaitingChallengePlan, // 챌린지: 학습 계획(prompt) 입력 대기
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? items; // ADD: 추천 리스트용

  ChatMessage({required this.text, required this.isUser, this.items});
}

class _HomePageState extends State<HomePage> {
  final List<String> _tags = const [
    'EXAM',
    'UNIVERSITY',
    'TOEIC',
    'CERTIFICATE',
    'CIVIL_SERVICE',
    'LEET',
    'CPA',
    'SELF_DEVELOPMENT',
  ];
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  FlowStep _flow = FlowStep.idle;
  String? _selectedTag;

  // 네트워크 공통
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _buildUri(String path, Map<String, String> query) {
    return kUseHttps
        ? Uri.https(kBaseHost, path, query)
        : Uri.http(kBaseHost, path, query);
  }

  // 채팅: '생각 중' 자리표시 추가 및 교체 유틸
  int _pushThinking() {
    setState(() {
      _messages.add(ChatMessage(text: '배추가 생각 중...', isUser: false));
    });
    return _messages.length - 1;
  }

  void _replaceThinking(int index, String text, {List<String>? items}) {
    setState(() {
      _messages[index] = ChatMessage(text: text, isUser: false, items: items);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
  }

  Future<void> _sendMotivation(String prompt) async {
    final thinkingIdx = _pushThinking();
    try {
      final uri = _buildUri('/api/motivation/quote', {'prompt': prompt});
      final res = await http.get(uri, headers: await _authHeaders());

      if (res.statusCode == 200) {
        // 응답이 순수 텍스트라고 가정
        final body = utf8.decode(res.bodyBytes);
        _replaceThinking(thinkingIdx, body.isEmpty ? '빈 응답입니다.' : body);
      } else {
        _replaceThinking(thinkingIdx, '오류(${res.statusCode})가 발생했습니다.');
      }
    } catch (e) {
      _replaceThinking(thinkingIdx, '네트워크 오류: $e');
    } finally {
      _flow = FlowStep.idle;
    }
  }

  // ADD: 챌린지 추천 GET /api/challenges/recommend?tag=...&prompt=...
  Future<void> _sendChallengeRecommend(String tag, String prompt) async {
    final thinkingIdx = _pushThinking();
    try {
      final uri = _buildUri('/api/challenges/recommend', {
        'tag': tag,
        'prompt': prompt,
      });
      final res = await http.get(uri, headers: await _authHeaders());

      if (res.statusCode == 200) {
        final body = utf8.decode(res.bodyBytes);
        final data = jsonDecode(body);

        final titles = <String>[];
        if (data is List) {
          for (final e in data) {
            final t = e is Map<String, dynamic>
                ? (e['title'] as String?)
                : null;
            if (t != null) titles.add(t);
          }
        }
        if (titles.isEmpty) {
          _replaceThinking(thinkingIdx, '추천 결과가 없어요.');
        } else {
          _replaceThinking(thinkingIdx, '추천 챌린지 목록', items: titles);
        }
      } else {
        _replaceThinking(thinkingIdx, '오류(${res.statusCode})가 발생했습니다.');
      }
    } catch (e) {
      _replaceThinking(thinkingIdx, '네트워크 오류: $e');
    } finally {
      _selectedTag = null;
      _flow = FlowStep.idle;
    }
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
                setState(() {
                  _flow = FlowStep.awaitingMotivationPrompt;
                  _messages.add(
                    ChatMessage(
                      text:
                          '본인의 현재 상태를 알려주세요. \n예) 집중이 잘 안 돼요 / 오늘 해야 할 일이 너무 많아요',
                      isUser: false,
                    ),
                  );
                });
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
                setState(() {
                  _selectedTag = null;
                  _flow = FlowStep.awaitingChallengeTag;
                  _messages.add(
                    ChatMessage(
                      text: '현재 사용자님의 목표는 무엇인가요? 아래에서 선택해 주세요.',
                      isUser: false,
                    ),
                  );
                });
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

              // 리스트(추천 결과) 메시지인 경우
              if (msg.items != null && msg.items!.isNotEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(msg.items!.length, (i) {
                          final title = msg.items![i];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 12,
                              child: Text('${i + 1}'),
                            ),
                            title: Text(title),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }

              // 일반 텍스트 메시지
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
        // ADD: 태그 선택 단계일 때만 노출
        if (_flow == FlowStep.awaitingChallengeTag)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((t) {
                final selected = _selectedTag == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedTag = t;
                      _flow = FlowStep.awaitingChallengePlan;
                      _messages.add(
                        ChatMessage(
                          text:
                              '어떤 방식으로 공부할 계획인가요? (예: 매일 2시간 문제풀이, 주 3회 스터디 등)',
                          isUser: false,
                        ),
                      );
                    });
                  },
                );
              }).toList(),
            ),
          ),

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
                  final text = _textController.text.trim();
                  if (text.isEmpty) return;
                  _textController.clear();

                  // 사용자가 보낸 메시지로 먼저 출력
                  setState(() {
                    _messages.add(ChatMessage(text: text, isUser: true));
                  });

                  // 플로우에 따라 서버 호출
                  if (_flow == FlowStep.awaitingMotivationPrompt) {
                    _sendMotivation(text);
                  } else if (_flow == FlowStep.awaitingChallengePlan) {
                    if (_selectedTag == null) {
                      setState(() {
                        _messages.add(
                          ChatMessage(
                            text: '먼저 목표 태그를 선택해 주세요.',
                            isUser: false,
                          ),
                        );
                      });
                    } else {
                      _sendChallengeRecommend(_selectedTag!, text);
                    }
                  } else {
                    // 일반 입력일 때는 아무 작업 안 함(원하시면 에코/가이드 추가 가능)
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
