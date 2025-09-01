// lib/views/pages/challenge_tab/challenge_participate_page.dart
import 'package:bet_u/utils/point_store.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_start_page.dart';
import '../../../models/challenge.dart';
import '../mypage_tab/point_page.dart';

class ChallengeParticipatePage extends StatefulWidget {
  final Challenge challenge;

  const ChallengeParticipatePage({super.key, required this.challenge});

  @override
  State<ChallengeParticipatePage> createState() =>
      _ChallengeParticipatePageState();
}

class _ChallengeParticipatePageState extends State<ChallengeParticipatePage> {
  final List<int> amounts = [
    1000,
    2000,
    3000,
    5000,
    10000,
    25000,
    50000,
    100000,
  ];
  int selectedAmount = 5000;

  int? _userId;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _initUserAndPoints();
  }

  Future<void> _initUserAndPoints() async {
    try {
      _userId = await TokenStorage.getUserId();
      // ✅ 전역 스토어가 로딩/동기화 담당
      await PointStore.instance.ensureLoaded();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('포인트 불러오기 실패: $e')));
    }
  }

  // FIXME: 실제 참여 API로 교체
  Future<bool> _postChallengeParticipation({
    required int userId,
    required int challengeId,
    required int points,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  void _toggleDropdown() =>
      _isDropdownOpen ? _closeDropdown() : _openDropdown();

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 120,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(120, 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: amounts.length,
                  itemBuilder: (context, index) {
                    final amount = amounts[index];
                    final formatted = _fmt(amount);
                    final selected = amount == selectedAmount;
                    return ListTile(
                      dense: true,
                      title: Text(
                        formatted,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: selected ? Colors.green[700] : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        setState(() => selectedAmount = amount);
                        _closeDropdown();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onParticipatePressed() async {
    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    // 항상 전역 최신값으로 검사
    final currentPoints = PointStore.instance.points.value;

    // 1) 포인트 부족 → 충전 화면
    if (currentPoints < selectedAmount) {
      final go = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('포인트 부족'),
          content: const Text('포인트가 부족합니다. 충전 페이지로 이동하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        ),
      );

      if (go == true) {
        final newPoints = await Navigator.push<int>(
          context,
          MaterialPageRoute(builder: (_) => const PointPage()),
        );
        if (newPoints != null) {
          // 전역 갱신
          PointStore.instance.setFromServer(newPoints);
        }
      }
      return;
    }

    // 2) 포인트 충분 → 참여 확인
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('참여 확인'),
        content: Text('${_fmt(selectedAmount)} 포인트를 걸고 도전하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // 3) 참여 API 호출
    final success = await _postChallengeParticipation(
      userId: _userId!,
      challengeId: widget.challenge.id,
      points: selectedAmount,
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('챌린지 참여에 실패했습니다. 다시 시도해주세요.')),
      );
      return;
    }

    // 4) 성공 시 전역 포인트 새로고침 + 로컬 모델도 진행중으로 갱신
    try {
      await PointStore.instance.refreshFromServer();
    } catch (_) {}
    widget.challenge.participating = true;
    widget.challenge.status = ChallengeStatus.inProgress;
    widget.challenge.todayCheck = TodayCheck.waiting;
    // widget.challenge.progressDays = 0; // 서버 정책에 맞춰 필요하면 설정

    if (!mounted) return;

    // 5) 시작 페이지로 이동 (기존 UX 유지)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeStartPage(
          deductedPoints: selectedAmount,
          challenge: widget.challenge,
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('챌린지 참여하기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/normal_lettuce.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.challenge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              '챌린지에',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            // 🔔 전역 포인트를 “구독”해서 항상 최신값 표시
            ValueListenableBuilder<int>(
              valueListenable: PointStore.instance.points,
              builder: (_, p, _) {
                return Text(
                  '내 보유 포인트: ${_fmt(p)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 배팅 금액 + 드롭다운
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    _fmt(selectedAmount),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: GestureDetector(
                      onTap: _toggleDropdown,
                      behavior: HitTestBehavior.translucent,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 200),
                        child: Icon(Icons.arrow_drop_down, size: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              '포인트를 걸고',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const Text(
              '도전하시겠어요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),

            const Spacer(),

            LongButtonWidget(
              text: '결제하고 참여하기',
              backgroundColor: Colors.green[600]!,
              height: 56,
              radius: 8,
              onPressed: _onParticipatePressed,
            ),
          ],
        ),
      ),
    );
  }
}
