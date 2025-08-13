import 'package:flutter/material.dart';

class ChallengeParticipatePage extends StatefulWidget {
  const ChallengeParticipatePage({super.key});

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
    if (overlay == null) return;

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
    RenderBox renderBox =
        _arrowKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    const double maxDropdownHeight = 180;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 50, // 화살표 기준으로 좌우 조정 (원하는 위치에 맞게 조절)
        top: offset.dy + size.height,
        width: 100, // 가격 선택 영역 넓이
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxDropdownHeight),
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
            Container(
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
              '챌린지 이름',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              '챌린지에',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            Center(
              child: Stack(
                clipBehavior: Clip.none, // 영역 밖도 보이게
                alignment: Alignment.center,
                children: [
                  Text(
                    formattedSelected,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Positioned(
                    right: -40, // 텍스트 오른쪽에 살짝 붙임
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      key: _arrowKey,
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleDropdown,
                      child: Icon(
                        _isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 40,
                        color: Colors.black87,
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
                            Navigator.pop(context);
                            // 결제 및 참여 로직
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
