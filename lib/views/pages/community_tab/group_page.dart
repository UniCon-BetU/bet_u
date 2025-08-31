// lib/views/pages/community_tab/group_page.dart
import 'dart:convert';
import 'package:bet_u/models/group.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/pages/community_tab/board_page.dart';
import 'package:bet_u/views/pages/community_tab/post_page.dart';
import 'package:bet_u/views/widgets/postcard_widget.dart';
import 'package:bet_u/views/widgets/profile_widget.dart';
import 'package:bet_u/views/widgets/ranking_widget.dart';
import 'package:bet_u/views/widgets/challenge_section_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/board_widget.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://54.180.150.39.nip.io';

class CrewRankingItem {
  final int userId;
  final String userName;
  final int challengeCount;
  final int rank;

  CrewRankingItem({
    required this.userId,
    required this.userName,
    required this.challengeCount,
    required this.rank,
  });

  factory CrewRankingItem.fromJson(Map<String, dynamic> j) => CrewRankingItem(
    userId: j['userId'] ?? 0,
    userName: (j['userName'] ?? '').toString(),
    challengeCount: j['challengeCount'] ?? 0,
    rank: j['rank'] ?? 0,
  );
}

/// API 응답용 요약 모델
class CrewPostSummary {
  final int postId;
  final int crewId;
  final int? authorId;
  final String authorName;
  final String title;
  final String preview;
  final int likeCount;
  final int commentCount;
  final String? thumbnailUrl;
  final DateTime createdAt; // 응답에 없으면 now로 대체

  CrewPostSummary({
    required this.postId,
    required this.crewId,
    required this.authorName,
    required this.title,
    required this.preview,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.authorId,
    this.thumbnailUrl,
  });

  factory CrewPostSummary.fromJson(Map<String, dynamic> j) => CrewPostSummary(
    postId: j['postId'] ?? 0,
    crewId: j['crewId'] ?? 0,
    authorId: j['authorId'],
    authorName: (j['authorName'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    preview: (j['preview'] ?? '').toString(),
    likeCount: j['likeCount'] ?? 0,
    commentCount: j['commentCount'] ?? 0,
    thumbnailUrl: (j['thumbnailUrl'] as String?)?.toString(),
    // createdAt 필드가 없을 수 있어 안전 처리
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}

final demoRanking = const [
  RankingEntry(username: '김철수', completed: 27),
  RankingEntry(username: '아름이', completed: 24),
  RankingEntry(username: '나는민수', completed: 22),
  RankingEntry(username: '대구정시파이터', completed: 19),
  RankingEntry(username: '고연오', completed: 17),
];

class GroupPage extends StatefulWidget {
  final GroupInfo group;

  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  bool _loading = false;
  String? _error;
  List<CrewPostSummary> _posts = [];

  bool _loadingRank = false;
  String? _rankError;
  List<RankingEntry> _ranking = []; // RankingWidget에 맞춘 리스트

  final demoChallenges = [
    /*
    Challenge(
      title: '물 하루 2L 마시기',
      participants: 12,
      day: 7,
      status: ChallengeStatus.inProgress,
      category: '건강',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      type: 'goal',
      tags: ['물', '습관'],
      progressDays: 2,
      todayCheck: TodayCheck.done,
    ),
    Challenge(
      title: '매일 만보 걷기',
      participants: 8,
      day: 14,
      status: ChallengeStatus.inProgress,
      category: '운동',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      type: 'time',
      tags: ['운동', '만보'],
      progressDays: 5,
      todayCheck: TodayCheck.waiting,
    ),
    Challenge(
      title: '일기 쓰기',
      participants: 5,
      day: 10,
      status: ChallengeStatus.notStarted,
      category: '자기계발',
      createdAt: DateTime.now().add(const Duration(days: 1)), // 내일부터 시작
      type: 'goal',
      tags: ['글쓰기'],
      progressDays: 0,
    ),
    Challenge(
      title: '하루 30분 책 읽기',
      participants: 15,
      day: 5,
      status: ChallengeStatus.done,
      category: '자기계발',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      type: 'time',
      tags: ['독서'],
      progressDays: 5,
    ),
    */
  ];

  @override
  void initState() {
    super.initState();
    _fetchCrewPosts();
    _fetchCrewRanking();
  }

  Future<void> _fetchCrewPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse(
        '$baseUrl/api/community/crews/posts?crewId=${widget.group.crewId}',
      );
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty ? jsonDecode(body) : [];
        final items = (decoded as List<dynamic>)
            .map((e) => CrewPostSummary.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() => _posts = items);
      } else {
        setState(() => _error = '불러오기 실패: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchCrewRanking() async {
    setState(() {
      _loadingRank = true;
      _rankError = null;
    });

    final token = await TokenStorage.getToken();

    try {
      final uri = Uri.parse(
        '$baseUrl/api/crews/${widget.group.crewId}/ranking',
      );
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = res.body.trim();
        final decoded = body.isNotEmpty
            ? (jsonDecode(body) as List)
            : <dynamic>[];

        // API 스키마 → UI 모델 매핑
        final items = decoded
            .map((e) => CrewRankingItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // RankingWidget이 쓰는 모델로 변환
        final list = items
            .map(
              (r) => RankingEntry(
                username: r.userName,
                completed: r.challengeCount,
              ),
            )
            .toList();

        setState(() => _ranking = list);
      } else {
        setState(() => _rankError = '랭킹 불러오기 실패: ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _rankError = '네트워크 오류: $e');
    } finally {
      if (mounted) setState(() => _loadingRank = false);
    }
  }

  /// BoardSectionCard가 기대하는 BoardPost로 매핑
  List<BoardPost> get boardPosts => _posts
      .map((p) => BoardPost(title: p.title, createdAt: p.createdAt, likeCount: p.likeCount))
      .toList();

  String get profileTitle => widget.group.name;

  String get profileSubtitle {
    final leaderName = ('알 수 없음').toString();
    final dPlus = 1;
    return '그룹장 $leaderName, 개설 D+$dPlus';
  }

  List<StatItemData> get profileStats => [
    StatItemData(label: '인원', value: (widget.group.memberCount).toString()),
    StatItemData(label: '챌린지', value: '0'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.group.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _fetchCrewPosts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchCrewPosts,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),

              SizedBox(height:6),
              ProfileWidget(
                title: profileTitle,
                subtitle: profileSubtitle,
                stats: profileStats,
              ),

              const SizedBox(height: 20),

              // ChallengeSectionWidget(title: '그룹  챌린지 🧩', items: demoChallenges),

              const SizedBox(height: 20),

              BoardSectionCard(
                title: '그룹 게시판',
                posts: boardPosts,
                onTap: (post) {
                  // 실제 postId로 상세 진입
                  final tapped = _posts.firstWhere(
                    (p) =>
                        p.title == post.title && p.createdAt == post.createdAt,
                    orElse: () => _posts.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(
                        args: PostDetailArgs(postId: tapped.postId),
                      ),
                    ),
                  );
                },
                onMore: () {
                  final cards = _posts
                      .map(
                        (p) => PostCard(
                          postId: p.postId,
                          title: p.title,
                          excerpt: p.preview,
                          author: p.authorName,
                          likes: p.likeCount,
                          createdAt: p.createdAt,
                          // thumbnailUrl: p.thumbnailUrl,
                        ),
                      )
                      .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BoardPage(
                        title: '${widget.group.name} 게시판',
                        posts: cards,
                        crewId: widget.group.crewId,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const SizedBox(height: 10),
              // 랭킹 섹션
              if (_loadingRank)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (_rankError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _rankError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchCrewRanking,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              RankingWidget(
                title: '랭킹',
                entries: _ranking, // ← 서버 데이터
                onTap: (entry) {
                  // TODO: 유저 프로필로 이동 등
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
