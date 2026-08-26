import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/buildTrangThai.dart' hide TrangThaiChiLuong;
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/cham_cong_ngay_desktop.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/data/respositories/nhan_vien_cong_trinh_repo.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_luong.dart';
import '../../../luong/presentation/ung_luong/screens/UngLuongScreen.dart';
import '../../data/models/bang_cham_cong.dart';
import '../../data/repositories/ChotChiLuongRepository.dart';
import '../../data/services/ChotChiLuongService.dart';
import '../../data/services/cham_cong_service.dart';
import '../../data/models/ChamCongModel.dart';
import '../../widgets/BangLuongActionCell.dart';
import '../../widgets/ChamCongFilterState.dart';
import '../../widgets/setKhoaChamCong.dart';
import '../widgets/badgeCell.dart';
import '../widgets/textCell.dart';
import '_buildColumns.dart';
import 'buildDesktopHeader.dart';
import 'buildEmptyTable.dart';
import 'buildLegend.dart';
import 'buildSummary.dart';
import 'buildTrangThai.dart' hide TrangThaiChiLuong;
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
  bool _showChucVu = true;
  bool _show10Dau = true;
  bool _show10Giua = true;
  bool _show10Cuoi = true;
  List<ChamCongNhanVienModel> data = [];
  late final Chotchiluongservice _chotService;
  late final ChotChiLuongRepository _chotRepo;
  late final ChamCongService _chamCongService;
  late final BangChamCongRepository _bangChamCongRepository;
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
      ChotChiLuongRepository()
    );
    _bangChamCongRepository = BangChamCongRepository();
    _chotRepo = ChotChiLuongRepository();
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
      final isChotLuong = await _chotService.isTonTaiDaChotLuong( widget.bangChamCong?.id);
      if (!mounted) return;
      // 2. setState CHỈ GÁN DỮ LIỆU ĐỒNG BỘ (Không dùng async ở đây)
      setState(() {
        data = result ?? []; // Nên fallback về list rỗng nếu result null
        daKhoaCC = khoa;
        coChotLuong = isChotLuong;
        _isLoading = false;

      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể tải dữ liệu 123: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
            thang:'${widget.bangChamCong?.thang}/${widget.bangChamCong?.nam}',
            daKhoa: daKhoaCC,
            daChotLuong: coChotLuong,
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
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    setState(() {
      switch (value) {
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
                columns: buildColumns(soNgay, _showChucVu, _show10Dau, _show10Giua, _show10Cuoi),
                rows: data.asMap().entries.map((e) => _buildDataRow(e.value, e.key)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ChamCongNhanVienModel nv, int index) {
    return DataRow(
      color: MaterialStateProperty.all(index.isEven ? Colors.grey.shade50 : Colors.white),
      cells: [
        textCell(nv.ten ?? '', isBold: true),
        if (_showChucVu) textCell(nv.chucVu ?? ''),
        ..._buildNgayCells(nv),
        badgeCell(nv.tongSoCong.toString(), Colors.blue),
        textCell(formatCurrency(nv.tongLuongHienThi), isBold: true),
        _ungLuongCell(nv),
        textCell(formatCurrency(nv.truUng), isBold: true),
        textCell(formatCurrency(nv.thucNhanHienThi), color: Colors.green.shade700, isBold: true),
        _chotLuongCell(nv),
        _chiLuongCel(nv)
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
      return DataCell(
        InkWell(
          onTap: () => _navigateToDay(nv:nv, ngayKey:ngayKey, idChamCongNgay: idChamCongNgay),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: getChamCongColor(hienThi),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hienThi,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: getChamCongTextColor(hienThi),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  DataCell _ungLuongCell(ChamCongNhanVienModel nv) => DataCell(
    InkWell(
      onTap: () => _navigateToUngLuong(nv),
      child: Text(
        formatCurrency(nv.tongUngHienThi),
        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600),
      ),
    ),
  );
  DataCell _chotLuongCell(ChamCongNhanVienModel nv) {
    final isDaChot = nv.trangThaiChotLuong == TrangThaiLuong.dachot.value;
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Badge trạng thái
            buildTrangThai(TrangThaiLuong.fromValue(nv.trangThaiChotLuong)),
            const SizedBox(height: 4),
            // 2. Nút thao tác Chốt / Hủy chốt
            InkWell(
              onTap: () async {
                // Hộp thoại xác nhận thao tác
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(isDaChot ? 'Xác nhận hủy chốt' : 'Xác nhận chốt lương'),
                    content: Text(
                      isDaChot
                          ? 'Bạn có chắc chắn muốn HỦY CHỐT lương của ${nv.ten}?'
                          : 'Bạn có chắc chắn muốn CHỐT LƯƠNG cho ${nv.ten}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDaChot ? Colors.red : Colors.green,
                        ),
                        child: Text(
                          isDaChot ? 'Hủy chốt' : 'Chốt lương',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                try {
                  // Gọi hàm chốt / hủy chốt với await
                  await _chotRepo.chotOrHuyChotLuong(
                    idBangLuong: nv.idBangLuong,
                    idNhanVienCongTrinh: nv.idNhanVienCongTrinh!,
                    idBangChamCong: widget.bangChamCong!.id!,
                    tongCong: nv.tongSoCong ?? 0,
                    tongLuong: nv.tongTienCong ?? 0,
                    tongUng: nv.tongUng ?? 0,
                    thucNhan: nv.thucNhan ?? 0,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isDaChot ? 'Đã hủy chốt lương thành công!' : 'Đã chốt lương thành công!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      // Đẩy SnackBar lên góc trên màn hình
                      margin: EdgeInsets.only(
                        top: 20,
                        bottom: MediaQuery.of(context).size.height - 100,
                        left: (MediaQuery.of(context).size.width - 280) / 2, // Căn giữa chiều ngang (rộng 280)
                        right: (MediaQuery.of(context).size.width - 280) / 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Reload lại dữ liệu mới lên Data Table
                  _load();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDaChot ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDaChot ? Colors.red.shade300 : Colors.green.shade300,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDaChot ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                      size: 12,
                      color: isDaChot ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDaChot ? 'Hủy chốt' : 'Chốt lương',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDaChot ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  DataCell _chiLuongCel(ChamCongNhanVienModel nv){
    return DataCell(
      Column(
        children: [
          buildTrangThaiChiLuong(TrangThaiChiLuong.fromValue(nv.trangThaiChotLuong)),
          // ChiLuongButton(
          //   nv: nv,
          //   idBangChamCong: widget.bangChamCong!.id!,
          //   tenCongTrinh: widget.tenCongTrinh,
          //   onReload: _load,
          // )
        ],
      )

    );
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================

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
        builder: (_) => UngLuongScreen(
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
          hoTen: nv.ten,
          congTrinh: widget.tenCongTrinh,
          idBangChamCong: widget.bangChamCong?.id,
          thang: widget.bangChamCong?.thang,
          nam: widget.bangChamCong?.nam,
        ),
      ),
    );
    _load();
  }
}