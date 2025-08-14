import 'package:flutter/material.dart';
import 'global_challenges.dart'; // 글로벌 챌린지 리스트 임포트
import 'package:bet_u/views/pages/challenge_start_page.dart';
import 'challenge.dart';
import 'point_page.dart';

class ChallengeParticipatePage extends StatefulWidget {
  final Challenge challenge; // 챌린지 필드

  const ChallengeParticipatePage({
    super.key,
    required this.challenge,
  }); // required 추가

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

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  final GlobalKey _arrowKey = GlobalKey();

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

  @override
  Widget build(BuildContext context) {
    final formattedSelected = selectedAmount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return Scaffold(
      appBar: AppBar(title: Text('챌린지 참여하기'), leading: BackButton()),
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
              widget.challenge.title, // <- 여기서 widget. 붙여야 함
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            Text(
              '챌린지에',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    formattedSelected,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: GestureDetector(
                      onTap: _toggleDropdown,
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 200), // 가격 오른쪽
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
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            Text(
              '도전하시겠어요?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('참여 확인'),
                      content: Text('$formattedSelected 포인트를 걸고 도전하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (userPoints >= selectedAmount) {
                              userPoints -= selectedAmount; // 포인트 차감
                              Navigator.pop(context); // 다이얼로그 닫기 먼저

                              // 도전 시작 페이지로 이동, 실제 챌린지 제목 전달
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChallengeStartPage(
                                    deductedPoints: selectedAmount, // 여기서 전달
                                    challengeTitle: widget.challenge.title,
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('포인트 부족'),
                                  content: Text(
                                    '포인트가 부족합니다. 충전 페이지로 이동하시겠습니까?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context), // 취소
                                      child: Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // 다이얼로그 닫기
                                        // 충전 페이지로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PointPage(), // 충전 페이지 위젯
                                          ),
                                        );
                                      },
                                      child: Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  '결제하고 참여하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
