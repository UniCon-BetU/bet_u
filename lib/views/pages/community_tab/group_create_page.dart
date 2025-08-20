// lib/views/pages/group_create_page.dart
import 'dart:convert';
import 'package:bet_u/utils/token_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/views/widgets/field_card_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _isPublic = true; // 공개 여부 (API 필드: isPublic)

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCrew() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse('$baseUrl/api/crews');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'crewName': name,
          'isPublic': _isPublic,
          // 태그/설명은 현재 전송하지 않음
        }),
      );

      // 성공(200/201) 가정
      if (res.statusCode == 200 || res.statusCode == 201) {
        // 서버 응답 본문 출력
        // (JSON/문자열 상관없이 우선 raw 출력)
        // debugPrint가 길면 잘려서 print도 같이 사용
        debugPrint('CREATE CREW OK: ${res.body}');
        print('CREATE CREW OK: ${res.body}');

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('그룹이 생성되었습니다.')));
        Navigator.pop(context);
      } else {
        debugPrint('CREATE CREW FAILED: ${res.statusCode} ${res.body}');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('생성 실패: ${res.statusCode}')));
      }
    } catch (e) {
      debugPrint('CREATE CREW ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('그룹 생성하기'),
        actions: [
          TextButton(
            onPressed: _createCrew,
            child: Text(
              '완료',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF34A853),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // 그룹 이름 (필수)
              FieldCardWidget(
                title: '그룹 이름',
                required: true,
                child: TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: '그룹 이름을 입력하세요',
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '그룹 이름은 필수입니다' : null,
                ),
              ),

              const SizedBox(height: 12),

              // 공개 여부
              FieldCardWidget(
                title: '공개 설정',
                subtitle: '그룹을 공개로 만들지 비공개로 만들지 선택하세요.',
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('공개 그룹'),
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
              ),

              const SizedBox(height: 12),

              // 태그 (일단 UI만, API 전송 X)
              FieldCardWidget(
                title: '태그',
                subtitle: '그룹의 주제, 목표 등을 묘사할 태그를 등록해 보세요.',
                child: TextFormField(
                  controller: _tagsCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: '#태그 형태로 입력하여 추가… (쉼표로 구분 가능)',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 그룹 설명 (멀티라인, 전송 X)
              FieldCardWidget(
                title: '그룹 설명',
                subtitle: '그룹의 목적, 구성원 등이 보게 될 설명을 입력해 주세요.',
                child: TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 8,
                  minLines: 6,
                  decoration: const InputDecoration(
                    hintText: '예) 매일 30분 러닝 인증 그룹입니다. 주 1회 리캡 게시글 작성!',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* 참고: 개발 중 인증서 이슈가 있으면 아래를 잠깐 써도 됩니다 (배포 금지)
import 'dart:io';
import 'package:http/io_client.dart';

Future<http.Client> _devClient() async {
  final ioc = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  return IOClient(ioc);
}
// 사용 예:
// final client = await _devClient();
// final res = await client.post(Uri.parse('$baseUrl/api/crews'), ...);
*/
