import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/widgets/exportExcelChamCong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/widgets/exportExcelChiLuong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/ChamCongModel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'exportExcelUngLuong.dart';
Future<void> exportExcelFull({
  required BuildContext context,
  required List<ChamCongLuongNhanVienModel> data,
  required int soNgay,
  int? idBangChamCong,
  required int idCongTrinh,
  String? tenCongTrinh,
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
      idCongTrinh: idCongTrinh, idBangChamCong: idBangChamCong!);
  await UngLuongExecl(sheetUngLuong: sheetUngLuong,
      idCongTrinh: idCongTrinh
  );
  await ChiLuongExcel(sheetChiLuong: sheetChiLuong, idCongTrinh: idCongTrinh);
  /// ===== SAVE FILE =====
  Directory? dir;

  if (Platform.isAndroid) {
    dir = await getExternalStorageDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  String path =
      "${dir!.path}/ChamCong_FULL_${idBangChamCong}.xlsx";

  File file = File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(excel.encode()!);

  OpenFilex.open(path);
showSuccessToast(context, "Đã xuất file FULL: $path");

}
