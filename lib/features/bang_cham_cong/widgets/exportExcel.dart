import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/viewmodel/ChamCongModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../core/utils/trang_thai_luong.dart';

 Future<void> exportExcelFull({
     required  BuildContext context,
     required  List<ChamCongModel> data,
     required  int soNgay,
     required  int selectedYear,
     required  int selectedMonth}) async {
  // var status = await Permission.storage.request();
  // if (!status.isGranted) return;

  var excel = Excel.createExcel();
  Sheet sheet = excel['ChamCong'];

  /// ===== HEADER (FULL) =====
  List<String> header = [
    "Họ tên",
    "Chức vụ",
  ];

  // 👉 luôn full ngày
  for (int i = 1; i <= soNgay; i++) {
    header.add(i.toString());
  }

  header
      .addAll(["Tổng công", "Tổng lương", "Đã ứng", "Thực nhận", "Trạng thái"]);

  sheet.appendRow(header);

  /// ===== DATA =====
  for (var nv in data) {
    List<dynamic> row = [];

    /// 👉 luôn có
    row.add(nv.ten ?? "");
    row.add(nv.chucVu ?? "");

    /// 👉 luôn full ngày
    for (int i = 1; i <= soNgay; i++) {
      final ngay =
          "${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";

      final cc = nv.data[ngay];
      row.add(cc?.chamCong.hienThi ?? "");
    }

    row.add(nv.tongSoCong ?? 0);
    row.add(nv.tongTienCong ?? 0);
    row.add(nv.tongUng ?? 0);
    row.add(nv.thucNhan ?? 0);

    final trangthai = TrangThaiLuong.fromValue(nv.trangThai);
    row.add(trangthai == TrangThaiLuong.dachot ? "Đã chốt" : "Chưa chốt");

    sheet.appendRow(row);
  }

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
