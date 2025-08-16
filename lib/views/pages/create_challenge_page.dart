import 'package:flutter/material.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  String detail = '';
  int period = 7;
  List<String> tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('챌린지 생성하기', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // 챌린지 저장 로직
              }
            },
            child: const Text(
              '생성',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 챌린지 이름
              _buildCard(
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '챌린지 이름 *',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => title = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? '챌린지 이름을 입력해주세요' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 챌린지 내용
              _buildCard(
                TextFormField(
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '챌린지 내용 *',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => content = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? '챌린지 내용을 입력해주세요' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 기간
              _buildCard(
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: '기간 *',
                    border: InputBorder.none,
                  ),
                  value: period,
                  items: [7, 14, 30]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text('$e일 동안 매일 수행'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => period = val ?? 7),
                ),
              ),
              const SizedBox(height: 16),

              // 태그
              _buildCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: '태그 추가',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            final text = _tagController.text.trim();
                            if (text.isNotEmpty) {
                              setState(() {
                                tags.add(text);
                                _tagController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.green.shade100,
                              onDeleted: () {
                                setState(() => tags.remove(tag));
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 사진 추가
              _buildCard(
                SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // 이미지 선택 로직
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                          label: const Text("사진 추가하기"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 상세 설명
              _buildCard(
                TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '상세 설명',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => detail = val,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      ),
    );
  }
}
