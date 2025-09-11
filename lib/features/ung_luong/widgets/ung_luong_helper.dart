import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVien.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/data/models/UngLuong.dart';
import 'package:nhat_ky_xay_dung/services/ung_luong_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/currencyFormat.dart';
import '../screens/UngLuongFormDialog.dart';
import 'package:intl/intl.dart';

import '../screens/UngLuongFormDialogForCongTrinh.dart';
import '../screens/UngLuongFormDialogGeneral.dart';
class UngLuongHelper {

  static Future<void> showFormDialog({
    required BuildContext context,
    Ungluong? ungLuong,
    required List<NhanVien> nhanViens,
    required List<NhanVienCongTrinh> nhanVienCongTrinhs,
    required UngLuongService service,
    required VoidCallback onSuccess,
    int? idCongTrinh,
  }) async {
    showDialog(
      context: context,
      builder: (_) => idCongTrinh != null
          ? UngLuongFormDialogForCongTrinh(
                ungLuong: ungLuong,
                nhanVienCongTrinhs: nhanVienCongTrinhs,
                idCongTrinh: idCongTrinh,
                onSave: (u) async {
                  if (u.id == null) {
                    await service.addUngLuong(u);
                  } else {
                    await service.updateUngLuong(u);
                  }
                  onSuccess();
                },
              )
          : UngLuongFormDialogGeneral(
        ungLuong: ungLuong,
        nhanViens: nhanViens,
        nhanVienCongTrinhs: nhanVienCongTrinhs,
        onSave: (u) async {
          if (u.id == null) {
            await service.addUngLuong(u);
          } else {
            await service.updateUngLuong(u);
          }
          onSuccess();
        },
      ),
    );
  }

  static Future<void> deleteUngLuong({
    required BuildContext context,
    required Ungluong ungLuong,
    required UngLuongService service,
    required VoidCallback onSuccess,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa ứng lương này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.deleteUngLuong(ungLuong.id!);
        onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Xóa ứng lương thành công",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Xóa thất bại: ${e.toString()}",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> export(List<Ungluong> list) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final monthYearFormat = DateFormat('MM/yyyy');

    // Load font Unicode hỗ trợ tiếng Việt
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    // Nhóm theo tháng/năm
    final Map<String, List<Ungluong>> grouped = {};
    for (var u in list) {
      final key = u.ngayUng != null ? monthYearFormat.format(u.ngayUng!) : "Chưa có ngày";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(u);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'BÁO CÁO ỨNG LƯƠNG',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Duyệt qua từng tháng/năm
            ...grouped.entries.map((entry) {
              final monthYear = entry.key;
              final items = entry.value;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
                    child: pw.Text(
                      'Chi lương tháng $monthYear',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                  ),
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      font: boldFont,
                      fontSize: 12,
                    ),
                    cellStyle: pw.TextStyle(
                      font: font,
                      fontSize: 11,
                    ),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2), // Nhân viên
                      1: const pw.FlexColumnWidth(2), // Số tiền
                      2: const pw.FlexColumnWidth(2), // Ngày
                      3: const pw.FlexColumnWidth(3), // Công trình
                      4: const pw.FlexColumnWidth(3), // Lý do
                    },
                    cellAlignment: pw.Alignment.centerLeft,
                    headers: [
                      'Nhân viên',
                      'Số tiền',
                      'Ngày',
                      'Công trình',
                      'Lý do',
                    ],
                    data: items.map((u) {
                      return [
                        u.nhanVien?.hoTen ?? "Không tên",
                        currencyFormat.format(u.soTien ?? 0),
                        u.ngayUng != null ? dateFormat.format(u.ngayUng!) : "Chưa có",
                        u.nhanVienCongTrinh?.congTrinh?.ten ?? "Không có",
                        u.lyDo ?? "",
                      ];
                    }).toList(),
                  ),
                ],
              );
            }),
          ];
        },
      ),
    );

    // Xuất PDF
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

}
