import 'package:flutter/material.dart';

class SmoothDropdown extends StatefulWidget {
  final int initialAmount;
  final List<int> amounts;
  final ValueChanged<int> onChanged;

  const SmoothDropdown({
    Key? key,
    required this.initialAmount,
    required this.amounts,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SmoothDropdownState createState() => _SmoothDropdownState();
}

class _SmoothDropdownState extends State<SmoothDropdown> {
  late int selectedAmount;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedAmount = widget.initialAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedAmount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                  style: TextStyle(fontSize: 20),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_drop_down, size: 30),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: isOpen ? widget.amounts.length * 50 : 0,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: widget.amounts.map((amount) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAmount = amount;
                      isOpen = false;
                    });
                    widget.onChanged(amount); // 선택된 금액 부모에 전달
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      amount.toString().replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => '${match[1]},',
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
