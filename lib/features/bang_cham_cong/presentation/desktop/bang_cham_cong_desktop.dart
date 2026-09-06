import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_luong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/buildTrangThai.dart' hide TrangThaiChiLuong;
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/cham_cong_ngay_desktop.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/respositories/nhan_vien_cong_trinh_repo.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';
import 'package:nhat_ky_xay_dung/features/luong/presentation/ung_luong/desktop/ung_luong_nhan_vien_desktop.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_luong.dart';
import '../../../luong/presentation/chi_luong/desktop/chi_luong_desktop.dart';
import '../../data/models/bang_cham_cong.dart';
import '../../data/models/phien_chot_cong.dart';
import '../../data/repositories/ChotChiLuongRepository.dart';
import '../../data/services/ChotChiLuongService.dart';
import '../../data/services/cham_cong_service.dart';
import '../../data/models/ChamCongModel.dart';
import '../../widgets/ChamCongFilterState.dart';
import '../../widgets/setKhoaChamCong.dart';
import '../../widgets/setKhoaChamCongTheoNhanVien.dart';
import '../widgets/badgeCell.dart';
import '../widgets/textCell.dart';
import '_buildColumns.dart';
import 'bang_cham_cong_nhan_vien_desktop.dart';
import 'buildDesktopHeader.dart';
import 'buildEmptyTable.dart';
import 'buildLegend.dart';
import 'buildSummary.dart';
import 'getChamCongColor.dart';
import 'getChamCongTextColor.dart';
import 'isShowNgay.dart';

class BangChamCongDesktop extends StatefulWidget {
  final BangChamCong? bangChamCong;
  final String? tenCongTrinh;
  const BangChamCongDesktop({
    super.key,
    this.bangChamCong,
    this.tenCongTrinh,
  });
  @override
  State<BangChamCongDesktop> createState() => _BangChamCongDesktopState();
}

class _BangChamCongDesktopState extends State<BangChamCongDesktop> {
  Set<int> selectedNhanVienIds = {};
  bool _showChucVu = true;
  bool _show10Dau = true;
  bool _show10Giua = true;
  bool _show10Cuoi = true;
  List<ChamCongLuongNhanVienModel> data = [];
  List<PhienChotCong> dsDotChot = [];
  late final Chotchiluongservice _chotService;
  late final ChotChiLuongRepository _chotRepo;
  late final ChamCongService _chamCongService;
  late final BangChamCongRepository _bangChamCongRepository;
  late final ChamCongLuongRepo _chamCongLuongRepo;
  bool daKhoaCC = false;
  bool coChotLuong = false;
  bool _isLoading = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  int get soNgay => DateUtils.getDaysInMonth(widget.bangChamCong!.nam!, widget.bangChamCong!.thang!);
  @override
  void initState() {
    super.initState();
    _showChucVu = ChamCongFilterState.showChucVu;
    _show10Dau = ChamCongFilterState.show10Dau;
    _show10Giua = ChamCongFilterState.show10Giua;
    _show10Cuoi = ChamCongFilterState.show10Cuoi;
    _chotService = Chotchiluongservice(ChotChiLuongRepository());
    _chamCongService = ChamCongService(
      ChamCongChiTietRepo(),
      BangChamCongRepository(),
      NhanVienCongTrinhRepo(),
      UngLuongRepository(),
      ChotChiLuongRepository(),
      ChamCongLuongRepo()
    );
    _bangChamCongRepository = BangChamCongRepository();
    _chotRepo = ChotChiLuongRepository();
    _chamCongLuongRepo = ChamCongLuongRepo();
    _initAndLoad();
  }
  Future<void> _initAndLoad() async {
    _load();
  }
  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }
  Future<void> _load() async {
    if (widget.bangChamCong == null) return;
    if(widget.bangChamCong?.idCongTrinh == null) return;
    if (mounted) setState(() => _isLoading = true);
    try {
      final result = await _chamCongService.chamCongNhanViens(idCongTrinh: widget.bangChamCong!.idCongTrinh!, idBangChamCong: widget.bangChamCong!.id!);
      final khoa = await _bangChamCongRepository.checkKhoaChamCong(idBangChamCong: widget.bangChamCong?.id);
      // final isChotLuong = await _chotService.isTonTaiDaChotLuong( widget.bangChamCong?.id);
      final phienChots = await _chamCongLuongRepo.phienChotCongs(widget.bangChamCong?.id);
      if (!mounted) return;
      // 2. setState CHỈ GÁN DỮ LIỆU ĐỒNG BỘ (Không dùng async ở đây)
      setState(() {
        data = result ?? []; // Nên fallback về list rỗng nếu result null
        daKhoaCC = khoa;
        // coChotLuong = isChotLuong;
        dsDotChot = phienChots;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showErrorToast(context, e, "Không thể tải dữ liệu");
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: buildDesktopHeader(
            theme:  theme,
            tenCongTrinh: widget.tenCongTrinh,
            thangKey:'${widget.bangChamCong?.thang}/${widget.bangChamCong?.nam}',
            nam: widget.bangChamCong?.nam ,
            thang: widget.bangChamCong?.thang,
            daKhoa: daKhoaCC,
            daChotLuong: coChotLuong,
            selectedNhanVienIds: selectedNhanVienIds,
            onChotCongTheoNhanVien: (DateTime dateSelected) async {
              await setKhoaChamCongTheoNhanVien(
                  context: context,
                  idBangChamCong: widget.bangChamCong?.id,
                  dateSelected: dateSelected,
                  selectedNhanVienIds: selectedNhanVienIds);
              await _load();
            },
            dsDotChot: dsDotChot,
            onChotCong: () async {
                            await setkhoaChamCong(
                              context: context,
                              selectedMonth: widget.bangChamCong?.thang,
                              selectedYear: widget.bangChamCong?.nam,
                              isKhoa: !daKhoaCC,
                              daChotLuong: coChotLuong,
                              idBangChamCong: widget.bangChamCong?.id,
                            );
                            await _load();
                          },
            onLoad: _load,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: buildSummary(data.length, soNgay, daKhoaCC, coChotLuong),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: _buildTableCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                ? buildEmptyTable("${widget.bangChamCong?.thangValue}")
                : _buildAttendanceTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bảng chấm công tháng ", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text("Theo dõi ngày công và bảng lương của nhân viên", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          buildLegend("Chưa khóa", Colors.orange),
          const SizedBox(width: 8),
          buildLegend("Đã khóa", Colors.green),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: "Tùy chọn hiển thị",
            icon: const Icon(Icons.settings_outlined),
            onSelected: _handleMenuSelection,
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            itemBuilder: (_) => [
              CheckedPopupMenuItem<String>(
                value: "chucvu",
                checked: _showChucVu,
                child: const Text("Hiển thị chức vụ"),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem<String>(
                value: "dau",
                checked: _show10Dau,
                child: const Text("Ngày 01 - 10"),
              ),
              CheckedPopupMenuItem<String>(
                value: "giua",
                checked: _show10Giua,
                child: const Text("Ngày 11 - 20"),
              ),
              CheckedPopupMenuItem<String>(
                value: "cuoi",
                checked: _show10Cuoi,
                child: const Text("Ngày 21 - cuối tháng"),
              ),
            ],
          ),
          const SizedBox(width: 12),
          PopupMenuButton<void>(
            tooltip: "Tùy chọn thêm",
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<void>(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Xác nhận xóa toàn bộ dữ liệu chấm công + lương'),
                      content: Text(
                          'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu chấm công + lương của '
                              'tháng ${widget.bangChamCong?.thang}/${widget.bangChamCong?.nam}?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Xóa',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  try {
                    await _chamCongLuongRepo.DeleteData(widget.bangChamCong?.id);
                    if (!mounted) return;
                    showSuccessToast(context, 'Đã xóa thành công!');
                    _load();
                  } catch (e) {
                    if (!mounted) return;
                    showErrorToast(context, e, "Không thể xóa dữ liệu");
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text("Xóa dữ liệu", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  void _handleMenuSelection(String value) {
    setState(() {
      switch (value) {
        case "deleteAll":

        case "chucvu":
          _showChucVu = !_showChucVu;
          ChamCongFilterState.showChucVu = _showChucVu;
          break;
        case "dau":
          _show10Dau = !_show10Dau;
          ChamCongFilterState.show10Dau = _show10Dau;
          break;
        case "giua":
          _show10Giua = !_show10Giua;
          ChamCongFilterState.show10Giua = _show10Giua;
          break;
        case "cuoi":
          _show10Cuoi = !_show10Cuoi;
          ChamCongFilterState.show10Cuoi = _show10Cuoi;
          break;
      }
    });
  }

  // ============================================================
  // TABLE DATA RENDER (Tối ưu hóa gọn gàng) -- CODE CHÍNH DỮ LIỆU TABLE
  // ============================================================

  Widget _buildAttendanceTable() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 48,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 70,
                headingRowColor: MaterialStateProperty.all(const Color(0xFFE8F5E9)),
                border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200)),
                onSelectAll: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      selectedNhanVienIds = data.map((e) => e.chamCong.idNhanVienCongTrinh!).toSet();
                    } else {
                      selectedNhanVienIds.clear();
                    }
                  });
                },
                columns: buildColumns(soNgay, _showChucVu, _show10Dau, _show10Giua, _show10Cuoi),
                rows: data.asMap().entries.map((e) => _buildDataRow(e.value, e.key)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ChamCongLuongNhanVienModel nv, int index) {
    final isSelected = selectedNhanVienIds.contains(nv.chamCong.idNhanVienCongTrinh);
    return DataRow(
      selected: isSelected,
      onSelectChanged: (bool? selected) {
        setState(() {
          if (selected == true) {
            selectedNhanVienIds.add(nv.chamCong.idNhanVienCongTrinh!);
          } else {
            selectedNhanVienIds.remove(nv.chamCong.idNhanVienCongTrinh);
          }
        });
      },
      color: MaterialStateProperty.all(
        isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1) // Đổi màu nền nhẹ khi chọn
            : (index.isEven ? Colors.grey.shade50 : Colors.white),
      ),
      cells: [
        DataCell(
          InkWell(
            onTap: () => _navigateToChiTietNhanVien(nv),
            child: Text(
              nv.chamCong.ten ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        // textCell(nv.chamCong.ten ?? '', isBold: true),
        if (_showChucVu) textCell(nv.chamCong.chucVu ?? ''),
        ..._buildNgayCells(nv.chamCong),
        // badgeCell(nv.chamCong.tongSoCong.toString(), Colors.blue),
        DataCell(
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Expanded(
                  child: Text("${nv.chamCong.tongSoCong}", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("${nv.chamCong.soCongDaChot}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Expanded(
                  child: Text("${currencyFormat.format(nv.tongTienCong)}", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("${currencyFormat.format(nv.luong.tongLuongChot)}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Expanded(
                  child: Text("${currencyFormat.format(nv.luong.tongUng ?? 0)}", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("${currencyFormat.format(nv.luong.truUng ?? 0)}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
        textCell(formatCurrency(nv.thucNhanHienThi), color: Colors.green.shade700, isBold: true),
        // _chotLuongCell(nv),
        _chiLuongCell(nv),
        textCell(formatCurrency(nv.luong.conPhaiTra), isBold: true),
      ],
    );
  }

  List<DataCell> _buildNgayCells(ChamCongNhanVienModel nv) {
    return List.generate(soNgay, (i) => i + 1)
        .where((day) => isShowNgay(day, _show10Dau, _show10Giua, _show10Cuoi))
        .map((day) {
      final ngayKey = "${widget.bangChamCong?.thangValue}-${day.toString().padLeft(2, '0')}";
      final chamCongNgayLuong = nv.data[ngayKey];
      final chamCong = chamCongNgayLuong?.chamCong;

      // 2. Lấy id chấm công ngày (nếu có) và chuỗi hiển thị
      final int? idChamCongNgay = chamCong?.id;
      final hienThi = nv.data[ngayKey]?.chamCong.hienThi ?? "...";
      final chotCong = nv.data[ngayKey]?.chamCong.idPhienChot != null ? true : false;
      return DataCell(
        InkWell(
          onTap: () => _navigateToDay(nv:nv, ngayKey:ngayKey, idChamCongNgay: idChamCongNgay),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getChamCongColor(hienThi, chotCong),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hienThi,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: getChamCongTextColor(hienThi, chotCong),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  DataCell _ungLuongCell(ChamCongLuongNhanVienModel nv) => DataCell(
    InkWell(
      onTap: () => _navigateToUngLuong(nv.chamCong),
      child: Text(
        formatCurrency(nv.luong.tongUng),
        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600),
      ),
    ),
  );
  // DataCell _chotLuongCell(ChamCongLuongNhanVienModel nv) {
  //   final isDaChot = nv.luong.trangThaiChotLuong == TrangThaiLuong.dachot.value;
  //   return DataCell(
  //     Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 4),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           // 1. Badge trạng thái
  //           buildTrangThai(TrangThaiLuong.fromValue(nv.luong.trangThaiChotLuong)),
  //           const SizedBox(height: 4),
  //           // 2. Nút thao tác Chốt / Hủy chốt
  //           InkWell(
  //             onTap: () async {
  //               // Hộp thoại xác nhận thao tác
  //               final confirm = await showDialog<bool>(
  //                 context: context,
  //                 builder: (ctx) => AlertDialog(
  //                   title: Text(isDaChot ? 'Xác nhận hủy chốt' : 'Xác nhận chốt lương'),
  //                   content: Text(
  //                     isDaChot
  //                         ? 'Bạn có chắc chắn muốn HỦY CHỐT lương của ${nv.chamCong.ten}?'
  //                         : 'Bạn có chắc chắn muốn CHỐT LƯƠNG cho ${nv.chamCong.ten}?',
  //                   ),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(ctx, false),
  //                       child: const Text('Hủy'),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () => Navigator.pop(ctx, true),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: isDaChot ? Colors.red : Colors.green,
  //                       ),
  //                       child: Text(
  //                         isDaChot ? 'Hủy chốt' : 'Chốt lương',
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //               if (confirm != true) return;
  //               try {
  //                 // Gọi hàm chốt / hủy chốt với await
  //                 await _chotRepo.chotOrHuyChotLuong(
  //                   idBangLuong: nv.luong.idBangLuong,
  //                   idNhanVienCongTrinh: nv.chamCong.idNhanVienCongTrinh!,
  //                   idBangChamCong: widget.bangChamCong!.id!,
  //                 );
  //
  //                 if (!mounted) return;
  //                   showSuccessToast(context, isDaChot ? 'Đã hủy chốt lương thành công!' : 'Đã chốt lương thành công!');
  //                 _load();
  //               } catch (e) {
  //                 if (!mounted) return;
  //                 showErrorToast(context, e, "Không thể chốt lương");
  //               }
  //             },
  //             borderRadius: BorderRadius.circular(6),
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  //               decoration: BoxDecoration(
  //                 color: isDaChot ? Colors.red.shade50 : Colors.green.shade50,
  //                 borderRadius: BorderRadius.circular(6),
  //                 border: Border.all(
  //                   color: isDaChot ? Colors.red.shade300 : Colors.green.shade300,
  //                   width: 0.8,
  //                 ),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     isDaChot ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
  //                     size: 12,
  //                     color: isDaChot ? Colors.red.shade700 : Colors.green.shade700,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     isDaChot ? 'Hủy chốt' : 'Chốt lương',
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       fontWeight: FontWeight.w600,
  //                       color: isDaChot ? Colors.red.shade700 : Colors.green.shade700,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  DataCell _chiLuongCell(ChamCongLuongNhanVienModel nv) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(nv.luong.tongDaChi),
              style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w700,),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: 'Xem danh sách các lần chi lương',
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChiLuongDesktop(
                        luong: nv.luong,
                        tenCongTrinh: widget.tenCongTrinh,
                        tenNhanVien: nv.chamCong.ten,
                        tongPhaiTra: nv.thucNhanHienThi,
                        thang: widget.bangChamCong?.thang,
                        nam: widget.bangChamCong?.nam
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Danh sách',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================
  Future<void> _navigateToChiTietNhanVien(ChamCongLuongNhanVienModel nv)async{
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChamCongChiTietNhanVienDesktop(
          model: nv,
          tenCongTrinh: widget.tenCongTrinh,
          thangKey: widget.bangChamCong!.thangValue,
          thang: widget.bangChamCong!.thang!,
          nam: widget.bangChamCong!.nam!,
        ),
      ),
    );
    _load();
  }
  Future<void> _navigateToDay({required ChamCongNhanVienModel nv, required String ngayKey, int? idChamCongNgay}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChamCongNgayDesktop(
          id: idChamCongNgay,
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
          idCongTrinh: widget.bangChamCong!.idCongTrinh,
          idBangChamCong: widget.bangChamCong?.id,
          ngay: ngayKey,
          hoTen: nv.ten,
          tenCongTrinh: widget.tenCongTrinh,
          idPhienChot: nv.data[ngayKey]?.chamCong.idPhienChot,
          daKhoa: daKhoaCC,
        ),
      ),
    );
    _load();
  }

  Future<void> _navigateToUngLuong(ChamCongNhanVienModel nv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongNhanVienDesktop(
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
          hoTen: nv.ten,
          congTrinh: widget.tenCongTrinh,
          idBangChamCong: widget.bangChamCong?.id,
          thang: widget.bangChamCong?.thang,
          nam: widget.bangChamCong?.nam,
          kyLuong: widget.bangChamCong?.thangValue,
        ),
      ),
    );
    _load();
  }
}