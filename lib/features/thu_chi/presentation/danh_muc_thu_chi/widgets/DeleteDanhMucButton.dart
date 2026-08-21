import 'package:flutter/material.dart';

import '../../../data/services/danh_muc_thu_chi_service.dart';
import '../../../data/services/thu_chi_service.dart';

Future<void> deleteDanhMuc(
    BuildContext context,
    int id,
    VoidCallback onDeleted,
    ) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Xóa danh mục?'),
      content: const Text(
        'Bạn chắc chắn muốn xóa danh mục này?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(false);
          },
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          child: const Text('Xóa'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  if (!context.mounted) return;

  final inUse = await ThuChiService().countByDanhMuc(id);

  if (!context.mounted) return;

  if (inUse > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Không thể xóa: đang có $inUse khoản thu/chi dùng danh mục này',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }

  try {
    await DanhMucThuChiService().delete(id);

    if (!context.mounted) return;

    onDeleted();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xóa danh mục thu chi thành công'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không thể xóa danh mục: $e'),
      ),
    );
  }
}
