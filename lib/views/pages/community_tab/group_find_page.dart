// lib/views/pages/community_tab/group_find_page.dart
import 'dart:convert';

import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/community_tab/group_info_page.dart';
import 'package:bet_u/views/widgets/group_card_widget.dart';
import 'package:bet_u/views/widgets/searchbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://54.180.150.39.nip.io';

class GroupFindPage extends StatefulWidget {
  const GroupFindPage({super.key});

  @override
  State<GroupFindPage> createState() => _GroupFindPageState();
}

class _GroupFindPageState extends State<GroupFindPage> {
  String _query = '';
  List<GroupInfo> _allGroups = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse('$baseUrl/api/crews');
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty ? jsonDecode(body) : [];

        // 기대 스키마:
        // [
        //   { "crewId": 1, "crewName": "...", "crewCode": "...", "isPublic": true, "myRole": "OWNER" },
        //   ...
        // ]
        final List<GroupInfo> items = (decoded as List<dynamic>).map((e) {
          final m = e as Map<String, dynamic>;
          final isPublic = (m['isPublic'] == true);
          return GroupInfo(
            name: (m['crewName'] ?? '이름없음').toString(),
            description: (m['crewCode'] ?? '').toString(), // 모르면 코드로 대체
            memberCount: 0, // API에 없으므로 기본값
            icon: isPublic ? Icons.public : Icons.lock,
          );
        }).toList();

        if (!mounted) return;
        setState(() => _allGroups = items);
      } else {
        if (!mounted) return;
        setState(() => _error = '불러오기 실패: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '네트워크 오류: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? _allGroups
        : _allGroups.where((g) => g.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9E8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '그룹 찾기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _fetchGroups,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색창
          SearchBarWidget(
            hintText: '그룹 이름으로 검색',
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: (v) => setState(() => _query = v),
          ),

          if (_loading) const LinearProgressIndicator(minHeight: 2),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchGroups,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),

          // 결과 리스트
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchGroups,
              child: results.isEmpty && !_loading && _error == null
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              '검색 결과가 없어요',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 16,
                        thickness: 1,
                        color: Colors.grey.withValues(alpha: 0.12),
                      ),
                      itemBuilder: (context, i) {
                        final g = results[i];
                        return GroupCardWidget(
                          group: g,
                          onTap: () {
                            // 상세 페이지로 이동 — 모르는 값은 기본값
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupInfoPage(
                                  groupName: g.name,
                                  nickname: g.description, // 임시로 코드/설명을 노출
                                  memberCount: g.memberCount,
                                  challengeCount: 0,
                                  tags: const [],
                                  isPublic: g.icon == Icons.public,
                                  description: '',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
