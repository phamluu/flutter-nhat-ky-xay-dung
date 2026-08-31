import 'package:flutter/material.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_luong.dart';
import '../../data/models/ChamCongModel.dart';

class ChamCongChiTietNhanVienDesktop extends StatelessWidget {
  final ChamCongLuongNhanVienModel model;
  final String? tenCongTrinh;
  final String? thangKey;
  final int thang;
  final int nam;

  const ChamCongChiTietNhanVienDesktop({
    super.key,
    required this.model,
    this.tenCongTrinh,
    this.thangKey,
    required this.thang,
    required this.nam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDaChot = model.luong.trangThaiChotLuong == TrangThaiLuong.dachot.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Chi tiết công & lương - ${model.chamCong.ten ?? 'Nhân viên'}"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDaChot ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDaChot ? Colors.green.shade300 : Colors.orange.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDaChot ? Icons.check_circle_outline : Icons.pending_actions,
                  size: 16,
                  color: isDaChot ? Colors.green.shade700 : Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  isDaChot ? "Đã chốt lương" : "Chưa chốt lương",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDaChot ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildDailyDetailsTable(context),
            ],
          ),
        ),
      ),
    );
  }

  // 1. HEADER: Thông tin nhân viên & công trình
  Widget _buildHeaderCard(BuildContext context) {
    final nv = model.chamCong;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              (nv.ten != null && nv.ten!.isNotEmpty) ? nv.ten![0].toUpperCase() : 'NV',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nv.ten ?? "Chưa đặt tên",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.badge_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    "Chức vụ: ${nv.chucVu ?? 'Chưa cập nhật'}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.construction, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    "Công trình: ${tenCongTrinh ?? 'Chưa xác định'}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Tháng $thang / $nam",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. STATS CARDS: Tổng hợp số liệu công & tiền lương
  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildStatItem("TỔNG SỐ CÔNG", "${model.chamCong.tongSoCong} công", Colors.blue),
        const SizedBox(width: 12),
        _buildStatItem("TỔNG TỀN CÔNG", formatCurrency(model.tongLuongHienThi), Colors.indigo),
        const SizedBox(width: 12),
        _buildStatItem("ĐÃ ỨNG LƯƠNG", formatCurrency(model.tongUngHienThi), Colors.orange.shade800),
        const SizedBox(width: 12),
        _buildStatItem("TRỪ ỨNG", formatCurrency(model.luong.truUng), Colors.purple),
        const SizedBox(width: 12),
        _buildStatItem("THỰC NHẬN", formatCurrency(model.thucNhanHienThi), Colors.green.shade700),
        const SizedBox(width: 12),
        _buildStatItem("CÒN PHẢI TRẢ", formatCurrency(model.luong.conPhaiTra), Colors.red.shade700),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. TABLE CHI TIẾT THEO NGÀY
  Widget _buildDailyDetailsTable(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(nam, thang);
    final Map<String, ChamCongNgayLuong> data = model.chamCong.data;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Chi tiết bảng công & lương từng ngày",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          DataTable(
            columnSpacing: 20,
            headingRowHeight: 46,
            dataRowMinHeight: 48,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            columns: const [
              DataColumn(label: Text("Ngày", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Thứ", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Ký hiệu công", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Số công", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Mức lương ngày", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Thành tiền công", style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Ghi chú", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(daysInMonth, (index) {
              final dayNumber = index + 1;
              final dayKey = "${thangKey}-${dayNumber.toString().padLeft(2, '0')}";
              final date = DateTime(nam, thang, dayNumber);
              final isSun = date.weekday == DateTime.sunday;

              final chamCongNgayLuong = model.chamCong.data[dayKey];
              final chamCong = chamCongNgayLuong?.chamCong;

              final hienThi = chamCong?.hienThi ?? "...";
              final soCong = chamCong?.soCong ?? 0.0;
              final luongNgay = chamCongNgayLuong?.luongNgay ?? 0.0;
              final tienCongNgay = chamCongNgayLuong?.tienCongNgay ?? 0.0;
              final ghiChu = chamCong?.ghiChu ?? "";

              final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

              return DataRow(
                color: WidgetStateProperty.all( isSun ? Colors.red.shade50.withOpacity(0.4) :
                      (index.isEven ? Colors.grey.shade50 : Colors.white),),
                cells: [
                  DataCell(Text(
                    "${dayNumber.toString().padLeft(2, '0')}/$thang",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text(
                    weekdays[date.weekday - 1],
                    style: TextStyle(
                      color: isSun ? Colors.red : Colors.black26,
                      fontWeight: isSun ? FontWeight.bold : FontWeight.normal,
                    ),
                  )),
                  DataCell(_buildStatusBadge(hienThi)),
                  DataCell(Text(soCong > 0 ? "$soCong công" : "-")),
                  DataCell(Text(luongNgay > 0 ? formatCurrency(luongNgay) : "-")),
                  DataCell(Text(
                    tienCongNgay > 0 ? formatCurrency(tienCongNgay) : "-",
                    style: TextStyle(
                      fontWeight: tienCongNgay > 0 ? FontWeight.bold : FontWeight.normal,
                      color: tienCongNgay > 0 ? Colors.green.shade800 : Colors.black,
                    ),
                  )),
                  DataCell(Text(ghiChu.isEmpty ? "-" : ghiChu)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị ký hiệu công (X, /, 0, ...)
  Widget _buildStatusBadge(String hienThi) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.grey.shade700;

    if (hienThi == "X") {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
    } else if (hienThi == "/") {
      bg = Colors.orange.shade100;
      fg = Colors.orange.shade900;
    } else if (hienThi == "0") {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hienThi,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: fg),
      ),
    );
  }
}