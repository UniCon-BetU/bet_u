import 'package:flutter/material.dart';
import 'challenge.dart';

class ChallengeDetailPage extends StatelessWidget {
  final Challenge challenge;

  const ChallengeDetailPage({Key? key, required this.challenge})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 원하는 도전 상세 UI를 여기서 자유롭게 구성
    return Scaffold(
      appBar: AppBar(title: Text(challenge.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('카테고리: ${challenge.category}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              '참가자 수: ${challenge.participants}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('진행 기간: ${challenge.day}일', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              '상태: ${_statusText(challenge.status)}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '생성일: ${challenge.createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              '인기도: ${challenge.popularity}',
              style: TextStyle(fontSize: 18),
            ),
            // 여기에 더 상세 내용이나 기능 추가 가능
          ],
        ),
      ),
    );
  }

  String _statusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.inProgress:
        return '진행 중';
      case ChallengeStatus.done:
        return '완료';
      case ChallengeStatus.missed:
        return '미참여';
      default:
        return '';
    }
  }
}
