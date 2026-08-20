import 'package:excel/excel.dart';

import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_luong.dart';
import '../data/models/ChamCongModel.dart';

Future<void> ChamCongExcel(
    {required Sheet sheet,
    required List<ChamCongModel> data,
    required int selectedYear,
    required int selectedMonth,
    required int idCongTrinh,
    String? tenCongTrinh}) async {
  /// ===== LẤY NGÀY CÓ CHẤM CÔNG =====
  Set<String> ngayCoChamCongSet = {};
  for (var nv in data) {
    nv.data.forEach((ngay, value) {
      if (value != null && value.chamCong.hienThi.isNotEmpty) {
        ngayCoChamCongSet.add(ngay);
      }
    });
  }
  List<String> ngayCoChamCong = ngayCoChamCongSet.toList()..sort();

  /// ===== STYLE =====
  final titleStyle = CellStyle(
    bold: true,
    fontSize: 10,
    horizontalAlign: HorizontalAlign.Left,
    fontColorHex: "#FF0000",
  );
  final headerStyle = CellStyle(
    bold: true,
    fontSize: 7,
    backgroundColorHex: "#D9D9D9",
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  /// ===== TITLE =====
  String title = "BẢNG CHẤM CÔNG THÁNG $selectedMonth/$selectedYear";
  String congTrinh = tenCongTrinh != null && tenCongTrinh.isNotEmpty
      ? "Công trình: $tenCongTrinh"
      : "";
  int totalColumns = 3 + ngayCoChamCong.length + 5;
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    CellIndex.indexByColumnRow(columnIndex: totalColumns - 1, rowIndex: 0),
  );
  var titleCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
  titleCell.value = title;
  titleCell.cellStyle = titleStyle;
// Công trình (dòng 1)
  if (congTrinh.isNotEmpty) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: totalColumns - 1, rowIndex: 1),
    );

    var congTrinhCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
    congTrinhCell.value = congTrinh;
    congTrinhCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 9,
    );
  }

  /// ===== HEADER =====
  List<String> header = ["STT", "Họ tên", "Chức vụ"];

  for (var ngay in ngayCoChamCong) {
    header.add(ngay.split("-").last);
  }
  header
      .addAll(["Tổng công", "Tổng lương", "Đã ứng", "Thực nhận", "Trạng thái"]);
  int headerRowIndex = congTrinh.isNotEmpty ? 2 : 1;
  sheet.insertRowIterables(header, headerRowIndex);
// Style header
  for (int col = 0; col < header.length; col++) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRowIndex),
    );
    cell.cellStyle = headerStyle;
  }

  /// ===== DATA =====
  int stt = 1;
  for (var nv in data) {
    List<dynamic> row = [];
    row.add(stt++);
    row.add(nv.ten ?? "");
    row.add(nv.chucVu ?? "");

    for (var ngay in ngayCoChamCong) {
      final cc = nv.data[ngay];
      row.add(cc?.chamCong.hienThi ?? "");
    }
    row.add(nv.tongSoCong ?? 0);
    row.add(formatCurrency(nv.tongTienCong ?? 0));
    row.add(formatCurrency(nv.tongUngHienThi ?? 0));
    row.add(formatCurrency(nv.thucNhanHienThi ?? 0));

    final trangthai = TrangThaiLuong.fromValue(nv.trangThai);
    row.add(trangthai == TrangThaiLuong.dachot ? "Đã chốt" : "Chưa chốt");

    sheet.appendRow(row);
  }

  /// ===== AUTO STYLE DATA =====
  int startDataRow = headerRowIndex + 1;
  for (int row = startDataRow; row < data.length + startDataRow; row++) {
    for (int col = 0; col < totalColumns; col++) {
      var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      );

      cell.cellStyle = CellStyle(
        fontSize: 7,
        horizontalAlign: col >= 3 && col < 3 + ngayCoChamCong.length
            ? HorizontalAlign.Center
            : HorizontalAlign.Left,
      );
    }
  }

  /// ===== COLUMN WIDTH =====
  sheet.setColWidth(0, 4);
  sheet.setColWidth(1, 12); // Họ tên rộng
  sheet.setColWidth(2, 9); // Chức vụ

  for (int i = 3; i < 3 + ngayCoChamCong.length; i++) {
    sheet.setColWidth(i, 3); // Ngày nhỏ
  }

  int startSummary = 3 + ngayCoChamCong.length;
  for (int i = startSummary; i < totalColumns; i++) {
    sheet.setColWidth(i, 15);
  }
}
