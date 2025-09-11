import 'package:nhat_ky_xay_dung/data/models/ChamCong.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/trang_thai_cham_cong.dart';
import 'package:intl/intl.dart';

Future<void> export(List<ChamCong> list, [String? tenCongTrinh]) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final monthYearFormat = DateFormat('MM/yyyy');

  // Load font Unicode hỗ trợ tiếng Việt
  final font = await PdfGoogleFonts.robotoRegular();
  final boldFont = await PdfGoogleFonts.robotoBold();

  // Nhóm theo tháng/năm
  final Map<String, List<ChamCong>> grouped = {};
  for (var u in list) {
    DateTime? ngay;
    try {
      ngay = DateTime.parse(u.ngay); // parse từ string yyyy-MM-dd
    } catch (_) {}
    final key = ngay != null ? monthYearFormat.format(ngay) : "Chưa có ngày";
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
              'BÁO CÁO CHẤM CÔNG ${tenCongTrinh ?? ""}',
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
                    'Chấm công tháng $monthYear',
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
                  headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2), // Nhân viên
                    1: const pw.FlexColumnWidth(2), // Ngày
                    2: const pw.FlexColumnWidth(2), // Trạng thái sáng
                    3: const pw.FlexColumnWidth(3), // Trạng thái chiều
                  },
                  cellAlignment: pw.Alignment.centerLeft,
                  headers: [
                    'Nhân viên',
                    'Ngày',
                    'Trạng thái sáng',
                    'Trạng thái chiều',
                  ],
                  data: items.map((u) {
                    DateTime? ngay;
                    try {
                      ngay = DateTime.parse(u.ngay);
                    } catch (_) {}
                    return [
                      u.nhanVienCongTrinh?.nhanVien?.hoTen ?? "Không tên",
                      ngay != null ? dateFormat.format(ngay) : "Chưa có",
                      TrangThaiChamCong.fromValue(u.trangThaiSang).label,
                      TrangThaiChamCong.fromValue(u.trangThaiChieu).label,
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
