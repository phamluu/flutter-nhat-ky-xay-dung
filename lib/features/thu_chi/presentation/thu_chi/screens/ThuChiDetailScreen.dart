import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/ThuChi.dart';

class ThuChiDetailScreen extends StatelessWidget {
  final ThuChi tc;
  const ThuChiDetailScreen({
    super.key,
    required this.tc
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tc.loai == 1 ? 'Chi tiết Thu' : 'Chi tiết Chi'),
        backgroundColor: tc.loai == 1 ? Colors.green : Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow("Số tiền:",
                    currencyFormat.format(tc.thanhTien),
                    color: tc.loai == 1 ? Colors.green : Colors.red,
                    isBold: true),
                const SizedBox(height: 8),
                _buildRow("Ngày:", DateUtilsCore.formatDate(tc.ngay)),
                const SizedBox(height: 8),
                _buildRow("Danh mục:",
                    tc.danhMucThuChi?.ten ?? "Không có"),
                const SizedBox(height: 8),
                _buildRow("Công trình:",
                    tc.congTrinh?.ten ?? "Không có"),
                const SizedBox(height: 8),
                _buildRow("Ghi chú:", tc.ghiChu ?? "—"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
