import 'package:flutter/material.dart';

import '../../../data/models/ThuChi.dart';
import '../../../data/services/thu_chi_service.dart';
import '../screens/them_thu_chi_screen.dart';

Future<void> openThuChiForm(BuildContext context, ThuChi? tc, VoidCallback onUpdated) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ThemThuChiScreen(thuChi: tc)),
  );
  if (result == true) {
    onUpdated();
  }
}

Future<void> deleteThuChi(BuildContext context, int id, VoidCallback onDeleted) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Xóa khoản thu/chi?'),
      content: const Text('Bạn chắc chắn muốn xóa khoản này?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
      ],
    ),
  );
  if (confirm != true) return;

  await ThuChiService().delete(id);
  onDeleted();
}
