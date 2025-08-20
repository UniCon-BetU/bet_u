import 'package:flutter/material.dart';

class GroupInfo {
  final String name; // 그룹 이름
  final String description; // 한 줄 설명
  final int memberCount; // 멤버 수
  final IconData icon; // 대표 아이콘
  final int crewId;
  final String crewCode;

  const GroupInfo({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.icon,
    required this.crewId,
    required this.crewCode,
  });
}