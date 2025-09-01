// lib/views/pages/community_tab/group_find_page.dart
import 'dart:convert';

import 'package:bet_u/models/group.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/community_tab/group_info_page.dart';
import 'package:bet_u/views/widgets/group_card_widget.dart';
import 'package:bet_u/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bet_u/theme/app_colors.dart';

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

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    // 텍스트 변화 → _query 갱신 (SearchBarOnly에 onChanged 없으니 리스너로 처리)
    _searchController.addListener(() {
      final v = _searchController.text;
      if (_query != v) {
        setState(() => _query = v);
      }
    });

    _fetchGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
            crewId: (m['crewId'] ?? 0) as int,
            crewCode: (m['crewCode'] ?? '').toString(),
            name: (m['crewName'] ?? '이름없음').toString(),
            description: '상세정보 예시'.toString(), // 상세 정보 미정 → 코드 노출
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

  Future<void> _joinCrew(
    BuildContext context, {
    required int crewId,
    required String crewCode,
  }) async {
    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse('$baseUrl/api/crews/join');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'crewId': crewId, 'crewCode': crewCode}),
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // 서버가 text를 줄 수도 있으니 안전하게 처리
        final msg = '그룹 참여에 성공했어요';

        print(msg);

        // 필요하면 이전 화면으로 돌아가기 등
        // Navigator.of(context).pop(true);
      } else {
        final err = res.body.isNotEmpty ? res.body : 'status ${res.statusCode}';
        print('참여 실패: $err');
      }
    } catch (e) {
      if (!mounted) return;
      print('네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? _allGroups
        : _allGroups.where((g) => g.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '그룹 찾기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        // actions: [
        //   IconButton(
        //     tooltip: '새로고침',
        //     onPressed: _fetchGroups,
        //     icon: const Icon(Icons.refresh),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBarOnly(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isSearching: _isSearching,
              onSearchingChanged: (isOn) => setState(() => _isSearching = isOn),
              icon: Icons.refresh,
              onTapSearch: () {
                // 검색창 탭 시 동작이 필요하면 여기에
                // ex) 최근 검색어 노출 등
              },
              onPlusPressed: _fetchGroups,
              // + 버튼 동작 (원하면 새 그룹 만들기 등)
              // _fetchGroups
              // Navigator.push(...);
              decoration: InputDecoration(
                hintText: '그룹 이름으로 검색',
                hintStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkerGray,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 12,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/normal_lettuce.png',
                    width: 48,
                    height: 48,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 지우기
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear(); // <- _query는 리스너로 자동 반영
                          _isSearching = true; // 유지하거나 false로 바꿔도 됨
                        });
                        _searchFocusNode.requestFocus();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.darkerGray,
                      ),
                    ),
                    const SizedBox(width: 7),
                    // 검색(엔터 대신 아이콘 눌러 실행하고 싶을 때)
                    GestureDetector(
                      onTap: () {
                        // 필요 시 포커스 내려주기
                        _searchFocusNode.unfocus();
                        // _query는 이미 최신값, 여기서 필터링은 자동 반영됨
                        // 서버 검색 트리거가 필요하면 호출
                        // _fetchGroups();
                      },
                      child: const Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ),
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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // 빈 공간도 탭 감지
              onTap: () {
                setState(() => _isSearching = false);
                FocusScope.of(context).unfocus(); // 키보드/포커스도 내려주기(선택)
              },
              child: RefreshIndicator(
                onRefresh: _fetchGroups,
                child: Container(
                  color: AppColors.lightGray, // 배경색 유지
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
                          separatorBuilder: (_, _) => const Divider(
                            height: 16,
                            thickness: 1,
                            color: Colors.transparent,
                          ),
                          itemBuilder: (context, i) {
                            final g = results[i];
                            return GroupCardWidget(
                              background: Colors.white,
                              group: g,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GroupInfoPage(
                                      groupName: g.name,
                                      nickname: g.description,
                                      memberCount: g.memberCount,
                                      challengeCount: 0,
                                      tags: const [],
                                      isPublic: g.icon == Icons.public,
                                      description: '',
                                      onJoinPressed: () {
                                        _joinCrew(
                                          context,
                                          crewId: g.crewId,
                                          crewCode: g.crewCode,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
