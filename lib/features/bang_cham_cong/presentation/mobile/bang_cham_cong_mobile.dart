import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_luong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/buildTrangThai.dart' hide TrangThaiChiLuong;
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/cham_cong_ngay_desktop.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/mobile/buildMobileHeader.dart';
import 'package:nhat_ky_xay_dung/features/luong/presentation/ung_luong/desktop/ung_luong_nhan_vien_desktop.dart';
import '../../../../core/enum/feature_enum.dart';
import '../../../../core/services/PermissionManager.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../data/models/bang_cham_cong.dart';
import '../../data/models/phien_chot_cong.dart';
import '../../data/models/ChamCongModel.dart';
import '../../widgets/ChamCongFilterState.dart';
import '../../widgets/setKhoaChamCongTheoNhanVien.dart';
import '../desktop/_buildColumns.dart';
import '../desktop/buildDesktopHeader.dart';
import '../desktop/buildEmptyTable.dart';
import '../desktop/buildLegend.dart';
import '../desktop/buildSummary.dart';
import '../desktop/getChamCongColor.dart';
import '../desktop/isShowNgay.dart';
import '../widgets/textCell.dart';
import 'cham_cong_ngay_mobile.dart';

class BangChamCongMobile extends StatefulWidget {
  final BangChamCong? bangChamCong;
  final String? tenCongTrinh;
  const BangChamCongMobile({
    super.key,
    this.bangChamCong,
    this.tenCongTrinh,
  });
  @override
  State<BangChamCongMobile> createState() => _BangChamCongMobileState();
}

class _BangChamCongMobileState extends State<BangChamCongMobile> {
  int _fromDay = 1;
  late int _toDay;
  Set<int> selectedNhanVienIds = {};
  bool _showChucVu = true;
  List<ChamCongLuongNhanVien> data = [];
  List<PhienChotCong> dsDotChot = [];
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
    _fromDay = 1;
    _toDay = soNgay;
    _bangChamCongRepository = BangChamCongRepository();
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
      final result = await _chamCongLuongRepo.chamCongNhanViens(idCongTrinh: widget.bangChamCong?.idCongTrinh, idBangChamCong:  widget.bangChamCong!.id!);
      final khoa = await _bangChamCongRepository.checkKhoaChamCong(idBangChamCong: widget.bangChamCong?.id);
      final phienChots = await _chamCongLuongRepo.phienChotCongs(widget.bangChamCong?.id);
      if (!mounted) return;
      // 2. setState CHỈ GÁN DỮ LIỆU ĐỒNG BỘ (Không dùng async ở đây)
      setState(() {
        data = result ?? []; // Nên fallback về list rỗng nếu result null
        daKhoaCC = khoa;
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sổ chấm công tháng ${widget.bangChamCong?.thang}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.tenCongTrinh?.trim().isNotEmpty == true
                  ? widget.tenCongTrinh!
                  : 'Quản lý chấm công và bảng lương',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          buildMobileHeader(
            theme: theme,
            nam: widget.bangChamCong?.nam,
            thang: widget.bangChamCong?.thang,
            daKhoa: daKhoaCC,
            daChotLuong: coChotLuong,
            selectedNhanVienIds: selectedNhanVienIds,
            onChotCongTheoNhanVien: (DateTime dateSelected) async {
              await PermissionManager.instance.runWithPermission(
                context,
                feature: FeatureEnum.chotCong,
                action: () async {
                  await setKhoaChamCongTheoNhanVien(
                    context: context,
                    idBangChamCong: widget.bangChamCong?.id,
                    dateSelected: dateSelected,
                    selectedNhanVienIds: selectedNhanVienIds,
                  );

                  await _load();
                },
              );
            },
            dsDotChot: dsDotChot,
            onLoad: _load,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // TABLE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : data.isEmpty
                ? buildEmptyTable(
              "${widget.bangChamCong?.thangValue}",
            )
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
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: "Tùy chọn hiển thị",
            icon: const Icon(Icons.settings_outlined),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            itemBuilder: (context) => [
              CheckedPopupMenuItem<String>(
                value: "chucvu",
                checked: _showChucVu,
                onTap: () {
                  setState(() {
                    _showChucVu = !_showChucVu;
                    ChamCongFilterState.showChucVu = _showChucVu;
                  });
                },
                child: const Text("Hiển thị chức vụ"),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: "custom_range",
                onTap: () {
                  // Mở dialog chọn khoảng ngày sau khi đóng popup menu
                  Future.delayed(
                    Duration.zero,
                        () => _showCustomDateRangeDialog(context),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text("Khoảng ngày: $_fromDay - $_toDay"),
                  ],
                ),
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
                      selectedNhanVienIds = data.map((e) => e.idNhanVienCongTrinh!).toSet();
                    } else {
                      selectedNhanVienIds.clear();
                    }
                  });
                },
                columns: buildColumns(soNgay, _showChucVu, _fromDay, _toDay),
                rows: (data ?? []).asMap().entries.map((e) => _buildDataRow(e.value, e.key)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ChamCongLuongNhanVien nv, int index) {
    final isSelected = selectedNhanVienIds.contains(nv.idNhanVienCongTrinh);
    final bool isEvenRow = (index ?? 0) % 2 == 0;
    return DataRow(
      selected: isSelected,
      onSelectChanged: (bool? selected) {
        setState(() {
          if (selected == true) {
            selectedNhanVienIds.add(nv.idNhanVienCongTrinh!);
          } else {
            selectedNhanVienIds.remove(nv.idNhanVienCongTrinh);
          }
        });
      },
      color: MaterialStateProperty.all(
        isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1) // Đổi màu nền nhẹ khi chọn
            : (isEvenRow ? Colors.grey.shade50 : Colors.white),
      ),
      cells: [
        DataCell(
          InkWell(
            onTap: () => _navigateToChiTietNhanVien(nv),
            child: Text(
              nv.hoTen ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        // textCell(nv.chamCong.ten ?? '', isBold: true),
        if (_showChucVu) textCell(nv.chucVu ?? ''),
        ..._buildNgayCells(nv),
        // badgeCell(nv.chamCong.tongSoCong.toString(), Colors.blue),
        DataCell(
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Expanded(
                  child: Text("${nv.soCong}", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("${nv.tongSoCongChot ?? 0}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
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
                  child: Text("${currencyFormat.format(nv.tongLuongDuKien ?? 0)}", textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("${currencyFormat.format(nv.tongLuongChot ?? 0)}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
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
                  child: InkWell(
                    onTap: () => _navigateToUngLuong(nv),
                    child: Text(
                      "${currencyFormat.format(nv.tongUngDuKien ?? 0)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text("${currencyFormat.format(nv.tongUngDaTru ?? 0)}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
        textCell(formatCurrency(nv.thucNhanChot ?? 0), color: Colors.green.shade700, isBold: true),
        // _chotLuongCell(nv),
        _chiLuongCell(nv),
      ],
    );
  }

  List<DataCell> _buildNgayCells(ChamCongLuongNhanVien nv) {
    return List.generate(soNgay, (i) => i + 1)
        .where((day) => isShowNgayCustom(day, _fromDay, _toDay))
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

  DataCell _chiLuongCell(ChamCongLuongNhanVien nv) {
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(nv.tongDaChi ?? 0),
              style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w700,),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION HELPERS
  // ============================================================
  Future<void> _navigateToChiTietNhanVien(ChamCongLuongNhanVien nv)async{
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ChamCongChiTietNhanVienDesktop(
    //       model: nv,
    //       tenCongTrinh: widget.tenCongTrinh,
    //       thangKey: widget.bangChamCong!.thangValue,
    //       thang: widget.bangChamCong!.thang!,
    //       nam: widget.bangChamCong!.nam!,
    //     ),
    //   ),
    // );
    _load();
  }
  Future<void> _navigateToDay({required ChamCongLuongNhanVien nv, required String ngayKey, int? idChamCongNgay}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChamCongNgayMobile(
          id: idChamCongNgay,
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
          idCongTrinh: widget.bangChamCong!.idCongTrinh,
          idBangChamCong: widget.bangChamCong?.id,
          ngay: ngayKey,
          hoTen: nv.hoTen,
          tenCongTrinh: widget.tenCongTrinh,
          idPhienChot: nv.data[ngayKey]?.chamCong.idPhienChot,
          daKhoa: daKhoaCC,
        ),
      ),
    );
    _load();
  }

  Future<void> _navigateToUngLuong(ChamCongLuongNhanVien nv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongNhanVienDesktop(
          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
          hoTen: nv.hoTen,
          congTrinh: widget.tenCongTrinh,
          idBangChamCong: widget.bangChamCong?.id,
          // thang: widget.bangChamCong?.thang,
          // nam: widget.bangChamCong?.nam,
          // kyLuong: widget.bangChamCong?.thangValue,
        ),
      ),
    );
    _load();
  }
  void _showCustomDateRangeDialog(BuildContext context) {
    final TextEditingController fromController =
    TextEditingController(text: _fromDay.toString());
    final TextEditingController toController =
    TextEditingController(text: _toDay.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Tùy chọn khoảng ngày hiển thị", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tháng này có $soNgay ngày. Vui lòng nhập khoảng ngày muốn xem:",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fromController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Từ ngày",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        validator: (val) {
                          final d = int.tryParse(val ?? '');
                          if (d == null || d < 1 || d > soNgay) {
                            return "1 - $soNgay";
                          }
                          return null;
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("-"),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: toController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Đến ngày",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        validator: (val) {
                          final d = int.tryParse(val ?? '');
                          final from = int.tryParse(fromController.text) ?? 1;
                          if (d == null || d < from || d > soNgay) {
                            return "$from - $soNgay";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _fromDay = int.parse(fromController.text);
                    _toDay = int.parse(toController.text);
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Áp dụng"),
            ),
          ],
        );
      },
    );
  }
}