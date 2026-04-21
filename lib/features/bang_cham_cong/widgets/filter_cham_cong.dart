import 'package:flutter/material.dart';
import 'chotCongBtn.dart';

class FilterChamCong extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final bool daKhoa;
  final bool daChotLuong;
  final Function(int) onMonthChanged;
  final Function(int) onYearChanged;
  final VoidCallback onChotCong;

  const FilterChamCong({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.daKhoa,
    required this.daChotLuong,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onChotCong,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedMonth,
              decoration: const InputDecoration(labelText: "Tháng"),
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem(
                  value: m,
                  child: Text("Tháng $m"),
                );
              }),
              onChanged: (value) {
                if (value != null) onMonthChanged(value);
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedYear,
              decoration: const InputDecoration(labelText: "Năm"),
              items: List.generate(5, (i) {
                final y = DateTime.now().year - 2 + i;
                return DropdownMenuItem(
                  value: y,
                  child: Text("$y"),
                );
              }),
              onChanged: (value) {
                if (value != null) onYearChanged(value);
              },
            ),
          ),
          const SizedBox(width: 6),
          ChotCongButton(
            daKhoa: daKhoa,
            daChotLuong: daChotLuong,
            onPressed: onChotCong,
          ),
        ],
      ),
    );
  }
}