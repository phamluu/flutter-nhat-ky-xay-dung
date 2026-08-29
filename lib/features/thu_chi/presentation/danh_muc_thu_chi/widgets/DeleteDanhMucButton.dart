import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

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
    showErrorToast(context, "",'Không thể xóa: đang có $inUse khoản thu/chi dùng danh mục này');

    return;
  }

  try {
    await DanhMucThuChiService().delete(id);

    if (!context.mounted) return;

    onDeleted();

    if (!context.mounted) return;
showSuccessToast(context, 'Xóa danh mục thu chi thành công');

  } catch (e) {
    if (!context.mounted) return;
      showErrorToast(context, e, 'Không thể xóa danh mục:');

  }
}
