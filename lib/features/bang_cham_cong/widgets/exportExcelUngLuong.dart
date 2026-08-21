import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../luong/data/models/UngLuong.dart';
import '../../luong/data/services/ung_luong_service.dart';

Future<void> UngLuongExecl({
  required Sheet sheetUngLuong,
  required int selectedYear,
  required int selectedMonth,
  required int idCongTrinh,
}) async {
  // 🔹 Lấy dữ liệu
  List<UngLuongViewModel> ungLuongs = [];
  UngLuongService service = UngLuongService();
  ungLuongs =
  await service.getDanhSach(idCongTrinh, selectedMonth, selectedYear);

  /// ===== STYLE =====
  final headerStyle = CellStyle(
    bold: true,
    fontSize: 7,
    backgroundColorHex: "#D9D9D9",
    horizontalAlign: HorizontalAlign.Center,
  );

  final nameStyle = CellStyle(
    bold: true,
    fontSize: 7,
  );

  final totalStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Right,
    fontSize: 7,
  );

  final moneyStyle = CellStyle(
    horizontalAlign: HorizontalAlign.Right,
    fontSize: 7,
  );

  final currencyFormat = NumberFormat("#,###");

  /// ===== TITLE =====
  sheetUngLuong.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
  );

  sheetUngLuong
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      .value =
  "DANH SÁCH ỨNG LƯƠNG THÁNG $selectedMonth/$selectedYear";

  /// ===== HEADER =====
  List<String> headerUng = [
    "STT",
    "Họ tên",
    "Số tiền",
    "Ngày ứng",
    "Ghi chú"
  ];
  sheetUngLuong.appendRow(headerUng);
  for (int col = 0; col < headerUng.length; col++) {
    sheetUngLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1))
        .cellStyle = headerStyle;
  }

  /// ===== WIDTH =====
  sheetUngLuong.setColWidth(0, 5);
  sheetUngLuong.setColWidth(1, 10);
  sheetUngLuong.setColWidth(2, 8);
  sheetUngLuong.setColWidth(3, 10);
  sheetUngLuong.setColWidth(4, 20);

  /// ===== DATA =====
  int stt = 1;
  int currentRow = 2;
  for (var nv in ungLuongs) {
    // 🔹 Tên nhân viên (merge)
    sheetUngLuong.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
    );
    var nameCell = sheetUngLuong.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));

    nameCell.value = nv.hoTen ?? "";
    nameCell.cellStyle = nameStyle;
    currentRow++;
    // 🔹 Danh sách ứng lương
    for (var ung in nv.daUngs) {
      sheetUngLuong.appendRow([
        stt,
        "",
        currencyFormat.format(ung.soTien),
        ung.ngayUng != null
            ? "${ung.ngayUng!.day}/${ung.ngayUng!.month}/${ung.ngayUng!.year}"
            : "",
        ung.lyDo ?? "",
      ]);
      for (int col = 0; col < 5; col++) {
        sheetUngLuong
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
            .cellStyle = CellStyle(fontSize: 7);
      }
      sheetUngLuong
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
          .cellStyle = moneyStyle;
      stt++;
      currentRow++;
    }
    // 🔹 Dòng tổng
    sheetUngLuong.appendRow([
      "",
      "Tổng",
      currencyFormat.format(nv.tongUng),
      "",
      ""
    ]);

    // Style dòng tổng
    sheetUngLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
        .cellStyle = totalStyle;
    sheetUngLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow))
        .cellStyle = totalStyle;
    currentRow++;

    // 🔹 Dòng trống ngăn cách
    sheetUngLuong.appendRow(["", "", "", "", ""]);
    currentRow++;
  }
}