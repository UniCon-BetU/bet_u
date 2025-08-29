import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/field_card_widget.dart';
import 'package:image_picker/image_picker.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class ChipDropdownWidget extends StatelessWidget {
  const ChipDropdownWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xFF1BAB0F),
    this.foregroundColor = const Color(0xFFEFFAE8),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.required = false, // 추가: 필수 표시 여부
    this.validator, // 추가: 선택 검증
  });

  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets padding;
  final bool required;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: foregroundColor.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                if (required) ...[
                  const SizedBox(width: 2), // 텍스트와 * 사이 간격
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: foregroundColor, size: 20),
              ],
            ),
          ),
        ),
        if (required) const Padding(padding: EdgeInsets.only(left: 4)),
      ],
    );
  }
}

/// 화살표 포함 칩
class ChipDropdownFormField extends FormField<String> {
  ChipDropdownFormField({
    super.key,
    required String initialValue,
    required bool required,
    required void Function(String) onChanged,
    required List<String> options,
  }) : super(
         initialValue: initialValue,
         validator: (v) {
           if (required && (v == null || v.isEmpty || v == '공부 내용')) {
             return '태그를 선택해주세요';
           }
           return null;
         },
         builder: (field) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               ChipDropdownWidget(
                 text: field.value!,
                 onTap: () async {
                   // Dropdown logic 그대로
                   final selected = await showDialog<String>(
                     context: field.context,
                     builder: (_) => SimpleDialog(
                       children: options
                           .map(
                             (o) => SimpleDialogOption(
                               onPressed: () => Navigator.pop(field.context, o),
                               child: Text(o),
                             ),
                           )
                           .toList(),
                     ),
                   );
                   if (selected != null) {
                     field.didChange(selected);
                     onChanged(selected);
                   }
                 },
                 required: required,
               ),
               if (field.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(
                     field.errorText!,
                     style: const TextStyle(
                       color: Colors.redAccent,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _tagsInputCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final _periodCtrl = TextEditingController();

  final List<String> _selectedTags = [];
  final bool _isPublic = true;

  // Overlay용 드롭다운
  OverlayEntry? _tagOverlayEntry;
  bool _isTagDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();

  final List<String> tagOptions = [
    "EXERCISE",
    "STUDY",
    "READING",
    "CODING",
    "HABIT",
  ];

  String selectedTagText = '공부 내용';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagsInputCtrl.dispose();
    _descCtrl.dispose();
    _detailCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  Future<http.Client> _devClient() async {
    final ioc = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  void _addTag(String value) {
    final tags = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (tags.isNotEmpty) {
      setState(() {
        _selectedTags.addAll(tags.where((tag) => !_selectedTags.contains(tag)));
      });
    }
    _tagsInputCtrl.clear();
  }

  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _nameCtrl.text.trim();
    final periodDays = int.parse(_periodCtrl.text);
    final tagsString = _selectedTags.join(',');
    final description = _descCtrl.text.trim();
    final token = await TokenStorage.getToken();

    try {
      final client = await _devClient();
      final uri = Uri.parse('$baseUrl/api/challenges');
      final res = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'isPublic': _isPublic,
          'tags': tagsString,
          'description': description,
          'periodDays': periodDays,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('챌린지가 성공적으로 생성되었습니다.')));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: ${res.statusCode} ${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러: $e')));
    }
  }

  void _openTagDropdown() {
    final overlay = Overlay.of(context);
    _tagOverlayEntry = _createTagOverlayEntry();
    overlay.insert(_tagOverlayEntry!);
    setState(() => _isTagDropdownOpen = true);
  }

  void _closeTagDropdown() {
    _tagOverlayEntry?.remove();
    _tagOverlayEntry = null;
    setState(() => _isTagDropdownOpen = false);
  }

  OverlayEntry _createTagOverlayEntry() {
    RenderBox box =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: pos.dx,
        top: pos.dy + size.height + 4,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: tagOptions
                  .where((tag) => tag != selectedTagText)
                  .map(
                    (tag) => InkWell(
                      onTap: () {
                        setState(() {
                          selectedTagText = tag;
                        });
                        _closeTagDropdown();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
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
        title: const Text('챌린지 생성하기'),
        actions: [
          TextButton(
            onPressed: _createChallenge,
            child: Text(
              '생성',
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
              // 제목, 공개여부, 내용, 기간 FieldCardWidget 동일
              FieldCardWidget(
                title: '챌린지 제목',
                required: true,
                subtitle: '챌린지의 제목을 입력해주세요.',
                child: TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: '예) 스크린타임 2시간 이내 챌린지',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '제목은 필수입니다' : null,
                ),
              ),
              const SizedBox(height: 12),

              // 공개 여부

              // 챌린지 내용
              FieldCardWidget(
                title: '챌린지 내용',
                required: true,
                subtitle: '수행하여 인증해야 하는 내용을 구체적으로 설명해 주세요.',
                child: TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 8,
                  minLines: 6,
                  decoration: const InputDecoration(
                    hintText: '예) 매일 30분 러닝 인증 챌린지입니다. 주 1회 리캡 게시글 작성!',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '챌린지 내용은 필수입니다' : null,
                ),
              ),
              const SizedBox(height: 12),

              // 기간
              FieldCardWidget(
                title: '기간',
                required: true,
                subtitle: '챌린지를 수행해야 하는 기간을 설정해 주세요.',
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: _periodCtrl,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '기간',
                          border: UnderlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return '기간 입력은 필수입니다';
                          }
                          final n = int.tryParse(v);
                          if (n == null) return '숫자만 입력하세요';
                          if (n < 1) return '1일 이상이어야 합니다';
                          if (n > 180) return '최대 180일까지 가능합니다';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('일 동안 매일 수행'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              FieldCardWidget(
                title: '태그',
                required: true,
                subtitle: '챌린지의 공부 내용과 방법 등을 묘사할 태그를 등록해 주세요.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) {
                        return SelectedTagChip(
                          text: tag,
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFF6FFE9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            key: _dropdownKey,
                            onTap: () {
                              if (_isTagDropdownOpen) {
                                _closeTagDropdown();
                              } else {
                                _openTagDropdown();
                              }
                            },
                            child: ChipDropdownFormField(
                              initialValue: selectedTagText,
                              required: true,
                              options: tagOptions,
                              onChanged: (val) {
                                setState(() {
                                  selectedTagText = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _tagsInputCtrl,
                              decoration: const InputDecoration(
                                hintText: '#태그 형태로 입력하여 추가...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 5,
                                ),
                              ),
                              onSubmitted: (val) => _addTag(val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 사진 추가

              // State 안에 추가

              // 사진 추가 FieldCardWidget
              FieldCardWidget(
                childBackgroundColor: Colors.transparent, // ⬅️ 배경 제거

                title: '사진 추가하기',
                subtitle: '챌린지 내용을 설명하는 미리보기 이미지를 추가해 보세요.',
                child: SizedBox(
                  height: 120,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length + 1, // +1은 항상 추가 버튼
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // 항상 맨 앞: 추가 버튼
                        return GestureDetector(
                          onTap: () async {
                            final XFile? pickedImage = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedImage != null) {
                              setState(() {
                                _images.add(pickedImage);
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/image_add.png', // 여기 경로에 올린 이미지 넣기
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final image = _images[index - 1];
                        return Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(image.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 상세설명
              FieldCardWidget(
                title: '상세설명',
                subtitle: '챌린지의 내용, 목적, 추천하는 분들 등의 상세 설명을 입력해 보세요.',
                child: TextFormField(
                  controller: _detailCtrl,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 8,
                  minLines: 6,
                  decoration: const InputDecoration(
                    hintText: '예) 이 챌린지는 건강한 생활 습관을 위해 기획되었습니다.',
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

/// 직접 선택한 태그용 커스텀 칩
class SelectedTagChip extends StatelessWidget {
  const SelectedTagChip({
    super.key,
    required this.text,
    required this.onDeleted,
  });

  final String text;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFE9),
        borderRadius: BorderRadius.circular(20), // 완만하게 둥글게
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
