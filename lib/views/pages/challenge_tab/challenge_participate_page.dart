import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
// 글로벌 챌린지 리스트 임포트
import 'package:bet_u/views/pages/challenge_tab/challenge_start_page.dart';
import '../../../models/challenge.dart';
import '../mypage_tab/point_page.dart';
import 'package:bet_u/utils/point_api.dart'; // TokenStorage or TokenUtil 가져오는 곳

class ChallengeParticipatePage extends StatefulWidget {
  final Challenge challenge; // 챌린지 필드

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

  // 서버에서 가져올 실제 사용자 포인트
  int _userPoints = 0;
  int? _userId;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  // 더미 서버 함수 - 실제 API 호출로 교체 필요
  // 챌린지 참여 API 호출을 시뮬레이션하는 더미 함수
  Future<bool> _postChallengeParticipation({
    required int userId,
    required int challengeId,
    required int points,
  }) async {
    // 실제 API 호출 로직 (예: http.post)
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    // 서버 응답에 따라 true 또는 false 반환
    return true;
  }

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      _userId = await TokenStorage.getUserId(); // ← 이 줄 추가

      final points = await PointApi.fetchUserPoints(); // ✅ 요렇게
      if (mounted) {
        setState(() {
          _userPoints = points;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('포인트 불러오기 실패: $e')));
      }
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);

    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 120,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(120, 40), // x값을 양수로 바꾸면 오른쪽, y값은 아래쪽
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
                    final formatted = amount.toString().replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                      (match) => '${match[1]},',
                    );
                    final selected = amount == selectedAmount;

                    return ListTile(
                      dense: true,
                      title: Text(
                        formatted,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected ? Colors.green[700] : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {
                          selectedAmount = amount;
                        });
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

  void _onParticipatePressed() async {
    // 포인트 부족 여부 체크
    if (_userPoints < selectedAmount) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('포인트 부족'),
          content: const Text('포인트가 부족합니다. 충전 페이지로 이동하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final newPoints = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (_) => const PointPage()),
                );
                if (newPoints != null && mounted) {
                  setState(() => _userPoints = newPoints);
                }
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return; // 포인트 부족 시 함수 종료
    }

    // 포인트가 충분하면 참여 확인 다이얼로그 표시
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('참여 확인'),
        content: Text(
          '${selectedAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} 포인트를 걸고 도전하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기

              // 실제 API 호출
              final success = await _postChallengeParticipation(
                userId: _userId!,
                challengeId: widget.challenge.id,
                points: selectedAmount,
              );

              if (success && mounted) {
                // 성공 시 포인트 차감 및 페이지 이동
                setState(() {
                  _userPoints -= selectedAmount;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChallengeStartPage(
                      deductedPoints: selectedAmount,
                      challenge: widget.challenge,
                    ),
                  ),
                );
              } else if (mounted) {
                // 실패 시 에러 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('챌린지 참여에 실패했습니다. 다시 시도해주세요.')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedSelected = selectedAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final formattedUserPoints = _userPoints.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '챌린지에',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            Text(
              '내 보유 포인트: $formattedUserPoints',
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    formattedSelected,
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
                      child: Padding(
                        padding: const EdgeInsets.only(left: 200),
                        child: Icon(
                          _isDropdownOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '포인트를 걸고',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            Text(
              '도전하시겠어요?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
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
