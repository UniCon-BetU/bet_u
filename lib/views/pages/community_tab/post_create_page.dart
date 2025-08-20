// lib/views/pages/community_tab/post_create_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as p;
import '../../widgets/field_card_widget.dart';
import 'package:bet_u/utils/token_util.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class PostCreatePage extends StatefulWidget {
  const PostCreatePage({super.key});

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  // 제목은 당분간 UI만 유지하고 전송은 안 함
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // 선택한 이미지들
  final List<XFile> _images = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 90);
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
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
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

    try {
      final uri = Uri.parse('$baseUrl/api/community/posts');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': content,
          // 태그/설명은 현재 전송하지 않음
        }),
      );

      // 이미지 파일 첨부 (필드명: images)
      // for (final x in _images) {
      //   // 서버 스웨거가 배열로 정의되어 있으므로 같은 키로 여러 번 첨부
      //   req.files.add(
      //     await http.MultipartFile.fromPath(
      //       'images', // 중요: 서버에서 기대하는 필드명
      //       x.path,
      //       filename: x.name.isNotEmpty ? x.name : p.basename(x.path),
      //     ),
      //   );
      // }

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
            // 제목 (UI만, 서버 전송 X)
            FieldCardWidget(
              title: '글 제목을 작성해주세요.',
              required: false,
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'BETU 메이트들과 함께 이야기를 나눠보세요.',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 내용
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

            // 사진 추가
            FieldCardWidget(
              title: '사진 추가하기',
              subtitle: '글에 사진을 추가해 보세요.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PhotoGrid(
                    images: _images,
                    onAddTap: _pickImages,
                    onRemoveTap: (index) =>
                        setState(() => _images.removeAt(index)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 사진 그리드 + 추가 아이콘 셀
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

        // 추가 아이콘
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
