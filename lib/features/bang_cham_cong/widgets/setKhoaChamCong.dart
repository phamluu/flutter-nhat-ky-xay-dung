import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
Future<void> setkhoaChamCong({
  required BuildContext context,
  int? selectedMonth,
  int? selectedYear,
  required bool isKhoa,
  required bool daChotLuong,
  int? idBangChamCong,
}) async {
  // Nếu đã chốt lương thì không cho mở khóa
  if (!isKhoa && daChotLuong) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không thể mở khóa'),
        content: const Text(
          'Tháng này đã tồn tại chốt lương nên không thể mở chốt công. Hãy hủy chốt lương trước',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
    return;
  }
  final actionText = isKhoa ? 'khóa' : 'mở khóa';
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isKhoa ? 'Xác nhận chốt công' : 'Xác nhận mở chốt công'),
      content: Text(
        isKhoa
            ? 'Bạn có chắc muốn khóa chấm công tháng '
            '$selectedMonth/$selectedYear?'
            : 'Bạn có chắc muốn mở khóa chấm công tháng '
            '$selectedMonth/$selectedYear?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(isKhoa ? 'Khóa' : 'Mở khóa'),
        ),
      ],
    ),
  );

  if (ok != true) return;
  try {
    final _bangChamCongRepo = BangChamCongRepository();
    await _bangChamCongRepo.setKhoaChamCong(idBangChamCong: idBangChamCong, daKhoa: isKhoa);
    if (!context.mounted) return;
    String title = isKhoa ?  'Đã khóa chấm công tháng $selectedMonth/$selectedYear'
      : 'Đã mở khóa chấm công tháng $selectedMonth/$selectedYear';
    showSuccessToast(context, title);
  } catch (e) {
    if (!context.mounted) return;
    showErrorToast(context, e, 'Không thể $actionText chấm công: $e');
  }
}