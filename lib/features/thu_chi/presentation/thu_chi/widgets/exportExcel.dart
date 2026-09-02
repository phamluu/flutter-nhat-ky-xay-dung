import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';
import 'package:nhat_ky_xay_dung/core/utils/date_utils.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

import '../../../data/models/ThuChi.dart';

Future<void> exportExcelThuChi({
  required BuildContext context,
  required Future<ThuChiCongTrinhViewModel> data,
  String? tenCongTrinh,
  DateTime? tuNgay,
  DateTime? denNgay,
}) async {
  final vm = await data;
  var excel = Excel.createExcel();

  Sheet sheetObject = excel['Sheet1'];

  final titleStyle = CellStyle(
    bold: true,
    fontSize: 14,
    fontColorHex: "#DC143C",
    horizontalAlign: HorizontalAlign.Center,
  );

  // Style cho Header của Bảng (có border)
  final tableHeaderStyle = CellStyle(
    bold: true,
    fontSize: 10,
    fontColorHex: "#1F497D",
    horizontalAlign: HorizontalAlign.Center,
  );

  final categoryHeaderStyle = CellStyle(
    bold: true,
    fontSize: 13,
    fontColorHex: "#1F497D",
  );

  // Style dữ liệu ô (có border)
  final alignLeftWithBorder = CellStyle(
    horizontalAlign: HorizontalAlign.Left,
  );

  final alignCenterWithBorder = CellStyle(
    horizontalAlign: HorizontalAlign.Center,
  );

  final alignRightWithBorder = CellStyle(
    horizontalAlign: HorizontalAlign.Right,
  );

  int currentRow = 0;

  void appendStyledRow(
      List<dynamic> rowValues, [ CellStyle? style, Map<int, CellStyle>? columnStyles,]) {
    sheetObject.appendRow(rowValues.map((v) => v?.toString() ?? '').toList());
    for (int col = 0; col < rowValues.length; col++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow),
      );
      if (columnStyles != null && columnStyles.containsKey(col)) {
        cell.cellStyle = columnStyles[col]!;
      } else if (style != null) {
        cell.cellStyle = style;
      }
    }
    currentRow++;
  }

  // 2. TIÊU ĐỀ VÀ THÔNG TIN BÁO CÁO
  appendStyledRow(['BÁO CÁO THU CHI CÔNG TRÌNH'], titleStyle);
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow - 1),
  );
  String strTuNgay = tuNgay != null ? DateUtilsCore.formatDate(tuNgay.toString()) : '...';
  String strDenNgay = denNgay != null ? DateUtilsCore.formatDate(denNgay.toString()) : '...';

  appendStyledRow(['', 'Công trình:', tenCongTrinh ?? 'Chưa xác định']);
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow - 1),
  );
  appendStyledRow(['', 'Thời gian:', 'Từ $strTuNgay đến $strDenNgay']);
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow - 1),
  );
  appendStyledRow(['']);
  appendStyledRow(['']);
  appendStyledRow(['','CÁC KHOẢN THU CHI'], categoryHeaderStyle);
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow - 1),
  );
  appendStyledRow(['', 'Tạm ứng lương:', formatCurrency(vm.tamUngLuong ?? 0)], CellStyle(bold: true));
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow - 1),
  );
  appendStyledRow(['', 'Đã chi lương:', formatCurrency(vm.daChiLuong ?? 0)], CellStyle(bold: true));
  sheetObject.merge(
    CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow - 1),
    CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow - 1),
  );

  // 4. DUYỆT DANH MỤC THU CHI
  final listThuChiDanhMucs = vm.thuChiDanhMucs;
  for (var i = 0; i < listThuChiDanhMucs.length; i++) {
    final dm = listThuChiDanhMucs[i];
    if (dm.thuchis != null && dm.thuchis!.isNotEmpty) {
      appendStyledRow(['']); // Dòng trống cách biệt giữa các Danh mục với nhau
      // In Tên Danh Mục
      appendStyledRow([
        '','${i + 1}. ${dm.danhMucThuChi?.ten ?? "Danh mục"}',
        '', '', '',
        'Số dư:', formatCurrency(dm.conLai ?? 0)
      ], categoryHeaderStyle);

      // IN TRỰC TIẾP HEADER BẢNG (Không có dòng trống ở giữa)
      appendStyledRow(
        ['STT', 'Tên hàng', 'Đơn vị tính', 'Số lượng', 'Đơn giá', 'Thành tiền', 'Ngày thực hiện'],
        tableHeaderStyle,
      );

      for (var j = 0; j < dm.thuchis!.length; j++) {
        final item = dm.thuchis![j];
        appendStyledRow([
          j + 1,
          item?.tenHangHoa ?? '',
          item?.donViTinh ?? '',
          item?.soLuong ?? 0,
          formatCurrency(item?.donGia ?? 0),
          formatCurrency(item?.thanhTien ?? 0),
          DateUtilsCore.formatDate(item?.ngay.toString())
        ], alignLeftWithBorder, {
          0: alignCenterWithBorder,
          1: alignLeftWithBorder,
          2: alignCenterWithBorder,
          3: alignRightWithBorder,
          4: alignRightWithBorder,
          5: alignRightWithBorder,
          6: alignCenterWithBorder,
        });
      }
    }
  }

  // 5. THU CHI KHÁC
  final listKhac = vm.thuChiKhacs.thuchis;
  if (listKhac != null && listKhac.isNotEmpty) {
    appendStyledRow(['']); // Dòng trống ngăn cách

    appendStyledRow([
      '','THU CHI KHÁC', '', '', '',
      'Số dư:', formatCurrency(vm.thuChiKhacs.conLai ?? 0)
    ], categoryHeaderStyle);

    // IN TRỰC TIẾP HEADER BẢNG (Không có dòng trống ở giữa)
    appendStyledRow(
      ['STT', 'Tên hàng', 'Đơn vị tính', 'Số lượng', 'Đơn giá', 'Thành tiền', 'Ngày thực hiện'],
      tableHeaderStyle,
    );

    for (var j = 0; j < listKhac.length; j++) {
      final item = listKhac[j];
      appendStyledRow([
        j + 1,
        item.tenHangHoa ?? '',
        item.donViTinh ?? '',
        item.soLuong ?? 0,
        formatCurrency(item.donGia ?? 0),
        formatCurrency(item.thanhTien ?? 0),
        DateUtilsCore.formatDate(item.ngay.toString())
      ], alignLeftWithBorder, {
        0: alignCenterWithBorder,
        1: alignLeftWithBorder,
        2: alignCenterWithBorder,
        3: alignRightWithBorder,
        4: alignRightWithBorder,
        5: alignRightWithBorder,
        6: alignCenterWithBorder,
      });
    }
  }

  // 6. CẤU HÌNH ĐỘ RỘNG CỘT
  sheetObject.setColWidth(0, 8.0);  // STT
  sheetObject.setColWidth(1, 28.0); // Tên hàng
  sheetObject.setColWidth(2, 14.0); // ĐVT
  sheetObject.setColWidth(3, 12.0); // Số lượng
  sheetObject.setColWidth(4, 18.0); // Đơn giá
  sheetObject.setColWidth(5, 20.0); // Thành tiền
  sheetObject.setColWidth(6, 16.0); // Ngày thực hiện

  // 7. LƯU FILE
  String sanitizedName = (tenCongTrinh ?? 'CongTrinh')
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '_');

  String fileName = 'ThuChi_${sanitizedName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Chọn nơi lưu file Excel',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (outputFile != null) {
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      if (context.mounted) {
        showSuccessToast(context, 'Đã lưu file tại: $outputFile');
      }
    }
  }
}