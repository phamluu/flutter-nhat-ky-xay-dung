import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/cham_cong_ngay_desktop.dart';
import 'package:nhat_ky_xay_dung/features/ung_luong/screens/UngLuongScreen.dart';

import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_luong.dart';
import '../../../../data/repositories/ChamCongRepository.dart';
import '../../../../data/repositories/ChotChiLuongRepository.dart';
import '../../../../services/BangLuongService.dart';
import '../../../../services/ChotChiLuongService.dart';
import '../../../../services/cham_cong_service.dart';
import '../../../../viewmodel/ChamCongModel.dart';
import '../../widgets/BangLuongActionCell.dart';
import '../../widgets/ChamCongFilterState.dart';
import '../../widgets/setKhoaChamCong.dart';
import 'filter_cham_cong_desktop.dart';

class BangChamCongDesktop extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const BangChamCongDesktop({
    super.key,
    this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<BangChamCongDesktop> createState() =>
      _BangChamCongDesktopState();
}

class _BangChamCongDesktopState
    extends State<BangChamCongDesktop> {
  // ============================================================
  // STATE
  // ============================================================

  /// Họ tên luôn hiển thị trên desktop.
  /// Không nên cho phép ẩn vì đây là cột định danh nhân viên.
  bool _showChucVu = true;

  bool _show10Dau = true;
  bool _show10Giua = true;
  bool _show10Cuoi = true;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<ChamCongModel> data = [];

  late final BangLuongService _service;
  late final Chotchiluongservice _chotService;
  late final ChamCongService _chamCongService;

  bool daKhoaCC = false;
  bool coChotLuong = false;

  bool _isLoading = false;

  // ============================================================
  // SCROLL
  // ============================================================

  final ScrollController _horizontalScrollController =
  ScrollController();

  final ScrollController _verticalScrollController =
  ScrollController();

  // ============================================================
  // GETTER
  // ============================================================

  int get soNgay => DateUtils.getDaysInMonth(
    _selectedYear,
    _selectedMonth,
  );

  String get thang =>
      "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}";

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _showChucVu =
        ChamCongFilterState.showChucVu;

    _show10Dau =
        ChamCongFilterState.show10Dau;

    _show10Giua =
        ChamCongFilterState.show10Giua;

    _show10Cuoi =
        ChamCongFilterState.show10Cuoi;

    _selectedMonth =
        ChamCongFilterState.selectedMonth;

    _selectedYear =
        ChamCongFilterState.selectedYear;

    _service = BangLuongService(
      chamCongService: ChamCongService(
        ChamCongRepository(),
      ),
      chotRepo: ChotChiLuongRepository(),
    );

    _chotService = Chotchiluongservice(
      ChotChiLuongRepository(),
    );

    _chamCongService = ChamCongService(
      ChamCongRepository(),
    );

    _load();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _load() async {
    if (widget.idCongTrinh == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _service.loadLuong(
        widget.idCongTrinh!,
        _selectedMonth,
        _selectedYear,
      );

      final khoa =
      await _chamCongService.checkKhoaChamCong(
        thang,
      );

      final isChotLuong =
      await _chotService.isTonTaiDaChotLuong(
        _selectedMonth,
        _selectedYear,
      );

      if (!mounted) return;

      setState(() {
        data = result;
        daKhoaCC = khoa;
        coChotLuong = isChotLuong;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Không thể tải dữ liệu: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: _buildDesktopHeader(theme),
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP HEADER
  // ============================================================

  Widget _buildDesktopHeader(
      ThemeData theme,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: Colors.green.shade700,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sổ chấm công",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tenCongTrinh
                      ?.trim()
                      .isNotEmpty ==
                      true
                      ? widget.tenCongTrinh!
                      : "Quản lý chấm công và bảng lương",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // MONTH
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 17,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Tháng $_selectedMonth/$_selectedYear",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // REFRESH
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _load,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const Text("Làm mới"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    return Column(
      children: [
        // FILTER
        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            0,
          ),
          child: _buildFilterCard(),
        ),

        const SizedBox(height: 14),

        // SUMMARY
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: _buildSummary(),
        ),

        const SizedBox(height: 14),

        // TABLE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24,
            ),
            child: _buildTableCard(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER CARD
  // ============================================================

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.filter_alt_outlined,
              color: Colors.blue.shade700,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "Bộ lọc",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          const SizedBox(width: 22),

          // FILTER
          Expanded(
            child: FilterChamCongDesktop(
              selectedMonth: _selectedMonth,
              selectedYear: _selectedYear,
              daKhoa: daKhoaCC,
              daChotLuong: coChotLuong,

              onMonthChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                  ChamCongFilterState.selectedMonth =
                      value;
                });

                _load();
              },

              onYearChanged: (value) {
                setState(() {
                  _selectedYear = value;
                  ChamCongFilterState.selectedYear =
                      value;
                });

                _load();
              },

              onChotCong: () async {
                await setkhoaChamCong(
                  context: context,
                  selectedMonth: _selectedMonth,
                  selectedYear: _selectedYear,
                  isKhoa: !daKhoaCC,
                  daChotLuong: coChotLuong,
                );

                await _load();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.people_alt_outlined,
            title: "Nhân viên",
            value: "${data.length}",
            subtitle: "Nhân viên trong công trình",
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.calendar_month_outlined,
            title: "Số ngày",
            value: "$soNgay",
            subtitle: "Ngày trong tháng",
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.lock_outline,
            title: "Chấm công",
            value: daKhoaCC
                ? "Đã khóa"
                : "Chưa khóa",
            subtitle: "Trạng thái chấm công",
            valueColor: daKhoaCC
                ? Colors.green
                : Colors.orange,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.payments_outlined,
            title: "Chốt lương",
            value: coChotLuong
                ? "Đã chốt"
                : "Chưa chốt",
            subtitle: "Trạng thái bảng lương",
            valueColor: coChotLuong
                ? Colors.green
                : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE CARD
  // ============================================================

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

          const Divider(
            height: 1,
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : data.isEmpty
                ? _buildEmptyTable()
                : _buildAttendanceTable(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Bảng chấm công",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Theo dõi ngày công và bảng lương của nhân viên",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _buildLegend(
            "Chưa khóa",
            Colors.orange,
          ),

          const SizedBox(width: 8),

          _buildLegend(
            "Đã khóa",
            Colors.green,
          ),

          const SizedBox(width: 12),

          // SETTINGS
          PopupMenuButton<String>(
            tooltip: "Tùy chọn hiển thị",
            icon: const Icon(
              Icons.settings_outlined,
            ),
            onSelected: _handleMenuSelection,
            itemBuilder: (_) => [
              CheckedPopupMenuItem<String>(
                value: "chucvu",
                checked: _showChucVu,
                child: const Text(
                  "Hiển thị chức vụ",
                ),
              ),

              const PopupMenuDivider(),

              CheckedPopupMenuItem<String>(
                value: "dau",
                checked: _show10Dau,
                child: const Text(
                  "Ngày 01 - 10",
                ),
              ),

              CheckedPopupMenuItem<String>(
                value: "giua",
                checked: _show10Giua,
                child: const Text(
                  "Ngày 11 - 20",
                ),
              ),

              CheckedPopupMenuItem<String>(
                value: "cuoi",
                checked: _show10Cuoi,
                child: const Text(
                  "Ngày 21 - cuối tháng",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _buildLegend(
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  void _handleMenuSelection(
      String value,
      ) {
    setState(() {
      switch (value) {
        case "chucvu":
          _showChucVu = !_showChucVu;

          ChamCongFilterState.showChucVu =
              _showChucVu;
          break;

        case "dau":
          _show10Dau = !_show10Dau;

          ChamCongFilterState.show10Dau =
              _show10Dau;
          break;

        case "giua":
          _show10Giua = !_show10Giua;

          ChamCongFilterState.show10Giua =
              _show10Giua;
          break;

        case "cuoi":
          _show10Cuoi = !_show10Cuoi;

          ChamCongFilterState.show10Cuoi =
              _show10Cuoi;
          break;
      }
    });
  }

  // ============================================================
  // ATTENDANCE TABLE
  // ============================================================

  Widget _buildAttendanceTable() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(14),
      ),
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        notificationPredicate: (notification) {
          return notification.metrics.axis ==
              Axis.horizontal;
        },
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notification) {
              return notification.metrics.axis ==
                  Axis.vertical;
            },
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 14,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 60,

                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),

                headingRowColor:
                MaterialStateProperty.resolveWith(
                      (_) => const Color(0xFFE8F5E9),
                ),

                columns: _buildColumns(),
                rows: _buildRows(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IS SHOW DAY
  // ============================================================

  bool _isShowNgay(int day) {
    if (day <= 10 && !_show10Dau) {
      return false;
    }

    if (day >= 11 &&
        day <= 20 &&
        !_show10Giua) {
      return false;
    }

    if (day >= 21 && !_show10Cuoi) {
      return false;
    }

    return true;
  }

  // ============================================================
  // COLUMNS
  // ============================================================

  List<DataColumn> _buildColumns() {
    final columns = <DataColumn>[];

    // ============================================================
    // HỌ TÊN
    // ============================================================

    // Luôn hiển thị HỌ TÊN.
    // Không cho ẩn vì đây là cột định danh nhân viên.
    columns.add(
      const DataColumn(
        label: SizedBox(
          width: 170,
          child: Text(
            "HỌ TÊN",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );

    // ============================================================
    // CHỨC VỤ
    // ============================================================

    if (_showChucVu) {
      columns.add(
        const DataColumn(
          label: SizedBox(
            width: 110,
            child: Text(
              "CHỨC VỤ",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    // ============================================================
    // NGÀY
    // ============================================================

    for (int i = 1; i <= soNgay; i++) {
      if (_isShowNgay(i)) {
        columns.add(
          DataColumn(
            numeric: true,
            label: SizedBox(
              width: 35,
              child: Center(
                child: Text(
                  "$i",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // ============================================================
    // TỔNG CÔNG
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "TỔNG CÔNG",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    // ============================================================
    // TỔNG LƯƠNG
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "TỔNG LƯƠNG",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    // ============================================================
    // ĐÃ ỨNG
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "ĐÃ ỨNG",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    // ============================================================
    // THỰC NHẬN
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "THỰC NHẬN",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    // ============================================================
    // TRẠNG THÁI
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "TRẠNG THÁI",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    // ============================================================
    // ACTION
    // ============================================================

    columns.add(
      const DataColumn(
        label: Text(
          "HÀNH ĐỘNG",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    return columns;
  }

  // ============================================================
  // ROWS
  // ============================================================

  List<DataRow> _buildRows() {
    return List.generate(
      data.length,
          (index) {
        final nv = data[index];

        final trangthai =
        TrangThaiLuong.fromValue(
          nv.trangThai,
        );

        return DataRow(
          color:
          MaterialStateProperty.resolveWith(
                (_) {
              return index % 2 == 0
                  ? Colors.grey.shade50
                  : Colors.white;
            },
          ),
          cells: [
            // ==================================================
            // HỌ TÊN
            // ==================================================

            // QUAN TRỌNG:
            // Phải có DataCell này vì _buildColumns()
            // luôn có cột HỌ TÊN.
            DataCell(
              SizedBox(
                width: 170,
                child: Text(
                  nv.ten ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ==================================================
            // CHỨC VỤ
            // ==================================================

            if (_showChucVu)
              DataCell(
                SizedBox(
                  width: 110,
                  child: Text(
                    nv.chucVu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // ==================================================
            // NGÀY
            // ==================================================

            for (int i = 1; i <= soNgay; i++)
              if (_isShowNgay(i))
                _buildNgayCell(
                  nv,
                  i,
                ),

            // ==================================================
            // TỔNG CÔNG
            // ==================================================

            DataCell(
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.08),
                  borderRadius:
                  BorderRadius.circular(6),
                ),
                child: Text(
                  (nv.tongSoCong ?? 0).toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ==================================================
            // TỔNG LƯƠNG
            // ==================================================

            DataCell(
              Text(
                formatCurrency(
                  nv.tongTienCong,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ==================================================
            // ĐÃ ỨNG
            // ==================================================

            DataCell(
              InkWell(
                borderRadius:
                BorderRadius.circular(6),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UngLuongScreen(
                            idNhanVienCongTrinh:
                            nv.idNhanVienCongTrinh,
                            hoTen: nv.ten,
                            congTrinh:
                            widget.tenCongTrinh,
                            thang: _selectedMonth,
                            nam: _selectedYear,
                          ),
                    ),
                  );

                  await _load();
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Text(
                    formatCurrency(
                      nv.tongUngHienThi,
                    ),
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // THỰC NHẬN
            // ==================================================

            DataCell(
              Text(
                formatCurrency(
                  nv.thucNhan,
                ),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ==================================================
            // TRẠNG THÁI
            // ==================================================

            DataCell(
              _buildTrangThai(
                trangthai,
              ),
            ),

            // ==================================================
            // ACTION
            // ==================================================

            DataCell(
              !daKhoaCC
                  ? _buildChuaKhoaAction(nv)
                  : BangLuongActionCell(
                nv: nv,
                thang: _selectedMonth,
                nam: _selectedYear,
                tenCongTrinh: widget.tenCongTrinh,
                service: _chotService,
                daKhoaCC: daKhoaCC,
                onReload: () async {
                  await _load();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DAY CELL
  // ============================================================

  DataCell _buildNgayCell(
      ChamCongModel nv,
      int i,
      ) {
    final ngay =
        "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";

    final cc = nv.data[ngay];

    final hienThi =
        cc?.chamCong.hienThi ?? "";

    return DataCell(
      InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChamCongNgayDesktop(
                    idNhanVienCongTrinh:
                    nv.idNhanVienCongTrinh,
                    ngay: ngay,
                    hoTen: nv.ten,
                    tenCongTrinh:
                    widget.tenCongTrinh,
                    daKhoa: daKhoaCC,
                  ),
            ),
          );

          await _load();
        },
        child: Container(
          width: 35,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _getChamCongColor(
              hienThi,
            ),
            borderRadius:
            BorderRadius.circular(5),
          ),
          child: Text(
            hienThi,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getChamCongTextColor(
                hienThi,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHẤM CÔNG COLOR
  // ============================================================

  Color _getChamCongColor(
      String value,
      ) {
    if (value.isEmpty) {
      return Colors.transparent;
    }

    switch (value.toUpperCase()) {
      case "X":
        return Colors.green.withOpacity(.12);

      case "P":
        return Colors.orange.withOpacity(.14);

      case "CT":
        return Colors.blue.withOpacity(.12);

      case "L":
        return Colors.red.withOpacity(.10);

      case "O":
        return Colors.purple.withOpacity(.10);

      default:
        return Colors.grey.withOpacity(.10);
    }
  }

  Color _getChamCongTextColor(
      String value,
      ) {
    if (value.isEmpty) {
      return Colors.grey;
    }

    switch (value.toUpperCase()) {
      case "X":
        return Colors.green.shade700;

      case "P":
        return Colors.orange.shade800;

      case "CT":
        return Colors.blue.shade700;

      case "L":
        return Colors.red.shade700;

      case "O":
        return Colors.purple.shade700;

      default:
        return Colors.grey.shade700;
    }
  }

  // ============================================================
  // TRẠNG THÁI
  // ============================================================

  Widget _buildTrangThai(
      TrangThaiLuong trangthai,
      ) {
    final isDaChot =
        trangthai == TrangThaiLuong.dachot;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDaChot
            ? Colors.green.withOpacity(.09)
            : Colors.red.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDaChot
            ? "Đã chốt lương"
            : "Chưa chốt lương",
        style: TextStyle(
          color: isDaChot
              ? Colors.green.shade700
              : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // CHƯA KHÓA ACTION
  // ============================================================

  Widget _buildChuaKhoaAction(
      ChamCongModel nv,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Chưa khóa CC",
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (nv.tongDaChi > 0)
            const SizedBox(height: 2),

          if (nv.tongDaChi > 0)
            Text(
              "Đã chi lương",
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyTable() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 34,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Chưa có dữ liệu chấm công",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Không tìm thấy dữ liệu cho tháng "
                "$_selectedMonth/$_selectedYear.",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}