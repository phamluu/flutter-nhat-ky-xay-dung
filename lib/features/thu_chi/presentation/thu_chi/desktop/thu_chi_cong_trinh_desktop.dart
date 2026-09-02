import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../../../core/utils/date_input_formatter.dart';
import '../../../data/models/ThuChi.dart';
import '../../../data/services/thu_chi_service.dart';
import '../widgets/buildInfoRow.dart';
import '../widgets/buildLoading.dart';
import '../widgets/buildProgressRow.dart';
import '../widgets/exportExcel.dart';
import '../widgets/getYears.dart';
import 'buildChiLuong.dart';
import 'buildDropdown.dart';
import 'buildEmpty.dart';
import 'buildTopAction.dart';
import 'buildTransactionHeader.dart';
import 'summaryCard.dart';
import 'thu_chi_form_desktop.dart';
import 'thu_chi_item_desktop.dart';

class ThuChiCongTrinhDesktop extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const ThuChiCongTrinhDesktop({
    super.key,
    this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<ThuChiCongTrinhDesktop> createState() => _ThuChiCongTrinhDesktopState();
}

class _ThuChiCongTrinhDesktopState extends State<ThuChiCongTrinhDesktop> {
  final _thuChiService = ThuChiService();
  late Future<ThuChiCongTrinhViewModel> _futureThuChi;

  // FILTER
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime? _firstDate;
  DateTime? _lastDate;

  // Controllers cho ô nhập
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================
  void _load() {
    final range = _getFilterDateRange();
    _futureThuChi = _thuChiService.loadThuChiCongTrinh(
      widget.idCongTrinh,
      tuNgay: range?.$1,
      denNgay: range?.$2,
    );
    _loadDateRange();
  }

  Future<void> _loadDateRange() async {
    final (firstDate, lastDate) = await _thuChiService.getThuChiDateRange(widget.idCongTrinh);
    if (mounted) {
      setState(() {
        _firstDate = firstDate ?? DateTime.now();
        _lastDate = lastDate ?? DateTime.now();
        // CẬP NHẬT CẢ BIẾN STATE VÀ CONTROLLER
        if (_fromDate == null && _firstDate != null) {
          _fromDate = _firstDate; // Gán object DateTime
          _fromDateController.text = _dateFormat.format(_firstDate!);
        }
        if (_toDate == null && _lastDate != null) {
          _toDate = _lastDate; // Gán object DateTime
          _toDateController.text = _dateFormat.format(_lastDate!);
        }
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
    await _futureThuChi;
  }

  Future<void> _addThuChi() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThuChiFormDesktop(
          idCongTrinh: widget.idCongTrinh,
        ),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar( title: _buildTopBar(), ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<ThuChiCongTrinhViewModel>(
              future: _futureThuChi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoading();
                }
                if (snapshot.hasError) {
                  return _buildError(
                    snapshot.error.toString(),
                  );
                }
                if (!snapshot.hasData) {
                  return buildEmpty();
                }
                return _buildDesktopContent(
                  snapshot.data!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP CONTENT
  // ============================================================

  Widget _buildDesktopContent(ThuChiCongTrinhViewModel vm) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(),
              const SizedBox(height: 16),
              _buildFilterBar(),
              const SizedBox(height: 22),
              _buildSummary(vm),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTransactionArea(vm),
                  const SizedBox(height: 20),
                  _buildOverviewPanel(vm),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // FILTER DATE RANGE
  // ============================================================

  (DateTime, DateTime)? _getFilterDateRange() {
    // Nếu cả 2 đều trống -> Không lọc
    if (_fromDate == null && _toDate == null) {
      return null;
    }

    // Tự động bù ngày còn lại nếu 1 trong 2 ô bị null
    final start = _fromDate ?? _firstDate ?? DateTime(2000);
    final end = _toDate ?? _lastDate ?? DateTime.now();

    return (
    DateTime(start.year, start.month, start.day, 0, 0, 0),
    DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffeaf2ff),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xff2563eb),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý thu chi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172033),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.tenCongTrinh?.isNotEmpty == true
                    ? widget.tenCongTrinh!
                    : 'Theo dõi tài chính công trình',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  Widget _buildPageTitle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng quan thu chi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172033),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _getFilterDescription(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: ()
            {
              exportExcelThuChi(
                  context: context,
                  data: _futureThuChi,
                tenCongTrinh: widget.tenCongTrinh
              );
            },
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red,),
            label: const Text('Xuất pdf',  style: TextStyle(color: Colors.red,)),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: const Color(0xff475569),
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(onPressed: ()
            {
                  exportExcelThuChi(
                  context: context,
                  data: _futureThuChi,
                  tenCongTrinh: widget.tenCongTrinh,
                    tuNgay: _fromDate,
                    denNgay: _toDate
                  );
            },
            icon: const Icon(Icons.import_export, color: Colors.green,),
            label: const Text('Xuất excel', style: TextStyle(color: Colors.green,),),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: const Color(0xff475569),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _addThuChi,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm khoản thu chi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2563eb),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  String _getFilterDescription() {
    if (_fromDate != null && _toDate != null) {
      return 'Theo dõi thu chi từ '
          '${_dateFormat.format(_fromDate!)} đến '
          '${_dateFormat.format(_toDate!)}';
    }

    return 'Theo dõi các khoản thu, chi và số dư của công trình';
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final datePicker = _buildDateRangeSelector();

          if (constraints.maxWidth < 650) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterTitle(),
                const SizedBox(height: 12),
                datePicker,
              ],
            );
          }

          return Row(
            children: [
              _buildFilterTitle(),
              const SizedBox(width: 24),
              datePicker,
              const Spacer(),
              buildTopAction(
                icon: Icons.refresh,
                label: 'Làm mới',
                onPressed: _refresh,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTitle() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.filter_alt_outlined,
          size: 18,
          color: Color(0xff64748b),
        ),
        SizedBox(width: 7),
        Text(
          'Lọc thời gian',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff334155),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ô nhập Từ ngày
        _buildDateInputField(
          hintText: 'Từ ngày',
          controller: _fromDateController,
          onDateChanged: (date) {
            setState(() {
              _fromDate = date;
              if (date == null) _fromDate = null;
            });
            _load();
          },
          onCalendarPressed: _selectFromDate,
        ),

        const SizedBox(width: 10),
        const Icon(
          Icons.arrow_forward_rounded,
          size: 18,
          color: Color(0xff94a3b8),
        ),
        const SizedBox(width: 10),

        // Ô nhập Đến ngày
        _buildDateInputField(
          hintText: 'Đến ngày',
          controller: _toDateController,
          onDateChanged: (date) {
            setState(() {
              _toDate = date;
            });
            if (_fromDate != null && _toDate != null) _load();
          },
          onCalendarPressed: _selectToDate,
        ),

        // Nút Xóa bộ lọc (chỉ hiện khi đã chọn/nhập ngày)
        if (_fromDate != null || _toDate != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Xóa bộ lọc',
            onPressed: _clearDateFilter,
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Color(0xff64748b),
            ),
          ),
        ],
      ],
    );
  }

  // Component Ô nhập ngày nhảy tự động dấu /
  Widget _buildDateInputField({
    required String hintText,
    required TextEditingController controller,
    required Function(DateTime?) onDateChanged,
    required VoidCallback onCalendarPressed,
  }) {
    return SizedBox(
      width: 155,
      height: 38,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 10,
        inputFormatters: [
          DateInputFormatter(), // Tự gạch / khi gõ
        ],
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        onTap: () {
          if (controller.text.isNotEmpty) {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xff2563eb)),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xff2563eb)),
            onPressed: onCalendarPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        onChanged: (val) {
          if (val.length == 10) {
            try {
              // Tách chuỗi dd/MM/yyyy để ép kiểu DateTime chính xác tuyệt đối
              final parts = val.split('/');
              if (parts.length == 3) {
                final day = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final year = int.parse(parts[2]);

                final parsed = DateTime(year, month, day);

                // Kiểm tra giới hạn khoảng ngày (nếu có)
                if (_firstDate != null && _lastDate != null) {
                  final min = DateTime(_firstDate!.year, _firstDate!.month, _firstDate!.day);
                  final max = DateTime(_lastDate!.year, _lastDate!.month, _lastDate!.day, 23, 59, 59);

                  if (parsed.isBefore(min) || parsed.isAfter(max)) {
                    showErrorToast(context,"", 'Ngày nằm ngoài phạm vi (${_firstDate?.day}/${_firstDate?.month}/${_firstDate?.year} '
                        '- ${_lastDate?.day}/${_lastDate?.month}/${_lastDate?.year})');
                    return;
                  }
                }

                // Gán giá trị và gọi kích hoạt load lại danh sách ngay lập tức
                onDateChanged(parsed);
                _load();
              }
            } catch (e) {
              // Ngày nhập không đúng định dạng hợp lệ (vd: 31/02/2026)
            }
          } else if (val.isEmpty) {
            onDateChanged(null);
            _load();
          }
        },
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final now = DateTime.now();
    final minDate = _firstDate ?? DateTime(2000);
    final maxDate = _toDate ?? _lastDate ?? DateTime(2100);

    DateTime initial = _fromDate ?? now;
    if (initial.isBefore(minDate)) initial = minDate;
    if (initial.isAfter(maxDate)) initial = maxDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: maxDate,
      locale: const Locale('vi', 'VN'),
    );

    if (date == null || !mounted) return;

    setState(() {
      _fromDate = DateTime(date.year, date.month, date.day);
      _fromDateController.text = _dateFormat.format(_fromDate!);
    });

    _load();
  }

  Future<void> _selectToDate() async {
    final now = DateTime.now();
    final minDate = _fromDate ?? _firstDate ?? DateTime(2000);
    final maxDate = _lastDate ?? DateTime(2100);

    DateTime initial = _toDate ?? _fromDate ?? now;
    if (initial.isBefore(minDate)) initial = minDate;
    if (initial.isAfter(maxDate)) initial = maxDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: maxDate,
      locale: const Locale('vi', 'VN'),
    );

    if (date == null || !mounted) return;

    setState(() {
      _toDate = DateTime(date.year, date.month, date.day);
      _toDateController.text = _dateFormat.format(_toDate!);
    });

    _load();
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _fromDateController.clear();
      _toDateController.clear();

      if (_firstDate != null) {
        _fromDateController.text = _dateFormat.format(_firstDate!);
      }
      if (_lastDate != null) {
        _toDateController.text = _dateFormat.format(_lastDate!);
      }
    });

    _load();
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(ThuChiCongTrinhViewModel vm) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;

        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              summaryCard(
                title: 'Tổng thu',
                value: currencyFormat.format(vm.tongThu),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xff16a34a),
                background: const Color(0xffecfdf3),
              ),
              const SizedBox(height: 12),
              summaryCard(
                title: 'Tổng chi',
                value: currencyFormat.format(vm.tongChi),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),
              const SizedBox(height: 12),
              summaryCard(
                title: 'Còn lại',
                value: currencyFormat.format(vm.conLai),
                icon: Icons.account_balance_wallet_outlined,
                color: vm.conLai >= 0
                    ? const Color(0xff2563eb)
                    : const Color(0xffdc2626),
                background: vm.conLai >= 0
                    ? const Color(0xffeff6ff)
                    : const Color(0xfffef2f2),
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: cardWidth,
              child: summaryCard(
                title: 'Tổng thu',
                value: currencyFormat.format(vm.tongThu),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xff16a34a),
                background: const Color(0xffecfdf3),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              child: summaryCard(
                title: 'Tổng chi',
                value: currencyFormat.format(vm.tongChi),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: summaryCard(
                title: 'Còn lại',
                value: currencyFormat.format(vm.conLai),
                icon: Icons.account_balance_wallet_outlined,
                color: vm.conLai >= 0
                    ? const Color(0xff2563eb)
                    : const Color(0xffdc2626),
                background: vm.conLai >= 0
                    ? const Color(0xffeff6ff)
                    : const Color(0xfffef2f2),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // TRANSACTION AREA
  // ============================================================

  Widget _buildTransactionArea(ThuChiCongTrinhViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          buildTransactionHeader(vm.thuChiDanhMucs.length),
          const Divider(height: 1),
          buildTamUngChiLuong(vm),
          if (vm.thuChiDanhMucs.isEmpty &&
              (vm.thuChiKhacs.thuchis == null ||
                  vm.thuChiKhacs.thuchis!.isEmpty))
            _buildNoTransaction()
          else
            Column(
              children: [
                ...vm.thuChiDanhMucs.map(
                      (dmVM) => _buildDanhMucCard(dmVM),
                ),
                if (vm.thuChiKhacs.thuchis != null &&
                    vm.thuChiKhacs.thuchis!.isNotEmpty)
                  _buildKhacCard(vm),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildDanhMucCard(dynamic dmVM) {
    final items = dmVM.thuchis ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xfff8fafc),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xffeaf2ff),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: Color(0xff2563eb),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dmVM.danhMucThuChi?.ten ?? 'Chưa phân loại',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1e293b),
                    ),
                  ),
                ),
                const Text(
                  'Số dư',
                  style: TextStyle(fontSize: 11, color: Color(0xff94a3b8)),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(dmVM.conLai),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: dmVM.conLai >= 0
                        ? const Color(0xff2563eb)
                        : const Color(0xffdc2626),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Chưa có khoản thu chi',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            )
          else
            ThuChiTableDesktop(items: items, onRefresh: _load,)
        ],
      ),
    );
  }

  // ============================================================
  // OTHER
  // ============================================================

  Widget _buildKhacCard(ThuChiCongTrinhViewModel vm) {
    final items = vm.thuChiKhacs.thuchis ?? [];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xfff8fafc),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    size: 19,
                    color: Color(0xff64748b),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Khác',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1e293b),
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(vm.thuChiKhacs.conLai),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: vm.thuChiKhacs.conLai >= 0
                        ? const Color(0xff2563eb)
                        : const Color(0xffdc2626),
                  ),
                ),
              ],
            ),
          ),
          ThuChiTableDesktop(items: items, onRefresh: _load)
        ],
      ),
    );
  }

  // ============================================================
  // RIGHT OVERVIEW
  // ============================================================

  Widget _buildOverviewPanel(ThuChiCongTrinhViewModel vm) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildBalancePanel(vm),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuickInfo(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePanel(ThuChiCongTrinhViewModel vm) {
    final total = vm.tongThu.abs() + vm.tongChi.abs();
    final incomePercent = total == 0 ? 0.0 : vm.tongThu.abs() / total;
    final expensePercent = total == 0 ? 0.0 : vm.tongChi.abs() / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bổ tài chính',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _getFinancialDescription(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 22),
          buildProgressRow(
            title: 'Tổng thu',
            value: vm.tongThu,
            percent: incomePercent,
            color: const Color(0xff16a34a),
          ),
          const SizedBox(height: 18),
          buildProgressRow(
            title: 'Tổng chi',
            value: vm.tongChi,
            percent: expensePercent,
            color: const Color(0xffdc2626),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: vm.conLai >= 0
                  ? const Color(0xffeff6ff)
                  : const Color(0xfffef2f2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  vm.conLai >= 0
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 20,
                  color: vm.conLai >= 0
                      ? const Color(0xff2563eb)
                      : const Color(0xffdc2626),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.conLai >= 0 ? 'Số dư hiện tại' : 'Đang âm ngân sách',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        currencyFormat.format(vm.conLai),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: vm.conLai >= 0
                              ? const Color(0xff2563eb)
                              : const Color(0xffdc2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFinancialDescription() {
    if (_fromDate != null && _toDate != null) {
      return 'Tỷ lệ thu chi từ '
          '${_dateFormat.format(_fromDate!)} đến '
          '${_dateFormat.format(_toDate!)}';
    }

    return 'Tỷ lệ giữa tổng thu và tổng chi';
  }

  Widget _buildQuickInfo(ThuChiCongTrinhViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 19,
                color: Color(0xff64748b),
              ),
              SizedBox(width: 8),
              Text(
                'Thông tin',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildInfoRow('Phạm vi', _getFilterLabel()),
          const SizedBox(height: 12),
          buildInfoRow('Danh mục', '${vm.thuChiDanhMucs.length}'),
          const SizedBox(height: 12),
          buildInfoRow('Tổng thu', currencyFormat.format(vm.tongThu)),
          const SizedBox(height: 12),
          buildInfoRow('Tổng chi', currencyFormat.format(vm.tongChi)),
          const SizedBox(height: 12),
          buildInfoRow(
            'Số dư',
            currencyFormat.format(vm.conLai),
            valueColor: vm.conLai >= 0
                ? const Color(0xff2563eb)
                : const Color(0xffdc2626),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel() {
    if (_fromDate != null && _toDate != null) {
      return '${_dateFormat.format(_fromDate!)} - '
          '${_dateFormat.format(_toDate!)}';
    }
    return 'Toàn bộ công trình';
  }

  // ============================================================
  // EMPTY TRANSACTION
  // ============================================================

  Widget _buildNoTransaction() {
    final hasFilter = _fromDate != null && _toDate != null;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 28,
              color: Color(0xff94a3b8),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Chưa có khoản thu chi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            !hasFilter
                ? 'Hãy thêm khoản thu hoặc chi đầu tiên cho công trình.'
                : 'Không có khoản thu chi trong khoảng thời gian đã chọn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 18),
          if (!hasFilter)
            ElevatedButton.icon(
              onPressed: _addThuChi,
              icon: const Icon(Icons.add, size: 17),
              label: const Text('Thêm khoản thu chi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xfffef2f2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 30,
                color: Color(0xffdc2626),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Text(
              'Đã xảy ra lỗi khi tải thông tin thu chi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(_load);
              },
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}