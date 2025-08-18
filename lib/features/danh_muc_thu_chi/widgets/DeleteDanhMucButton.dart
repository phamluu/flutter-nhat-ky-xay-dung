import 'package:flutter/material.dart';
import '../../../services/danh_muc_thu_chi_service.dart';
import '../../../services/thu_chi_service.dart';

Future<void> deleteDanhMuc(BuildContext context, int id, VoidCallback onDeleted) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Xóa danh mục?'),
      content: const Text('Bạn chắc chắn muốn xóa danh mục này?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
      ],
    ),
  );
  if (confirm != true) return;

  final inUse = await ThuChiService().countByDanhMuc(id);
  if (inUse > 0) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không thể xóa: đang có $inUse khoản thu/chi dùng danh mục này'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  await DanhMucThuChiService().delete(id);
  onDeleted();
}
