import 'package:flutter/material.dart';

class GroupManagementPage extends StatelessWidget {
  const GroupManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 관리')),
      body: const Center(
        child: Text(
          '그룹 관리 UI가 여기에 표시됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
