// import 'package:flutter/material.dart';
// import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
// import '../../../core/utils/currencyFormat.dart';
// import '../../../core/utils/trang_thai_luong.dart';
// import '../../luong/presentation/ung_luong/screens/UngLuongScreen.dart';
// import '../data/repositories/ChamCongRepository.dart';
// import '../data/repositories/ChotChiLuongRepository.dart';
// import '../data/services/BangLuongService.dart';
// import '../data/services/ChotChiLuongService.dart';
// import '../data/services/cham_cong_service.dart';
// import '../data/models/ChamCongModel.dart';
// import '../widgets/BangLuongActionCell.dart';
// import '../widgets/ChamCongFilterState.dart';
// import '../widgets/filter_cham_cong.dart';
// import '../widgets/header_cham_cong.dart';
// import '../widgets/setKhoaChamCong.dart';
// import 'ChamCongNgayScreen.dart';
//
// class ChamCong2Screen extends StatefulWidget {
//   final int? idCongTrinh;
//   final String? tenCongTrinh;
//
//   const ChamCong2Screen({super.key, this.idCongTrinh, this.tenCongTrinh});
//
//   @override
//   State<ChamCong2Screen> createState() => _ChamCong2ScreenState();
// }
//
// class _ChamCong2ScreenState extends State<ChamCong2Screen> {
//   bool _showTen = true;
//   bool _showChucVu = true;
//   bool _show10Dau = true;
//   bool _show10Giua = true;
//   bool _show10Cuoi = true;
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//
//   List<ChamCongNhanVienModel> data = [];
//   late final BangLuongService _service;
//   late final Chotchiluongservice _chotService;
//   late final ChamCongService _chamCongService;
//   int get soNgay => DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
//   String get thang =>
//       "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}";
//   late var daKhoaCC = false;
//   late var coChotLuong = false;
//   @override
//   void initState() {
//     super.initState();
//     _showTen = ChamCongFilterState.showTen;
//     _showChucVu = ChamCongFilterState.showChucVu;
//     _show10Dau = ChamCongFilterState.show10Dau;
//     _show10Giua = ChamCongFilterState.show10Giua;
//     _show10Cuoi = ChamCongFilterState.show10Cuoi;
//     _selectedMonth = ChamCongFilterState.selectedMonth;
//     _selectedYear = ChamCongFilterState.selectedYear;
//     _service = BangLuongService(
//       chamCongService: ChamCongService(ChamCongRepository(), BangChamCongRepository()),
//       chotRepo: ChotChiLuongRepository(),
//     );
//     _chotService = Chotchiluongservice(ChotChiLuongRepository());
//     _chamCongService = ChamCongService(ChamCongRepository(), BangChamCongRepository());
//     _load();
//   }
//
//   Future<void> _load() async {
//     if (widget.idCongTrinh == null) return;
//     final result = await _service.loadChamCongLuong(
//         widget.idCongTrinh!, _selectedMonth, _selectedYear);
//     final Future<int?> idBangChamCong = _chamCongService.getChamCongId(widget.idCongTrinh!, _selectedMonth, _selectedYear);
//     final khoa = await _chamCongService.checkKhoaChamCong(idBangChamCong as int);
//     final isChotLuong = await _chotService.isTonTaiDaChotLuong(_selectedMonth, _selectedYear);
//     setState(() {
//       data = result;
//       daKhoaCC = khoa;
//       coChotLuong = isChotLuong;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Sổ chấm công"),
//             Text(widget.tenCongTrinh ?? "",
//                 style: const TextStyle(fontSize: 13)),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           FilterChamCong(
//             selectedMonth: _selectedMonth,
//             selectedYear: _selectedYear,
//             daKhoa: daKhoaCC,
//             daChotLuong: coChotLuong,
//             onMonthChanged: (value) {
//               setState(() {
//                 _selectedMonth = value;
//                 ChamCongFilterState.selectedMonth = value;
//               });
//               _load();
//             },
//             onYearChanged: (value) {
//               setState(() {
//                 _selectedYear = value;
//                 ChamCongFilterState.selectedYear = value;
//               });
//               _load();
//             },
//             onChotCong: () async {
//               await setkhoaChamCong(
//                   context: context,
//                   selectedMonth: _selectedMonth,
//                   selectedYear: _selectedYear,
//                   isKhoa: !daKhoaCC,
//                   daChotLuong: coChotLuong
//               );
//               await _load();
//             },
//           ),
//           HeaderChamCong(
//             idCongTrinh: widget.idCongTrinh!,
//             tenCongTrinh: widget.tenCongTrinh,
//             showTen: _showTen,
//             showChucVu: _showChucVu,
//             show10Dau: _show10Dau,
//             show10Giua: _show10Giua,
//             show10Cuoi: _show10Cuoi,
//
//             onToggleTen: () {
//               setState(() {
//                 _showTen = !_showTen;
//                 ChamCongFilterState.showTen = _showTen;
//               });
//             },
//
//             onToggleChucVu: () {
//               setState(() {
//                 _showChucVu = !_showChucVu;
//                 ChamCongFilterState.showChucVu = _showChucVu;
//               });
//             },
//
//             onToggle10Dau: (v) {
//               setState(() {
//                 _show10Dau = v;
//                 ChamCongFilterState.show10Dau = v;
//               });
//             },
//
//             onToggle10Giua: (v) {
//               setState(() {
//                 _show10Giua = v;
//                 ChamCongFilterState.show10Giua = v;
//               });
//             },
//
//             onToggle10Cuoi: (v) {
//               setState(() {
//                 _show10Cuoi = v;
//                 ChamCongFilterState.show10Cuoi = v;
//               });
//             },
//
//             data: data,
//             soNgay: soNgay,
//             selectedMonth: _selectedMonth,
//             selectedYear: _selectedYear,
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               if (_showTen)
//                 DataTable(
//                   columnSpacing: 2,
//                   border: TableBorder.all(color: Colors.grey),
//                   headingRowColor:
//                       MaterialStateProperty.all(Colors.green.shade300),
//                   columns: [
//                     DataColumn(label: Text("Họ tên")),
//                   ],
//                   rows: List.generate(data.length, (index) {
//                     final nv = data[index];
//                     return DataRow(
//                       cells: [
//                         DataCell(Text(nv.ten ?? "")),
//                       ],
//                     );
//                   }),
//                 ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: SingleChildScrollView(
//                     child: DataTable(
//                       columnSpacing: 10,
//                       border: TableBorder.all(color: Colors.grey),
//                       headingRowColor:
//                           MaterialStateProperty.all(Colors.green.shade300),
//                       columns: _buildColumns(),
//                       rows: _buildRows(),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   bool _isShowNgay(int day) {
//     if (day <= 10 && !_show10Dau) return false;
//     if (day >= 11 && day <= 20 && !_show10Giua) return false;
//     if (day >= 21 && !_show10Cuoi) return false;
//     return true;
//   }
//
//   // ===== COLUMNS =====
//   List<DataColumn> _buildColumns() {
//     List<DataColumn> columns = [
//       if (_showChucVu)
//         DataColumn(
//             label: Row(
//           children: [const Text("Chức vụ")],
//         ))
//     ];
//     for (int i = 1; i <= soNgay; i++) {
//       if (_isShowNgay(i)) {
//         columns.add(DataColumn(label: Text("$i")));
//       }
//       // columns.add(DataColumn(label: Text("$i")));
//     }
//     columns.add(const DataColumn(label: Text("Tổng công")));
//     columns.add(const DataColumn(label: Text("Tổng lương")));
//     columns.add(const DataColumn(label: Text("Đã ứng")));
//     columns.add(const DataColumn(label: Text("Thực nhận")));
//     columns.add(const DataColumn(label: Text("Trạng thái")));
//     columns.add(const DataColumn(label: Text("Hành động")));
//     return columns;
//   }
//
//   // ===== ROWS =====
//   List<DataRow> _buildRows() {
//     return List.generate(data.length, (index) {
//       final nv = data[index];
//       final trangthai = TrangThaiLuong.fromValue(nv.trangThai);
//       return DataRow(
//         color: MaterialStateProperty.resolveWith<Color?>(
//           (Set<MaterialState> states) {
//             if (index % 2 == 0) {
//               return Colors.grey.shade200; // dòng chẵn
//             }
//             return Colors.white; // dòng lẻ
//           },
//         ),
//         cells: [
//           if (_showChucVu) DataCell(Text(nv.chucVu)),
//           ...[
//             for (int i = 1; i <= soNgay; i++)
//               if (_isShowNgay(i))
//                 DataCell(
//                   Container(
//                     width: 35,
//                     height: 30,
//                     child: Builder(
//                       builder: (_) {
//                         final ngay =
//                             "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
//                         final cc = nv.data[ngay];
//                         return Center(
//                           child: Text(cc?.chamCong.hienThi ?? ""),
//                         );
//                       },
//                     ),
//                   ),
//
//                   /// 👇 ĐÚNG CHỖ
//                   onTap: () async {
//                     final ngay =
//                         "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
//                     String thang =
//                         "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}";
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChamCongNgayScreen(
//                           idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
//                           ngay: ngay,
//                           hoTen: nv.ten,
//                           tenCongTrinh: widget.tenCongTrinh,
//                           daKhoa: daKhoaCC,
//                         ),
//                       ),
//                     );
//
//                     _load();
//                   },
//                 )
//           ],
//           DataCell(
//             Text(
//               (nv.tongSoCong ?? 0).toString(),
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           DataCell(Text(formatCurrency(nv.tongTienCong))),
//           DataCell(
//             SizedBox(
//               child: Center(
//                 child: Text(formatCurrency(nv.tongUngHienThi)),
//               ),
//             ),
//             onTap: () async {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => UngLuongScreen(
//                     idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
//                     hoTen: nv.ten,
//                     congTrinh: widget.tenCongTrinh,
//                     thang: _selectedMonth,
//                     nam: _selectedYear,
//                   ),
//                 ),
//               ).then((_) {
//                 _load();
//               });
//             },
//           ),
//           DataCell(Text(formatCurrency(nv.thucNhan))),
//           DataCell(
//             Text(
//               trangthai == TrangThaiLuong.dachot ? "Đã chốt lương" : "Chưa chốt lương",
//               style: TextStyle(
//                 color: trangthai == TrangThaiLuong.dachot
//                     ? Colors.green
//                     : Colors.red,
//               ),
//             ),
//           ),
//           DataCell(!daKhoaCC ? (
//                 nv.tongDaChi > 0 ?
//                 Column(children: [
//                   Text('Chưa khóa CC'),
//                   Text(nv.tongDaChi > 0 ? 'Đã chi lương' : '')
//                 ],) : Text('Chưa khóa CC')
//               ):
//             BangLuongActionCell(
//               nv: nv,
//               thang: _selectedMonth,
//               nam: _selectedYear,
//               service: _chotService,
//               daKhoaCC: daKhoaCC,
//               onReload: () async => await _load(),
//             ),
//           ),
//           // DataCell(
//           //   trangthai == TrangThaiLuong.dachot
//           //       ? (nv.tongDaChi == 0
//           //           ? Row(
//           //               children: [HuyChotLuongButton(
//           //                 nv: nv,
//           //                 service: _chotService,
//           //                 onReload: _load,
//           //               ), ChiLuongButton(
//           //                 nv: nv,
//           //                 onReload: _load,
//           //               ),],
//           //             )
//           //           : ChiLuongButton(
//           //               nv: nv,
//           //               onReload: _load,
//           //             )
//           //           )
//           //       : ElevatedButton(
//           //           onPressed: () async {
//           //              await ChotLuongHelper.showConfirmChot(
//           //               context: context,
//           //               nv: nv,
//           //               thang: _selectedMonth,
//           //               nam: _selectedYear,
//           //               service: _chotService,
//           //               onSuccess: () {
//           //                 _load();
//           //               },
//           //             );;
//           //           },
//           //           style: ElevatedButton.styleFrom(
//           //             backgroundColor: Colors.green,
//           //             padding: const EdgeInsets.symmetric(
//           //                 horizontal: 8, vertical: 4), // 👈 nhỏ lại
//           //             minimumSize: const Size(0, 30), // 👈 chiều cao
//           //             tapTargetSize: MaterialTapTargetSize
//           //                 .shrinkWrap, // 👈 giảm vùng click
//           //           ),
//           //           child: const Text(
//           //             "Chốt",
//           //             style: TextStyle(color: Colors.white),
//           //           ),
//           //         ),
//           // ),
//         ],
//       );
//     }).toList();
//   }
// }
