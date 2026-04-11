import 'package:flutter/material.dart';

import '../../../data/repositories/ChamCongRepository.dart';

Future<void> khoaChamCong({
  required BuildContext context,
  required int selectedMonth,
  required int selectedYear
}) async {
  final ok = await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Xác nhận"),
      content: Text("Khóa chấm công tháng $selectedMonth/$selectedYear?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Huỷ")),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Khóa")),
      ],
    ),
  );

  if (ok == true) {
    final thang =
        "${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}";
    await ChamCongRepository().khoaChamCong(thang);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã khóa chấm công")),
    );
  }
}