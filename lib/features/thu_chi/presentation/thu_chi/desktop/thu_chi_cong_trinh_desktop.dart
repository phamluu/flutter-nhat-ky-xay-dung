import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/ThuChi.dart';
import '../../../data/services/thu_chi_service.dart';
import '../widgets/buildInfoRow.dart';
import '../widgets/buildLoading.dart';
import '../widgets/buildProgressRow.dart';
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
  // ============================================================

  String _filterType = 'all';

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _load();
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
  }

  Future<void> _refresh() async {
    setState(_load);
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
      setState(_load);
    }
  }

  // ============================================================
  // FILTER DATE RANGE
  // ============================================================

  (DateTime, DateTime)? _getFilterDateRange() {
    switch (_filterType) {
      case 'month':
        final from = DateTime(
          _selectedYear,
          _selectedMonth,
          1,
        );

        final to = DateTime(
          _selectedYear,
          _selectedMonth + 1,
          0,
        );

        return (
          DateTime(
            from.year,
            from.month,
            from.day,
          ),
          DateTime(
            to.year,
            to.month,
            to.day,
          ),
        );

      case 'year':
        return (
          DateTime(
            _selectedYear,
            1,
            1,
          ),
          DateTime(
            _selectedYear,
            12,
            31,
          ),
        );

      case 'range':
        if (_fromDate == null || _toDate == null) {
          return null;
        }

        return (
          DateTime(
            _fromDate!.year,
            _fromDate!.month,
            _fromDate!.day,
          ),
          DateTime(
            _toDate!.year,
            _toDate!.month,
            _toDate!.day,
          ),
        );

      case 'all':
      default:
        return null;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      appBar: AppBar(
        title: _buildTopBar(),
      ),
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
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
          const Spacer(),
          buildTopAction(
            icon: Icons.refresh,
            label: 'Làm mới',
            onPressed: _refresh,
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _addThuChi,
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            label: const Text(
              'Thêm khoản thu chi',
            ),
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
      ),
    );
  }

  // ============================================================
  // DESKTOP CONTENT
  // ============================================================

  Widget _buildDesktopContent(
    ThuChiCongTrinhViewModel vm,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1100;

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
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTransactionArea(vm),
                    const SizedBox(height: 20),
                    _buildOverviewPanel(vm),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildTransactionArea(vm),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      flex: 3,
                      child: _buildOverviewPanel(vm),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
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
      ],
    );
  }

  String _getFilterDescription() {
    switch (_filterType) {
      case 'month':
        return 'Theo dõi thu chi tháng $_selectedMonth/$_selectedYear';

      case 'year':
        return 'Theo dõi thu chi năm $_selectedYear';

      case 'range':
        if (_fromDate != null && _toDate != null) {
          final format = DateFormat('dd/MM/yyyy');

          return 'Theo dõi thu chi từ '
              '${format.format(_fromDate!)} đến '
              '${format.format(_toDate!)}';
        }

        return 'Theo dõi các khoản thu, chi và số dư của công trình';

      case 'all':
      default:
        return 'Theo dõi các khoản thu, chi và số dư của công trình';
    }
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
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
          if (constraints.maxWidth < 750) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterTitle(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterButton(
                      label: 'Tất cả',
                      value: 'all',
                    ),
                    _buildFilterButton(
                      label: 'Theo tháng',
                      value: 'month',
                    ),
                    _buildFilterButton(
                      label: 'Theo năm',
                      value: 'year',
                    ),
                    _buildFilterButton(
                      label: 'Khoảng thời gian',
                      value: 'range',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFilterValueControl(),
              ],
            );
          }

          return Row(
            children: [
              _buildFilterTitle(),
              const SizedBox(width: 20),
              _buildFilterButton(
                label: 'Tất cả',
                value: 'all',
              ),
              const SizedBox(width: 6),
              _buildFilterButton(
                label: 'Theo tháng',
                value: 'month',
              ),
              const SizedBox(width: 6),
              _buildFilterButton(
                label: 'Theo năm',
                value: 'year',
              ),
              const SizedBox(width: 6),
              _buildFilterButton(
                label: 'Khoảng thời gian',
                value: 'range',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFilterValueControl(),
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

  Widget _buildFilterButton({
    required String label,
    required String value,
  }) {
    final selected = _filterType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () async {
        if (value == 'range') {
          await _selectDateRange();
          return;
        }

        if (_filterType == value) {
          return;
        }

        setState(() {
          _filterType = value;
          _load();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffeff6ff) : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? const Color(0xff2563eb) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xff2563eb) : const Color(0xff475569),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterValueControl() {
    switch (_filterType) {
      case 'month':
        return _buildMonthSelector();

      case 'year':
        return _buildYearSelector();

      case 'range':
        return _buildRangeSelector();

      case 'all':
      default:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Đang hiển thị toàn bộ thời gian',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        );
    }
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _buildMonthSelector() {
    final months = List.generate(
      12,
      (index) => index + 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDropdown<int>(
          value: _selectedMonth,
          items: months,
          itemLabel: (month) => 'Tháng ${month.toString().padLeft(2, '0')}',
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedMonth = value;
              _load();
            });
          },
        ),
        const SizedBox(width: 8),
        buildDropdown<int>(
          value: _selectedYear,
          items: getYears(),
          itemLabel: (year) => '$year',
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedYear = value;
              _load();
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // YEAR SELECTOR
  // ============================================================

  Widget _buildYearSelector() {
    return buildDropdown<int>(
      value: _selectedYear,
      items: getYears(),
      itemLabel: (year) => 'Năm $year',
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedYear = value;
          _load();
        });
      },
    );
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  Widget _buildRangeSelector() {
    if (_fromDate == null || _toDate == null) {
      return OutlinedButton.icon(
        onPressed: _selectDateRange,
        icon: const Icon(
          Icons.date_range_outlined,
          size: 17,
        ),
        label: const Text(
          'Chọn khoảng thời gian',
        ),
      );
    }

    final format = DateFormat('dd/MM/yyyy');

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: _selectDateRange,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffeff6ff),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: const Color(0xffbfdbfe),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.date_range_outlined,
              size: 17,
              color: Color(0xff2563eb),
            ),
            const SizedBox(width: 8),
            Text(
              '${format.format(_fromDate!)} - '
              '${format.format(_toDate!)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff2563eb),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.edit_calendar_outlined,
              size: 15,
              color: Color(0xff2563eb),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(
              start: _fromDate!,
              end: _toDate!,
            )
          : DateTimeRange(
              start: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                1,
              ),
              end: DateTime.now(),
            ),
      locale: const Locale(
        'vi',
        'VN',
      ),
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _filterType = 'range';
      _fromDate = range.start;
      _toDate = range.end;
      _load();
    });
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
    ThuChiCongTrinhViewModel vm,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 32) / 3;

        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              summaryCard(
                title: 'Tổng thu',
                value: currencyFormat.format(
                  vm.tongThu,
                ),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xff16a34a),
                background: const Color(0xffecfdf3),
              ),
              const SizedBox(height: 12),
              summaryCard(
                title: 'Tổng chi',
                value: currencyFormat.format(
                  vm.tongChi,
                ),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),
              const SizedBox(height: 12),
              summaryCard(
                title: 'Còn lại',
                value: currencyFormat.format(
                  vm.conLai,
                ),
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
                value: currencyFormat.format(
                  vm.tongThu,
                ),
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
                value: currencyFormat.format(
                  vm.tongChi,
                ),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: summaryCard(
                title: 'Còn lại',
                value: currencyFormat.format(
                  vm.conLai,
                ),
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

  Widget _buildTransactionArea(
    ThuChiCongTrinhViewModel vm,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          buildTransactionHeader(vm.thuChiDanhMucs.length),
          const Divider(
            height: 1,
          ),
          buildTamUngChiLuong(vm),
          if (vm.thuChiDanhMucs.isEmpty &&
              (vm.thuChiKhacs.thuchis == null ||
                  vm.thuChiKhacs.thuchis!.isEmpty))
            _buildNoTransaction()
          else
            Column(
              children: [
                ...vm.thuChiDanhMucs.map(
                  (dmVM) => _buildDanhMucCard(
                    dmVM,
                  ),
                ),
                if (vm.thuChiKhacs.thuchis != null &&
                    vm.thuChiKhacs.thuchis!.isNotEmpty)
                  _buildKhacCard(vm),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildDanhMucCard(dynamic dmVM,) {
    final items = dmVM.thuchis ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration: const BoxDecoration(
              color: Color(0xfff8fafc),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xff94a3b8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(
                    dmVM.conLai,
                  ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...items.map(
                    (tc) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 6,
                      ),
                      child: ThuChiItemDesktop(
                        tc: tc,
                        onRefresh: () {
                          setState(_load);
                        },
                      ),
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
  // OTHER
  // ============================================================

  Widget _buildKhacCard(ThuChiCongTrinhViewModel vm,) {
    final items = vm.thuChiKhacs.thuchis ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            decoration: const BoxDecoration(
              color: Color(0xfff8fafc),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
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
                  currencyFormat.format(
                    vm.thuChiKhacs.conLai,
                  ),
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ...items.map(
                  (tc) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 6,
                    ),
                    child: ThuChiItemDesktop(
                      tc: tc,
                      onRefresh: () {
                        setState(_load);
                      },
                    ),
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
  // RIGHT OVERVIEW
  // ============================================================

  Widget _buildOverviewPanel(ThuChiCongTrinhViewModel vm,) {
    return Column(
      children: [
        _buildBalancePanel(vm),
        const SizedBox(height: 16),
        _buildQuickInfo(vm),
      ],
    );
  }

  Widget _buildBalancePanel(
    ThuChiCongTrinhViewModel vm,
  ) {
    final total = vm.tongThu.abs() + vm.tongChi.abs();

    final incomePercent = total == 0 ? 0.0 : vm.tongThu.abs() / total;

    final expensePercent = total == 0 ? 0.0 : vm.tongChi.abs() / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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
                        currencyFormat.format(
                          vm.conLai,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: vm.conLai >= 0
                              ? const Color(
                                  0xff2563eb,
                                )
                              : const Color(
                                  0xffdc2626,
                                ),
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
    switch (_filterType) {
      case 'month':
        return 'Tỷ lệ thu chi tháng $_selectedMonth/$_selectedYear';

      case 'year':
        return 'Tỷ lệ thu chi năm $_selectedYear';

      case 'range':
        return 'Tỷ lệ thu chi trong khoảng đã chọn';

      case 'all':
      default:
        return 'Tỷ lệ giữa tổng thu và tổng chi';
    }
  }

  Widget _buildQuickInfo(
    ThuChiCongTrinhViewModel vm,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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
          buildInfoRow(
            'Phạm vi',
            _getFilterLabel(),
          ),
          const SizedBox(height: 12),
          buildInfoRow(
            'Danh mục',
            '${vm.thuChiDanhMucs.length}',
          ),
          const SizedBox(height: 12),
          buildInfoRow(
            'Tổng thu',
            currencyFormat.format(
              vm.tongThu,
            ),
          ),
          const SizedBox(height: 12),
          buildInfoRow(
            'Tổng chi',
            currencyFormat.format(
              vm.tongChi,
            ),
          ),
          const SizedBox(height: 12),
          buildInfoRow(
            'Số dư',
            currencyFormat.format(
              vm.conLai,
            ),
            valueColor: vm.conLai >= 0
                ? const Color(0xff2563eb)
                : const Color(0xffdc2626),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel() {
    switch (_filterType) {
      case 'month':
        return 'Tháng $_selectedMonth/$_selectedYear';

      case 'year':
        return 'Năm $_selectedYear';

      case 'range':
        if (_fromDate != null && _toDate != null) {
          final format = DateFormat('dd/MM/yyyy');

          return '${format.format(_fromDate!)} - '
              '${format.format(_toDate!)}';
        }

        return 'Khoảng thời gian';

      case 'all':
      default:
        return 'Toàn bộ công trình';
    }
  }

  // ============================================================
  // EMPTY TRANSACTION
  // ============================================================

  Widget _buildNoTransaction() {
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
            _filterType == 'all'
                ? 'Hãy thêm khoản thu hoặc chi đầu tiên cho công trình.'
                : 'Không có khoản thu chi trong khoảng thời gian đã chọn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 18),
          if (_filterType == 'all')
            ElevatedButton.icon(
              onPressed: _addThuChi,
              icon: const Icon(
                Icons.add,
                size: 17,
              ),
              label: const Text(
                'Thêm khoản thu chi',
              ),
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

  // ============================================================
  // LOADING
  // ============================================================

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    String error,
  ) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Đã xảy ra lỗi khi tải thông tin thu chi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(_load);
              },
              icon: const Icon(
                Icons.refresh,
                size: 17,
              ),
              label: const Text(
                'Thử lại',
              ),
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

  // ============================================================
  // EMPTY PAGE
  // ============================================================
}
