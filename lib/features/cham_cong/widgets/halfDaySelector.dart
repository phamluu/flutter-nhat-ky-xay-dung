import 'package:flutter/material.dart';

import '../../../core/utils/trang_thai_cham_cong.dart';

class HalfDaySelector extends StatefulWidget {
  final int? initialValue; // 1 = có mặt, 0 = vắng
  final ValueChanged<int> onChanged;

  const HalfDaySelector({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<HalfDaySelector> createState() => _HalfDaySelectorState();
}

class _HalfDaySelectorState extends State<HalfDaySelector> {
  int? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _onSelected(int v) {
    setState(() {
      _value = v;
    });
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        ChoiceChip(
          label: const Text("Có mặt", style: TextStyle(fontSize: 12)),
          selected: _value == TrangThaiChamCong.coMat.value,
          selectedColor: Colors.amber,
          backgroundColor: Colors.grey.shade50,
          onSelected: (_) => _onSelected(1),
        ),
        ChoiceChip(
          label: const Text("Vắng"),
          selected: _value == TrangThaiChamCong.vang.value,
          selectedColor: Colors.amber,
          backgroundColor: Colors.grey.shade50,
          onSelected: (_) => _onSelected(0),
        ),
      ],
    );
  }
}
