import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/desktop/thu_chi_form_desktop.dart';

import '../../../../data/models/ThuChi.dart';
import '../../../../services/thu_chi_service.dart';
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
  State<ThuChiCongTrinhDesktop> createState() =>
      _ThuChiCongTrinhDesktopState();
}

class _ThuChiCongTrinhDesktopState
    extends State<ThuChiCongTrinhDesktop> {
  final _thuChiService = ThuChiService();

  late Future<ThuChiCongTrinhViewModel> _futureThuChi;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureThuChi = _thuChiService.loadThuChiCongTrinh(
      widget.idCongTrinh,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),
      body: Column(
        children: [
          _buildTopBar(),

          Expanded(
            child: FutureBuilder<ThuChiCongTrinhViewModel>(
              future: _futureThuChi,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return _buildLoading();
                }

                if (snapshot.hasError) {
                  return _buildError(
                    snapshot.error.toString(),
                  );
                }

                if (!snapshot.hasData) {
                  return _buildEmpty();
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

          _buildTopAction(
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

  Widget _buildTopAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 17,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xff475569),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
                'Theo dõi các khoản thu, chi và số dư của công trình',
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

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      ThuChiCongTrinhViewModel vm,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - 32) / 3;

        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              _summaryCard(
                title: 'Tổng thu',
                value: _currencyFormat.format(
                  vm.tongThu,
                ),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xff16a34a),
                background: const Color(0xffecfdf3),
              ),

              const SizedBox(height: 12),

              _summaryCard(
                title: 'Tổng chi',
                value: _currencyFormat.format(
                  vm.tongChi,
                ),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),

              const SizedBox(height: 12),

              _summaryCard(
                title: 'Còn lại',
                value: _currencyFormat.format(
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
              child: _summaryCard(
                title: 'Tổng thu',
                value: _currencyFormat.format(
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
              child: _summaryCard(
                title: 'Tổng chi',
                value: _currencyFormat.format(
                  vm.tongChi,
                ),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xffdc2626),
                background: const Color(0xfffef2f2),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _summaryCard(
                title: 'Còn lại',
                value: _currencyFormat.format(
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

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: color,
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
          _buildTransactionHeader(vm),

          const Divider(
            height: 1,
          ),

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

  Widget _buildTransactionHeader(
      ThuChiCongTrinhViewModel vm,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffeff6ff),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xff2563eb),
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Các khoản thu chi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff172033),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Chi tiết các giao dịch theo danh mục',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff64748b),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${vm.thuChiDanhMucs.length} danh mục',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildDanhMucCard(
      dynamic dmVM,
      ) {
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
                    borderRadius:
                    BorderRadius.circular(8),
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
                    dmVM.danhMucThuChi?.ten ??
                        'Chưa phân loại',
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
                  _currencyFormat.format(
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
                      padding:
                      const EdgeInsets.only(
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

  Widget _buildKhacCard(
      ThuChiCongTrinhViewModel vm,
      ) {
    final items =
        vm.thuChiKhacs.thuchis ?? [];

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
                    borderRadius:
                    BorderRadius.circular(8),
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
                  _currencyFormat.format(
                    vm.thuChiKhacs.conLai,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                    vm.thuChiKhacs.conLai >= 0
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
                    padding:
                    const EdgeInsets.only(
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

  Widget _buildOverviewPanel(
      ThuChiCongTrinhViewModel vm,
      ) {
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
    final total = vm.tongThu.abs() +
        vm.tongChi.abs();

    final incomePercent =
    total == 0 ? 0.0 : vm.tongThu.abs() / total;

    final expensePercent =
    total == 0 ? 0.0 : vm.tongChi.abs() / total;

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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
            'Tỷ lệ giữa tổng thu và tổng chi',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 22),

          _buildProgressRow(
            title: 'Tổng thu',
            value: vm.tongThu,
            percent: incomePercent,
            color: const Color(0xff16a34a),
          ),

          const SizedBox(height: 18),

          _buildProgressRow(
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.conLai >= 0
                            ? 'Số dư hiện tại'
                            : 'Đang âm ngân sách',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _currencyFormat.format(
                          vm.conLai,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
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

  Widget _buildProgressRow({
    required String title,
    required num value,
    required double percent,
    required Color color,
  }) {
    final safePercent =
    percent.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff475569),
                ),
              ),
            ),

            Text(
              _currencyFormat.format(value),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius:
          BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: safePercent,
            minHeight: 7,
            backgroundColor:
            const Color(0xfff1f5f9),
            valueColor:
            AlwaysStoppedAnimation<Color>(
              color,
            ),
          ),
        ),
      ],
    );
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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

          _buildInfoRow(
            'Danh mục',
            '${vm.thuChiDanhMucs.length}',
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            'Tổng thu',
            _currencyFormat.format(
              vm.tongThu,
            ),
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            'Tổng chi',
            _currencyFormat.format(
              vm.tongChi,
            ),
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            'Số dư',
            _currencyFormat.format(
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

  Widget _buildInfoRow(
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff64748b),
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                const Color(0xff334155),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
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
              borderRadius:
              BorderRadius.circular(14),
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
            'Hãy thêm khoản thu hoặc chi đầu tiên cho công trình.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 18),

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
              backgroundColor:
              const Color(0xff2563eb),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
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

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      ),
    );
  }

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
          borderRadius:
          BorderRadius.circular(12),
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
                borderRadius:
                BorderRadius.circular(12),
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
                backgroundColor:
                const Color(0xff2563eb),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 30,
              color: Color(0xff94a3b8),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Chưa có dữ liệu thu chi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff334155),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Dữ liệu thu chi của công trình sẽ hiển thị tại đây.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}