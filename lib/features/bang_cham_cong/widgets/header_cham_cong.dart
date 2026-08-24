import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/ChamCongModel.dart';
import 'buildToggle.dart';
import 'exportExcel.dart';

class HeaderChamCong extends StatelessWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  final bool showTen;
  final bool showChucVu;
  final bool show10Dau;
  final bool show10Giua;
  final bool show10Cuoi;

  final Function() onToggleTen;
  final Function() onToggleChucVu;
  final ValueChanged<bool> onToggle10Dau;
  final ValueChanged<bool> onToggle10Giua;
  final ValueChanged<bool> onToggle10Cuoi;

  final List<ChamCongNhanVienModel> data;
  final int soNgay;
  final int selectedMonth;
  final int selectedYear;

  const HeaderChamCong({
    super.key,
    required this.idCongTrinh,
    this.tenCongTrinh,
    required this.showTen,
    required this.showChucVu,
    required this.show10Dau,
    required this.show10Giua,
    required this.show10Cuoi,
    required this.onToggleTen,
    required this.onToggleChucVu,
    required this.onToggle10Dau,
    required this.onToggle10Giua,
    required this.onToggle10Cuoi,
    required this.data,
    required this.soNgay,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HÀNG 1
          Row(
            children: [
              TextButton.icon(
                onPressed: onToggleTen,
                icon: Icon(
                  showTen ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blue,
                ),
                label: Text(showTen ? "Ẩn họ tên" : "Hiện họ tên"),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onToggleChucVu,
                icon: Icon(
                  showChucVu ? Icons.badge_outlined : Icons.badge,
                  color: Colors.orange,
                ),
                label: Text(showChucVu ? "Ẩn chức vụ" : "Hiện chức vụ"),
              ),
            ],
          ),

          const SizedBox(height: 1),

          /// HÀNG 2
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildToggle("1-10", show10Dau, onToggle10Dau),
                const SizedBox(width: 10),
                buildToggle("11-20", show10Giua, onToggle10Giua),
                const SizedBox(width: 10),
                buildToggle("21+", show10Cuoi, onToggle10Cuoi),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                    );

                    await exportExcelFull(
                      context: context,
                      data: data,
                      soNgay: soNgay,
                      idCongTrinh: idCongTrinh,
                      tenCongTrinh: tenCongTrinh
                    );

                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}