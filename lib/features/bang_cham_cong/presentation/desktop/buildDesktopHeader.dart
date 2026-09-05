import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_luong_repo.dart';

import '../../data/models/phien_chot_cong.dart';
import '../../data/repositories/bang_cham_cong_repo.dart';
import '../../widgets/chotCongBtn.dart';
import 'dot_chot_cong_detail_desktop.dart';

Widget buildDesktopHeader({
    required ThemeData theme,
    String? tenCongTrinh,
    String? thangKey,
    int? nam,
    int? thang,
    Set<int>? selectedNhanVienIds,
    required bool daKhoa,
    required bool daChotLuong,
    required VoidCallback onChotCong,
    required Function(DateTime dateSelected) onChotCongTheoNhanVien,
    List<PhienChotCong> dsDotChot = const [],
    Function(int idPhienChot)? onHuyDotChot,
    required Future<void> Function() onLoad,
    })
{
  final hasSelectedEmployees = selectedNhanVienIds != null && selectedNhanVienIds.isNotEmpty;
  final int currentMonth = thang ?? DateTime.now().month;
  final int currentYear = nam ?? DateTime.now().year;
  final DateTime firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
  final DateTime lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
  // Hàm mở Dialog/DatePicker khi bấm nút
  Future<void> _openDatePickerDialog(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Tự động điều chỉnh initialDate nằm trong khoảng [firstDayOfMonth, lastDayOfMonth]
    DateTime validInitialDate = now;
    if (now.isAfter(lastDayOfMonth)) {
      validInitialDate = lastDayOfMonth; // Nếu là tháng cũ, mặc định chọn ngày cuối tháng
    } else if (now.isBefore(firstDayOfMonth)) {
      validInitialDate = firstDayOfMonth; // Nếu là tháng tương lai, mặc định chọn ngày đầu tháng
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: firstDayOfMonth,
      lastDate: lastDayOfMonth,
      helpText: 'CHỌN NGÀY CHỐT CÔNG',
      confirmText: 'XÁC NHẬN CHỐT',
      cancelText: 'HỦY',
    );

    // Người dùng bấm chọn ngày xong mới gửi dữ liệu đi
    if (pickedDate != null) {
      onChotCongTheoNhanVien(pickedDate);
    }
  }
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 18,
    ),
    child: Row(
      children: [
        // ICON
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            color: Colors.green.shade700,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sổ chấm công tháng ${thang}",
                style: const TextStyle( fontSize: 21, fontWeight: FontWeight.w700, ),
              ),
              const SizedBox(height: 4),
              Text(
                tenCongTrinh?.trim().isNotEmpty == true ? tenCongTrinh! : "Quản lý chấm công và bảng lương",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // NÚT CHỐT CÔNG THEO NHÂN VIÊN ĐÃ CHỌN
        // if (hasSelectedEmployees) ...[
          Builder(
            builder: (context) {
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Khi bấm nút mới gọi hàm mở DatePicker
                onPressed: (daKhoa || daChotLuong)
                    ? null
                    : () => _openDatePickerDialog(context),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  "Chốt công (${selectedNhanVienIds?.length})",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) {
              return _buildHuyDotChotMenu(
                context: context,
                dsDotChot: dsDotChot,
                onHuyDotChot: onHuyDotChot ?? (_) {},
                onLoad: onLoad,
              );
            },
          ),
        // ],
        // MONTH
        // ChotCongButton(
        //   daKhoa: daKhoa,
        //   daChotLuong: daChotLuong,
        //   onPressed: onChotCong,
        // ),
        const SizedBox(width: 12),
      ],
    ),
  );
}

Widget _buildHuyDotChotMenu({
  required BuildContext context,
  required List<PhienChotCong> dsDotChot,
  required Function(int idPhienChot) onHuyDotChot,
  Function(PhienChotCong phienChot)? onSelectDot, // Hàm khi bấm vào dòng đợt chốt
  Future<void> Function()? onLoad,
}) {
  return PopupMenuButton<PhienChotCong>(
    tooltip: 'Danh sách đợt chốt công',
    offset: const Offset(0, 45),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    // Sự kiện khi bấm vào vùng TEXT của item
    onSelected: (phienChot) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DotChotCongDetailDesktop(phienChot: phienChot),
        ),
      );
    },
    itemBuilder: (context) => [
      const PopupMenuItem<PhienChotCong>(
        enabled: false,
        child: Text(
          'DANH SÁCH ĐỢT CHỐT CÔNG',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const PopupMenuDivider(),
      ...dsDotChot.map(
            (dot) => PopupMenuItem<PhienChotCong>(
          value: dot,
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              // Vùng 1: Thông tin đợt chốt (Bấm vào đây để chọn/xem)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đợt ${dot.maDot}: Đến ${dot.denNgayStr ?? dot.ngayChot}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (dot.soLuongNhanVien != null)
                      Text(
                        '${dot.soLuongNhanVien} nhân viên',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Vùng 2: CHỈ BẤM VÀO NÚT NÀY MỚI XÓA
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // 1. Đóng Popup Menu
                  Navigator.of(context).pop();

                  // 2. Mở dialog xác nhận xóa
                  _xuLyXoa(context, dot, onLoad);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: null, // Để null để PopupMenuButton tự kích hoạt
      icon: const Icon(Icons.history_toggle_off_outlined, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hủy đợt chốt (${dsDotChot.length})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    ),
  );
}

void _xuLyXoa(
    BuildContext context,
    PhienChotCong phienChot,
    Future<void> Function()? onLoad,
    ) {
  final repo = ChamCongLuongRepo();
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa đợt chốt công ngày ${phienChot.denNgayStr ?? phienChot.ngayChot}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // 1. Thực hiện xóa dưới Database
              await repo.huyKhoaChamCong(phienChot.id);

              // 2. Đóng Dialog
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                showSuccessToast(context, "Hủy thành công");
              }

              // 3. Load lại danh sách
              if (onLoad != null) {
                await onLoad();
              }
            },
            child: const Text('Đồng ý xóa'),
          ),
        ],
      );
    },
  );
}