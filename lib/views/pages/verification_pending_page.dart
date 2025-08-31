import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/utils/token_util.dart';

//관리자 페이지 - 인증 대기 목록
class VerificationPendingPage extends StatefulWidget {
  const VerificationPendingPage({super.key});

  @override
  State<VerificationPendingPage> createState() =>
      _VerificationPendingPageState();
}

class _VerificationPendingPageState extends State<VerificationPendingPage> {
  List<dynamic> pendingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingVerifications();
  }

  Future<void> fetchPendingVerifications() async {
    setState(() => isLoading = true);
    final token = await TokenStorage.getToken();

    try {
      final res = await http.get(
        Uri.parse('https://54.180.150.39.nip.io/api/verifications/pending'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          pendingList = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching pending: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<void> updateVerification(int imageId, String action) async {
    setState(() => isLoading = true);
    final token = await TokenStorage.getToken();

    try {
      final res = await http.post(
        Uri.parse(
          'https://54.180.150.39.nip.io/api/verifications/$imageId/$action',
        ),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action 완료')));
        fetchPendingVerifications();
      } else {
        throw Exception('Failed: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error updating verification: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('인증 대기 목록')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingList.isEmpty
          ? const Center(child: Text('대기 중인 인증이 없습니다.'))
          : ListView.builder(
              itemCount: pendingList.length,
              itemBuilder: (context, index) {
                final item = pendingList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: item['imageUrl'] != null
                        ? Image.network(
                            item['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(item['challengeName'] ?? '챌린지 없음'),
                    subtitle: Text(
                      '참가자: ${item['userName'] ?? '알 수 없음'}\n'
                      '업로드: ${item['uploadedAt'] ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              updateVerification(item['imageId'], 'approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('승인'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              updateVerification(item['imageId'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('거절'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
