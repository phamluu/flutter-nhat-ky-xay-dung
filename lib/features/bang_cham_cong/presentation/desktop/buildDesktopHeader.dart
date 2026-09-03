import 'package:flutter/material.dart';

import '../../widgets/chotCongBtn.dart';

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
    List<dynamic> dsDotChot = const [],
    Function(int idPhienChot)? onHuyDotChot,
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
                daKhoa: daKhoa,
                daChotLuong: daChotLuong,
                onHuyDotChot: onHuyDotChot ?? (_) {},
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
        // REFRESH
        // OutlinedButton.icon(
        //   onPressed: _isLoading ? null : _load,
        //   icon: const Icon(
        //     Icons.refresh,
        //     size: 18,
        //   ),
        //   label: const Text("Làm mới"),
        // ),
      ],
    ),
  );
}

Widget _buildHuyDotChotMenu({
  required BuildContext context,
  required List<dynamic> dsDotChot, // Thay dynamic bằng Model PhienChotCong của bạn
  required bool daKhoa,
  required bool daChotLuong,
  required Function(int idPhienChot) onHuyDotChot,
}) {
  final bool isEnabled = !(daKhoa || daChotLuong) && dsDotChot.isNotEmpty;

  return PopupMenuButton<int>(
    tooltip: 'Danh sách đợt chốt công',
    enabled: isEnabled,
    onSelected: (idPhienChot) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận hủy đợt chốt'),
          content: const Text(
            'Bạn có chắc chắn muốn hủy đợt chốt này không?\n'
                'Dữ liệu chấm công của đợt này sẽ quay về trạng thái chưa khóa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onHuyDotChot(idPhienChot);
              },
              child: const Text('Đồng ý hủy'),
            ),
          ],
        ),
      );
    },
    offset: const Offset(0, 45),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    itemBuilder: (context) => [
      const PopupMenuItem<int>(
        enabled: false,
        child: Text(
          'CHỌN ĐỢT ĐỂ HỦY CHỐT',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const PopupMenuDivider(),
      ...dsDotChot.map(
            (dot) => PopupMenuItem<int>(
          value: dot.id,
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đợt ${dot.maDot}: Đến ${dot.denNgayStr ?? dot.denNgay}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (dot.soLuongNV != null)
                      Text(
                        '${dot.soLuongNV} nhân viên',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade600,
              ),
            ],
          ),
        ),
      ),
    ],
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: isEnabled ? Colors.red.shade700 : Colors.grey,
        side: BorderSide(
          color: isEnabled ? Colors.red.shade300 : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: null, // Để null để PopupMenuButton tự nhận diện sự kiện click
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