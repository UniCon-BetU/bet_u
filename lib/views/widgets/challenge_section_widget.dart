import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/models/challenge.dart';
import 'package:bet_u/views/widgets/challenge_tile_widget.dart';
import '../../theme/app_colors.dart';
import 'package:bet_u/utils/token_util.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

class ChallengeSectionWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onSectionTap;

  /// 눌렀을 때 축소 비율 (예: 0.97)
  final double pressedScale;

  /// 프레스 애니메이션 시간
  final Duration pressedAnimDuration;

  const ChallengeSectionWidget({
    super.key,
    this.title = 'MY CHALLENGE 🥇',
    this.onSectionTap,
    this.pressedScale = 0.97,
    this.pressedAnimDuration = const Duration(milliseconds: 90),
  });

  @override
  State<ChallengeSectionWidget> createState() => _ChallengeSectionWidgetState();
}

class _ChallengeSectionWidgetState extends State<ChallengeSectionWidget> {
  final _pc = PageController(viewportFraction: 1.0);
  int _page = 0;
  bool _pressed = false;

  bool _loading = false;
  String? _error;
  List<Challenge> _all = [];

  @override
  void initState() {
    super.initState();
    _fetchMyChallenges();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _fetchMyChallenges() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        if (mounted) {
          setState(() {
            _all = [];
            _error = '로그인이 필요해요';
          });
        }
        return;
      }

      final uri = Uri.parse('$baseUrl/api/challenges/me');
      final res = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final List<dynamic> decoded = body.isNotEmpty
            ? jsonDecode(body) as List<dynamic>
            : <dynamic>[];

        final mine = decoded.map((e) {
          final m = e as Map<String, dynamic>;

          // 스웨거 응답 매핑
          final int id = (m['challengeId'] ?? 0) as int;
          final String title = (m['challengeName'] ?? '제목 없음') as String;
          final int duration = (m['challengeDuration'] ?? 0) as int;
          final int participants = (m['participantCount'] ?? 0) as int;
          final String? type = m['challengeType'] as String?;
          final List<String> tags = (m['challengeTags'] as List<dynamic>? ?? [])
              .map((x) => x.toString())
              .toList();
          final String? imageUrl = m['imageUrl'] as String?;
        
          return Challenge(
            // 기본 식별
            id: id,

            // 범위/크루
            scope: 'PUBLIC', // 필요시 'CREW' 등 실제 값으로 교체
            crew: null,

            // 타입 표준화: DURATION/TARGET → duration/target
            type: (() {
              final t = type.toString().trim().toUpperCase();
              if (t == 'DURATION') return 'duration';
              if (t == 'TARGET') return 'target';
              return t.toLowerCase();
            })(),

            // 태그
            tags: tags,
            customTags: const <String>[],

            // 표시 텍스트
            title: title,
            description: '',

            // 이미지
            imageUrls: (imageUrl != null && imageUrl.isNotEmpty)
                ? [imageUrl]
                : const <String>[],
            imageUrl: (imageUrl != null && imageUrl.isNotEmpty)
                ? imageUrl
                : null,

            // 수치
            day: duration == 0 ? 1 : duration,
            participants: participants,
            favoriteCount: 0,
            progressDays: 0,

            // 상태
            participating: true,
            status: ChallengeStatus.inProgress, // 내 참여 목록이면 진행중 가정
            todayCheck: TodayCheck.notStarted, // 오늘 인증 정보 없으니 기본값
            liked: false,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _all = mine;
          });
        }
      } else if (res.statusCode == 401) {
        if (mounted) {
          setState(() {
            _all = [];
            _error = '인증이 만료됐어요. 다시 로그인 해주세요';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = '서버 오류: ${res.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '네트워크 오류: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // 당겨서 새로고침
  Future<void> _refresh() async {
    await _fetchMyChallenges();
  }

  List<List<Challenge>> _chunk(List<Challenge> src) {
    final chunk = <List<Challenge>>[];
    for (var i = 0; i < src.length; i += 3) {
      chunk.add(src.sublist(i, (i + 3).clamp(0, src.length)));
    }
    return chunk.isEmpty ? [[]] : chunk;
  }

  Widget _buildBody(List<Challenge> items) {
    // 로딩 + 비어있음 → 스피너
    if (_loading && items.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 에러 + 비어있음 → 안내
    if (_error != null && items.isEmpty) {
      return SizedBox(
        height: 210,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '불러오는 중 오류가 발생했습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _refresh, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    // 비어있음 → 안내
    if (items.isEmpty) {
      return SizedBox(
        height: 210,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '진행 중인 챌린지가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _refresh, child: const Text('새로고침')),
            ],
          ),
        ),
      );
    }

    // 데이터 있음
    final pages = _chunk(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pc,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, idx) => Column(
              children: pages[idx]
                  .map((c) => ChallengeTileWidget(c: c, showTags: false))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pages.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                width: active ? 12 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryGreen : AppColors.gray,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onSectionTap,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              child: AnimatedScale(
                scale: _pressed ? widget.pressedScale : 1.0,
                duration: widget.pressedAnimDuration,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 당겨서 새로고침
                      RefreshIndicator(
                        onRefresh: _refresh,
                        // 현재 구조가 고정 높이라 스크롤 래핑 필요
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildBody(_all),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
