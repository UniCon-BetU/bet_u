// lib/views/pages/group_create_page.dart
import 'package:bet_u/views/widgets/field_card_widget.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: 실제 생성 로직 연결
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('그룹이 생성되었습니다.')));
      Navigator.pop(context);
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
            onPressed: _submit,
            child: Text(
              '완료',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF34A853), // 스샷 느낌의 초록색
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

              // 태그
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

              // 그룹 설명 (멀티라인)
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
