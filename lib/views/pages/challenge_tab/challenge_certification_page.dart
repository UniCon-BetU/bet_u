import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/challenge_tab/other_certification_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ChallengeCertificationPage extends StatefulWidget {
  final Challenge challenge;

  const ChallengeCertificationPage({super.key, required this.challenge});

  @override
  State<ChallengeCertificationPage> createState() =>
      _ChallengeCertificationPageState();
}

class _ChallengeCertificationPageState
    extends State<ChallengeCertificationPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCamera();
    });
  }

  // ------------------- 사진 찍기 ------------------- // 카메라 권한 거부당하면 앱이 뻗어버림!!!
  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      _showConfirmDialog();
    } else {
      if (mounted) Navigator.of(context).pop(); // 뒤로가기
    }
  }

  // ------------------- 갤러리 선택 -------------------
  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      _showConfirmDialog();
    }
  }

  // ------------------- 확인 다이얼로그 -------------------
  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("사진 확인"),
        content: _image != null
            ? Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover)
            : const Text("사진 없음"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openCamera();
            },
            child: const Text("다시 찍기"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickFromGallery();
            },
            child: const Text("갤러리에서 선택"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _submitImage();
            },
            child: const Text("완료"),
          ),
        ],
      ),
    );
  }

  // ------------------- 서버 업로드 -------------------
  Future<void> _submitImage() async {
    final token = await TokenStorage.getToken();

    if (_image == null) return;

    try {
      final url = Uri.parse(
        'https://54.180.150.39.nip.io/api/verifications/${widget.challenge.id}',
      );

      var request = http.MultipartRequest('POST', url);

      // 토큰 필요 (사용자 로그인 시 받은 access token)
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = '*/*';

      String mimeType = 'image/${_image!.path.split('.').last}';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("사진이 관리자에게 제출되었습니다.")));

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OtherCertificationPage(challenge: widget.challenge),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("제출 실패 (code: ${response.statusCode})")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("오류 발생: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _image == null
            ? const Text("카메라 실행 중...")
            : Image.file(_image!, width: 200, height: 200, fit: BoxFit.cover),
      ),
    );
  }
}
