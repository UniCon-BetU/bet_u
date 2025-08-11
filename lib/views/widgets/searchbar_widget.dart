import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final String initialText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SearchBarWidget({
    super.key,
    this.hintText = '그룹 이름으로 검색',
    this.initialText = '',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctl.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctl,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (v) {
                widget.onChanged?.call(v);
                setState(() {});
              },
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (_ctl.text.isNotEmpty)
            IconButton(
              tooltip: '지우기',
              onPressed: _clear,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}
