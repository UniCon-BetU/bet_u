import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/field_card_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class ChipDropdownWidget extends StatelessWidget {
  const ChipDropdownWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xFF1BAB0F),
    this.foregroundColor = const Color(0xFFEFFAE8),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.required = false,
    this.validator,
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
                  const SizedBox(width: 2),
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

  final List<String> _selectedTags = []; // 드롭다운 태그 (하나만)
  final List<String> _customTags = []; // 직접 입력 태그 (여러 개)

  // Overlay용 드롭다운
  OverlayEntry? _tagOverlayEntry;
  bool _isTagDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();

  final List<String> tagOptions = [
    'EXAM',
    'UNIVERSITY',
    'TOEIC',
    'CERTIFICATE',
    'CIVIL_SERVICE',
    'LEET',
    'CPA',
    'SELF_DEVELOPMENT',
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
        _customTags.addAll(tags);
      });
    }
    _tagsInputCtrl.clear();
  }

  // 이 함수는 더 이상 사용하지 않으므로 제거합니다.
  // Uri _buildUriWithParams({
  //   required Map<String, String> qp,
  //   required List<String> challengeTags,
  //   required List<String> customTags,
  // }) {
  //   final b = StringBuffer('$baseUrl/api/challenges?');
  //   var first = true;
  //   qp.forEach((k, v) {
  //     if (!first) b.write('&');
  //     first = false;
  //     b
  //       ..write(Uri.encodeQueryComponent(k))
  //       ..write('=')
  //       ..write(Uri.encodeQueryComponent(v));
  //   });
  //   for (final t in challengeTags) {
  //     b
  //       ..write('&challengeTags=')
  //       ..write(Uri.encodeQueryComponent(t));
  //   }
  //   for (final t in customTags) {
  //     b
  //       ..write('&customTags=')
  //       ..write(Uri.encodeQueryComponent(t));
  //   }
  //   return Uri.parse(b.toString());
  // }
  // _createChallenge 함수 내부
  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await TokenStorage.getToken();
    if (token == null) {
      debugPrint('토큰없음');

      throw Exception('로그인 토큰이 없습니다.');
    }

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final challengeName = _nameCtrl.text.trim();
    final challengeDescription = _descCtrl.text.trim();
    final periodDays = _periodCtrl.text.trim();
    final challengeDuration = int.tryParse(periodDays);
    if (challengeDuration == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기간을 정확히 입력해주세요.')));
      return;
    }

    if (_selectedTags.isEmpty && _customTags.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('태그를 최소 1개 이상 선택해주세요')));
      return;
    }

    final client = await _devClient();
    try {
      // 1. URL 쿼리 파라미터를 사용하여 URI를 직접 구성합니다.
      final uri = Uri.parse('$baseUrl/api/challenges').replace(
        queryParameters: {
          'challengeScope': 'PUBLIC',
          'challengeType': 'DURATION',
          'challengeName': challengeName,
          'challengeDescription': challengeDescription,
          'challengeDuration': challengeDuration.toString(),
          'challengeTags': _selectedTags.isNotEmpty
              ? _selectedTags.join(',')
              : '', // 콤마로 구분된 문자열로 전송
          'customTags': _customTags.isNotEmpty
              ? _customTags.join(',')
              : '', // 콤마로 구분된 문자열로 전송
        },
      );

      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['accept'] = '*/*';

      // 2. 이미지 파일만 files에 추가합니다.
      for (final x in _images) {
        if (x.path.isNotEmpty) {
          final mime = lookupMimeType(x.path) ?? 'image/jpeg';
          final parts = mime.split('/');
          req.files.add(
            await http.MultipartFile.fromPath(
              'images',
              x.path,
              contentType: MediaType(parts[0], parts[1]),
            ),
          );
        }
      }

      // 이 방식에서는 텍스트 데이터를 fields에 추가할 필요가 없습니다.
      // debugPrint에서 fields는 비어있을 것입니다.

      debugPrint('사용자 토큰: $token');
      debugPrint('요청 URI: $uri');
      debugPrint('Headers: ${req.headers}');
      debugPrint('Images: ${_images.map((e) => e.path).toList()}');
      debugPrint('챌린지 제목: $challengeName');
      debugPrint('챌린지 설명: $challengeDescription');
      debugPrint('기간: $challengeDuration');
      debugPrint('드롭다운 태그: $_selectedTags');
      debugPrint('커스텀 태그: $_customTags');
      debugPrint('선택 이미지 개수: ${_images.length}');

      final res = await client.send(req).then(http.Response.fromStream);

      if (!mounted) return;
      debugPrint('응답 상태 코드: ${res.statusCode}');
      debugPrint('응답 본문: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('챌린지가 성공적으로 생성되었습니다.')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: ${res.statusCode} ${res.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러: $e')));
    } finally {
      client.close();
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
              boxShadow: const [
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
                          if (!_selectedTags.contains(tag)) {
                            _selectedTags.clear(); // 드롭다운 태그 하나만
                            _selectedTags.add(tag);
                          }
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
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
                      children: [
                        ..._selectedTags.map((tag) {
                          return SelectedTagChip(
                            text: tag,
                            onDeleted: () {
                              setState(() {
                                _selectedTags.remove(tag);
                              });
                            },
                          );
                        }),
                        ..._customTags.map((tag) {
                          return SelectedTagChip(
                            text: tag,
                            onDeleted: () {
                              setState(() {
                                _customTags.remove(tag);
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FFE9),
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
                                  if (_selectedTags.isNotEmpty) {
                                    _selectedTags.clear();
                                  }
                                  _selectedTags.add(val);
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
              FieldCardWidget(
                childBackgroundColor: Colors.transparent,
                title: '사진 추가하기',
                subtitle: '챌린지 내용을 설명하는 미리보기 이미지를 추가해 보세요.',
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
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
                                'assets/images/image_add.png',
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
        borderRadius: BorderRadius.circular(20),
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
