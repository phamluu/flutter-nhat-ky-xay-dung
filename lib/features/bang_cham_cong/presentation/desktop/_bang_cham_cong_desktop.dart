// import 'package:flutter/material.dart';
// import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
// import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/cham_cong_ngay_desktop.dart';
// import '../../../../core/utils/currencyFormat.dart';
// import '../../../../core/utils/trang_thai_luong.dart';
// import '../../../luong/presentation/ung_luong/screens/UngLuongScreen.dart';
// import '../../data/repositories/ChamCongRepository.dart';
// import '../../data/repositories/ChotChiLuongRepository.dart';
// import '../../data/services/BangLuongService.dart';
// import '../../data/services/ChotChiLuongService.dart';
// import '../../data/services/cham_cong_service.dart';
// import '../../data/models/ChamCongModel.dart';
// import '../../widgets/BangLuongActionCell.dart';
// import '../../widgets/ChamCongFilterState.dart';
// import '../../widgets/setKhoaChamCong.dart';
// import '_buildColumns.dart';
// import 'buildChuaKhoaAction.dart';
// import 'buildDesktopHeader.dart';
// import 'buildEmptyTable.dart';
// import 'buildSummary.dart';
// import 'buildTrangThai.dart';
// import 'filter_cham_cong_desktop.dart';
// import 'getChamCongColor.dart';
// import 'getChamCongTextColor.dart';
// import 'isShowNgay.dart';
//
// class BangChamCongDesktop extends StatefulWidget {
//   final int? idCongTrinh;
//   final String? tenCongTrinh;
//   const BangChamCongDesktop({
//     super.key,
//     this.idCongTrinh,
//     this.tenCongTrinh,
//   });
//   @override
//   State<BangChamCongDesktop> createState() =>
//       _BangChamCongDesktopState();
// }
//
// class _BangChamCongDesktopState extends State<BangChamCongDesktop> {
//   bool _showChucVu = true;
//   bool _show10Dau = true;
//   bool _show10Giua = true;
//   bool _show10Cuoi = true;
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//
//   List<ChamCongNhanVienModel> data = [];
//
//   late final BangLuongService _service;
//   late final Chotchiluongservice _chotService;
//   late final ChamCongService _chamCongService;
//
//   bool daKhoaCC = false;
//   bool coChotLuong = false;
//
//   bool _isLoading = false;
//   late final int? idBangChamCong;
//   final ScrollController _horizontalScrollController = ScrollController();
//   final ScrollController _verticalScrollController = ScrollController();
//   int get soNgay => DateUtils.getDaysInMonth(_selectedYear,_selectedMonth,);
//   String get thang => "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}";
//
//   @override
//   Future<void> initState() async {
//     super.initState();
//     idBangChamCong = await _chamCongService.getChamCongId(widget.idCongTrinh , _selectedMonth, _selectedYear) ;
//     _showChucVu = ChamCongFilterState.showChucVu;
//     _show10Dau = ChamCongFilterState.show10Dau;
//     _show10Giua = ChamCongFilterState.show10Giua;
//     _show10Cuoi = ChamCongFilterState.show10Cuoi;
//     _selectedMonth = ChamCongFilterState.selectedMonth;
//     _selectedYear = ChamCongFilterState.selectedYear;
//
//     _service = BangLuongService(
//       chamCongService: ChamCongService(
//         ChamCongRepository(), BangChamCongRepository()
//       ),
//       chotRepo: ChotChiLuongRepository(),
//     );
//     _chotService = Chotchiluongservice(
//       ChotChiLuongRepository(),
//     );
//     _chamCongService = ChamCongService(
//       ChamCongRepository(), BangChamCongRepository()
//     );
//
//     _load();
//   }
//
//   @override
//   void dispose() {
//     _horizontalScrollController.dispose();
//     _verticalScrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     if (widget.idCongTrinh == null) { return;}
//
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//       });
//     }
//     try {
//       final result = await _service.loadLuong( widget.idCongTrinh!, _selectedMonth, _selectedYear,);
//       final khoa = await _chamCongService.checkKhoaChamCong(idBangChamCong!);
//       final isChotLuong = await _chotService.isTonTaiDaChotLuong(_selectedMonth, _selectedYear);
//       if (!mounted) return;
//       setState(() {
//         data = result;
//         daKhoaCC = khoa;
//         coChotLuong = isChotLuong;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Không thể tải dữ liệu: $e",
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: buildDesktopHeader(theme, widget.tenCongTrinh, "$_selectedMonth/$_selectedYear"),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: _buildBody(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     return Column(
//       children: [
//         // FILTER
//         Padding(
//           padding: const EdgeInsets.fromLTRB(
//             24,
//             20,
//             24,
//             0,
//           ),
//           child: _buildFilterCard(),
//         ),
//
//         const SizedBox(height: 14),
//
//         // SUMMARY
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 24,
//           ),
//           child: buildSummary(data.length, soNgay, daKhoaCC, coChotLuong),
//         ),
//
//         const SizedBox(height: 14),
//
//         // TABLE
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(
//               24,
//               0,
//               24,
//               24,
//             ),
//             child: _buildTableCard(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // FILTER CARD
//   // ============================================================
//
//   Widget _buildFilterCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: Colors.grey.shade200,
//         ),
//       ),
//       child: Row(
//         children: [
//           // ICON
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(.08),
//               borderRadius: BorderRadius.circular(9),
//             ),
//             child: Icon(
//               Icons.filter_alt_outlined,
//               color: Colors.blue.shade700,
//             ),
//           ),
//
//           const SizedBox(width: 12),
//
//           const Text(
//             "Bộ lọc",
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 15,
//             ),
//           ),
//
//           const SizedBox(width: 22),
//
//           // FILTER
//           Expanded(
//             child: FilterChamCongDesktop(
//               selectedMonth: _selectedMonth,
//               selectedYear: _selectedYear,
//               daKhoa: daKhoaCC,
//               daChotLuong: coChotLuong,
//
//               onMonthChanged: (value) {
//                 setState(() {
//                   _selectedMonth = value;
//                   ChamCongFilterState.selectedMonth =
//                       value;
//                 });
//
//                 _load();
//               },
//
//               onYearChanged: (value) {
//                 setState(() {
//                   _selectedYear = value;
//                   ChamCongFilterState.selectedYear =
//                       value;
//                 });
//
//                 _load();
//               },
//               onChotCong: () async {
//                 await setkhoaChamCong(
//                   context: context,
//                   selectedMonth: _selectedMonth,
//                   selectedYear: _selectedYear,
//                   isKhoa: !daKhoaCC,
//                   daChotLuong: coChotLuong,
//                   idBangChamCong: idBangChamCong
//                 );
//
//                 await _load();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTableCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildTableHeader(),
//           const Divider(
//             height: 1,
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//               child: CircularProgressIndicator(),
//             )
//                 : data.isEmpty
//                 ? buildEmptyTable("$_selectedMonth/$_selectedYear.")
//                 : _buildAttendanceTable(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTableHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 18,
//         vertical: 14,
//       ),
//       child: Row(
//         children: [
//           const Expanded(
//             child: Column(
//               crossAxisAlignment:
//               CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Bảng chấm công",
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(height: 3),
//                 Text(
//                   "Theo dõi ngày công và bảng lương của nhân viên",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           _buildLegend(
//             "Chưa khóa",
//             Colors.orange,
//           ),
//
//           const SizedBox(width: 8),
//
//           _buildLegend(
//             "Đã khóa",
//             Colors.green,
//           ),
//
//           const SizedBox(width: 12),
//
//           // SETTINGS
//           PopupMenuButton<String>(
//             tooltip: "Tùy chọn hiển thị",
//             icon: const Icon(
//               Icons.settings_outlined,
//             ),
//             onSelected: _handleMenuSelection,
//             itemBuilder: (_) => [
//               CheckedPopupMenuItem<String>(
//                 value: "chucvu",
//                 checked: _showChucVu,
//                 child: const Text(
//                   "Hiển thị chức vụ",
//                 ),
//               ),
//
//               const PopupMenuDivider(),
//
//               CheckedPopupMenuItem<String>(
//                 value: "dau",
//                 checked: _show10Dau,
//                 child: const Text(
//                   "Ngày 01 - 10",
//                 ),
//               ),
//
//               CheckedPopupMenuItem<String>(
//                 value: "giua",
//                 checked: _show10Giua,
//                 child: const Text(
//                   "Ngày 11 - 20",
//                 ),
//               ),
//
//               CheckedPopupMenuItem<String>(
//                 value: "cuoi",
//                 checked: _show10Cuoi,
//                 child: const Text(
//                   "Ngày 21 - cuối tháng",
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegend(
//       String text,
//       Color color,
//       ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.08),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 7,
//             height: 7,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//
//           const SizedBox(width: 6),
//
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _handleMenuSelection( String value, )
//   {
//     setState(() {
//       switch (value) {
//         case "chucvu":
//           _showChucVu = !_showChucVu;
//           ChamCongFilterState.showChucVu = _showChucVu;
//           break;
//         case "dau":
//           _show10Dau = !_show10Dau;
//           ChamCongFilterState.show10Dau =_show10Dau;
//           break;
//         case "giua":
//           _show10Giua = !_show10Giua;
//           ChamCongFilterState.show10Giua =_show10Giua;
//           break;
//         case "cuoi":
//           _show10Cuoi = !_show10Cuoi;
//           ChamCongFilterState.show10Cuoi =_show10Cuoi;
//           break;
//       }
//     });
//   }
//
//   Widget _buildAttendanceTable() {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(
//         bottom: Radius.circular(14),
//       ),
//       child: Scrollbar(
//         controller: _horizontalScrollController,
//         thumbVisibility: true,
//         trackVisibility: true,
//         notificationPredicate: (notification) {
//           return notification.metrics.axis == Axis.horizontal;
//         },
//         child: SingleChildScrollView(
//           controller: _horizontalScrollController,
//           scrollDirection: Axis.horizontal,
//           child: Scrollbar(
//             controller: _verticalScrollController,
//             thumbVisibility: true,
//             trackVisibility: true,
//             notificationPredicate: (notification) {
//               return notification.metrics.axis == Axis.vertical;
//             },
//             child: SingleChildScrollView(
//               controller: _verticalScrollController,
//               scrollDirection: Axis.vertical,
//               child: DataTable(
//                 columnSpacing: 14,
//                 horizontalMargin: 16,
//                 headingRowHeight: 48,
//                 dataRowMinHeight: 52,
//                 dataRowMaxHeight: 60,
//
//                 border: TableBorder(
//                   horizontalInside: BorderSide(
//                     color: Colors.grey.shade200,
//                   ),
//                 ),
//
//                 headingRowColor:
//                 MaterialStateProperty.resolveWith(
//                       (_) => const Color(0xFFE8F5E9),
//                 ),
//                 columns: buildColumns(soNgay, _showChucVu, _show10Dau, _show10Giua, _show10Cuoi),
//                 rows: _buildRows(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DataRow> _buildRows() {
//     return List.generate(
//       data.length,
//           (index) {
//         final nv = data[index];
//
//         final trangthai =
//         TrangThaiLuong.fromValue(
//           nv.trangThai,
//         );
//
//         return DataRow(
//           color:
//           MaterialStateProperty.resolveWith(
//                 (_) {
//               return index % 2 == 0
//                   ? Colors.grey.shade50
//                   : Colors.white;
//             },
//           ),
//           cells: [
//             // ==================================================
//             // HỌ TÊN
//             // ==================================================
//
//             // QUAN TRỌNG:
//             // Phải có DataCell này vì _buildColumns()
//             // luôn có cột HỌ TÊN.
//             DataCell(
//               SizedBox(
//                 width: 170,
//                 child: Text(
//                   nv.ten ?? "",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // CHỨC VỤ
//             // ==================================================
//
//             if (_showChucVu)
//               DataCell(
//                 SizedBox(
//                   width: 110,
//                   child: Text(
//                     nv.chucVu,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ),
//
//             // ==================================================
//             // NGÀY
//             // ==================================================
//
//             for (int i = 1; i <= soNgay; i++)
//               if (isShowNgay(i,  _show10Dau,  _show10Giua,  _show10Cuoi))
//                 _buildNgayCell(
//                   nv,
//                   i,
//                 ),
//
//             // ==================================================
//             // TỔNG CÔNG
//             // ==================================================
//
//             DataCell(
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(
//                   horizontal: 9,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(.08),
//                   borderRadius:
//                   BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   (nv.tongSoCong ?? 0).toString(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // TỔNG LƯƠNG
//             // ==================================================
//
//             DataCell(
//               Text(
//                 formatCurrency(
//                   nv.tongTienCong,
//                 ),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // ĐÃ ỨNG
//             // ==================================================
//
//             DataCell(
//               InkWell(
//                 borderRadius:
//                 BorderRadius.circular(6),
//                 onTap: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           UngLuongScreen(
//                             idNhanVienCongTrinh:
//                             nv.idNhanVienCongTrinh,
//                             hoTen: nv.ten,
//                             congTrinh:
//                             widget.tenCongTrinh,
//                             thang: _selectedMonth,
//                             nam: _selectedYear,
//                           ),
//                     ),
//                   );
//
//                   await _load();
//                 },
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 5,
//                   ),
//                   child: Text(
//                     formatCurrency(
//                       nv.tongUngHienThi,
//                     ),
//                     style: TextStyle(
//                       color: Colors.orange.shade800,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // THỰC NHẬN
//             // ==================================================
//
//             DataCell(
//               Text(
//                 formatCurrency(
//                   nv.thucNhan,
//                 ),
//                 style: TextStyle(
//                   color: Colors.green.shade700,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//
//             // ==================================================
//             // TRẠNG THÁI
//             // ==================================================
//
//             DataCell(
//               buildTrangThai(
//                 trangthai,
//               ),
//             ),
//
//             // ==================================================
//             // ACTION
//             // ==================================================
//
//             DataCell(
//               !daKhoaCC
//                   ? buildChuaKhoaAction(nv)
//                   : BangLuongActionCell(
//                 nv: nv,
//                 thang: _selectedMonth,
//                 nam: _selectedYear,
//                 tenCongTrinh: widget.tenCongTrinh,
//                 service: _chotService,
//                 daKhoaCC: daKhoaCC,
//                 onReload: () async {
//                   await _load();
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   DataCell _buildNgayCell(
//       ChamCongNhanVienModel nv,
//       int i,
//       )
//   {
//     final ngay =
//         "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
//
//     final cc = nv.data[ngay];
//
//     final hienThi =
//         cc?.chamCong.hienThi ?? "";
//
//     return DataCell(
//       InkWell(
//         onTap: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   ChamCongNgayDesktop(
//                     idNhanVienCongTrinh:
//                     nv.idNhanVienCongTrinh,
//                     ngay: ngay,
//                     hoTen: nv.ten,
//                     tenCongTrinh:
//                     widget.tenCongTrinh,
//                     daKhoa: daKhoaCC,
//                   ),
//             ),
//           );
//
//           await _load();
//         },
//         child: Container(
//           width: 35,
//           height: 34,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: getChamCongColor(
//               hienThi,
//             ),
//             borderRadius:
//             BorderRadius.circular(5),
//           ),
//           child: Text(
//             hienThi,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: getChamCongTextColor(
//                 hienThi,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// }