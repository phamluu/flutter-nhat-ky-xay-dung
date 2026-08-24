import 'package:excel/excel.dart';
import '../../luong/data/repositories/ChiLuongRepository.dart';
import '../../luong/data/services/ChiLuongService.dart';
Future<void> ChiLuongExcel({
  required Sheet sheetChiLuong,
  String? kyLuong,
  int? idBangChamCong,
  required int idCongTrinh,
}) async {
  ChiLuongService service = ChiLuongService(ChiLuongRepository());
  final chiLuongs = await service.getByCongTrinhThangNam(
    idCongTrinh,
    idBangChamCong: idBangChamCong,
    kyLuong: kyLuong,
  );

  // STYLE
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

  final normalStyle = CellStyle(
    fontSize: 7,
  );

  // TITLE
  String title = "CHI LƯƠNG THÁNG $kyLuong";
  sheetChiLuong
      .cell(CellIndex.indexByString("A1"))
      .value = title;
  sheetChiLuong
      .cell(CellIndex.indexByString("A1"))
      .cellStyle = titleStyle;

  // HEADER
  final headers = ["STT", "Tên nhân viên", "Số tiền", "Ngày chi", "Ghi chú"];

  for (int i = 0; i < headers.length; i++) {
    final cell = sheetChiLuong.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
    cell.value = headers[i];
    cell.cellStyle = headerStyle;
  }

  // DATA
  int rowIndex = 3;
  int stt = 1;
  double tongTien = 0;

  for (var item in chiLuongs) {
    sheetChiLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = stt;

    sheetChiLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = item.tenNhanVien ?? "";

    sheetChiLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = item.soTien;

    sheetChiLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = "${item.ngayChi.day}/${item.ngayChi.month}/${item.ngayChi.year}";

    sheetChiLuong
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        .value = item.ghiChu ?? "";

    // style
    for (int i = 0; i < 5; i++) {
      sheetChiLuong
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
          .cellStyle = normalStyle;
    }

    tongTien += item.soTien ?? 0;
    stt++;
    rowIndex++;
  }

  // TOTAL
  sheetChiLuong
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
      .value = "Tổng";

  sheetChiLuong
      .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
      .value = tongTien;

  sheetChiLuong
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
      .cellStyle = headerStyle;

  sheetChiLuong
      .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
      .cellStyle = headerStyle;
  sheetChiLuong.setColWidth(0, 4);
}