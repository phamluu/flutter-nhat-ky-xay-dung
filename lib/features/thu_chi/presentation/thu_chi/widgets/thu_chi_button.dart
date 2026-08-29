import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

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
    builder: (dialogContext) => AlertDialog(
      title: const Text('Xóa khoản thu/chi?'),
      content: const Text('Bạn chắc chắn muốn xóa khoản này?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa')),
      ],
    ),
  );
  if (confirm != true) return;
  try{
    await ThuChiService().delete(id);
    if (context.mounted) {
      showSuccessToast(context, "Xóa khoản thu/chi thành công");
      onDeleted();
    }
  }catch(e){
      showErrorToast(context, e, "Xóa khoản thu/chi thất bại");
  }
}
