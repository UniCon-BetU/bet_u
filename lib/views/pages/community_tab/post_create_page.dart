// lib/views/pages/community_tab/post_create_page.dart
import 'dart:io';
import 'package:bet_u/utils/token_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../widgets/field_card_widget.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key, this.crewId});

  final int? crewId;

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  final _picker = ImagePicker();
  final List<XFile> _images = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 92);
      if (picked.isNotEmpty) {
        setState(() => _images.addAll(picked));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 선택 실패: $e')));
    }
  }

  Future<void> _submitPost() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력하세요')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력하세요')));
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    // 요청: POST /api/community/posts?title=...&content=...
    // 바디: multipart/form-data (images[]=... 반복)
    try {
      final uri = Uri.parse('$baseUrl/api/community/posts').replace(
        queryParameters: {
          if (widget.crewId != null) 'crewId': widget.crewId.toString(),
          'title': title,
          'content': content,
        },
      );

      final req = http.MultipartRequest('POST', uri);

      // Authorization만 세팅 (Content-Type 세팅 금지)
      final token = await TokenStorage.getToken();
      req.headers['Authorization'] = 'Bearer $token';

      // 이미지 파트 추가 (필드명: images)
      for (final x in _images) {
        req.files.add(await http.MultipartFile.fromPath('images', x.path));
      }
      // _images가 비어있어도 전송 가능하게 하려면(서버가 빈 images 허용 시):
      // if (_images.isEmpty) req.fields['images'] = '';

      // ----- 디버깅용 로그 -----
      debugPrint('REQ URL: ${req.url}');
      debugPrint(
        'REQ HEADERS: ${{...req.headers, 'Authorization': 'Bearer ***${token?.substring(token.length - 6)}'}}',
      );
      debugPrint('REQ FILE COUNT: ${req.files.length}');

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      debugPrint('RESP STATUS: ${res.statusCode}');
      debugPrint('RESP BODY: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 등록되었습니다')));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${res.statusCode} ${res.body}')),
        );
      }
    } catch (e) {
      debugPrint('CREATE POST ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F9E8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('글쓰기', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text(
              '등록',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            FieldCardWidget(
              title: '제목',
              required: true,
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FieldCardWidget(
              title: '내용',
              required: true,
              child: TextField(
                controller: _contentCtrl,
                minLines: 6,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요…',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FieldCardWidget(
              title: '사진 추가하기',
              subtitle: '파일 업로드',
              child: _PhotoGrid(
                images: _images,
                onAddTap: _pickImages,
                onRemoveTap: (i) => setState(() => _images.removeAt(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAddTap;
  final void Function(int index) onRemoveTap;

  const _PhotoGrid({
    required this.images,
    required this.onAddTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    const double tileSize = 84;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (int i = 0; i < images.length; i++)
          Stack(
            clipBehavior: Clip.none,
            children: [
              _SquareTile(
                size: tileSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(images[i].path),
                    fit: BoxFit.cover,
                    width: tileSize,
                    height: tileSize,
                  ),
                ),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: Material(
                  color: Colors.black87,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onRemoveTap(i),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        _SquareTile(
          size: tileSize,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAddTap,
            child: const Center(
              child: Icon(Icons.add, size: 28, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}

class _SquareTile extends StatelessWidget {
  final double size;
  final Widget child;

  const _SquareTile({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
