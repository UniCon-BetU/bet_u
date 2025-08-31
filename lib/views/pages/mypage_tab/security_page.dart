import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개인 및 보안")),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // 프로필 관리
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("프로필 관리"),
            subtitle: const Text("닉네임, 프로필 사진 변경"),
            onTap: () {
              // TODO: 프로필 관리 페이지 이동
            },
          ),

          const Divider(),

          // 비밀번호 변경
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("비밀번호 변경"),
            onTap: () {
              // TODO: 비밀번호 변경 기능 연결
            },
          ),

          // 2단계 인증
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text("2단계 인증"),
            subtitle: const Text("추가 인증으로 계정 보호"),
            onTap: () {
              // TODO: 2단계 인증 페이지 연결
            },
          ),

          const Divider(),

          // 알림 설정
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("알림 설정"),
            onTap: () {
              // TODO: 알림 설정 페이지 연결
            },
          ),

          // 회원 탈퇴
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("회원 탈퇴"),
            onTap: () {
              // TODO: 탈퇴 처리
            },
          ),
        ],
      ),
    );
  }
}
