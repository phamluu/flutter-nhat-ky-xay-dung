import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/widgets/exportExcelChamCong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/widgets/exportExcelChiLuong.dart';
import 'package:nhat_ky_xay_dung/viewmodel/ChamCongModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_luong.dart';
import 'exportExcelUngLuong.dart';
Future<void> exportExcelFull({
  required BuildContext context,
  required List<ChamCongModel> data,
  required int soNgay,
  required int selectedYear,
  required int selectedMonth,
  required int idCongTrinh,
  String? tenCongTrinh
}) async {
  var excel = Excel.createExcel();
  // Bổ sung
  // String defaultSheet = excel.getDefaultSheet()!;
  // excel.rename(defaultSheet, 'ChamCong');
  // Bổ sung
  Sheet sheet = excel['ChamCong'];
  Sheet sheetUngLuong = excel['UngLuong'];
  Sheet sheetChiLuong = excel['ChiLuong'];
  await ChamCongExcel(
      sheet: sheet,
      data: data,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth,
      idCongTrinh: idCongTrinh);
  await UngLuongExecl(sheetUngLuong: sheetUngLuong,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth,
      idCongTrinh: idCongTrinh
  );
  await ChiLuongExcel(sheetChiLuong: sheetChiLuong,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth,
      idCongTrinh: idCongTrinh);
  /// ===== SAVE FILE =====
  Directory? dir;

  if (Platform.isAndroid) {
    dir = await getExternalStorageDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  String path =
      "${dir!.path}/ChamCong_FULL_${selectedMonth}_$selectedYear.xlsx";

  File file = File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);

  OpenFile.open(path);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Đã xuất file FULL: $path")),
  );
}
