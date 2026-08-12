import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/desktop/thu_chi_form_desktop.dart';

import '../../../../data/models/ThuChi.dart';
import '../../../../services/thu_chi_service.dart';
import '../../widgets/ThuChiItem.dart';

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

  final NumberFormat _currencyFormat =
  NumberFormat.currency(
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
    _futureThuChi =
        _thuChiService.loadThuChiCongTrinh(
          widget.idCongTrinh,
        );
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quản lý thu chi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
              Text(
                widget.tenCongTrinh ?? "",
                style: const TextStyle(fontSize: 13, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xfff5f6f8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<
                    ThuChiCongTrinhViewModel>(
                  future: _futureThuChi,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildError(
                        snapshot.error.toString(),
                      );
                    }

                    if (!snapshot.hasData) {
                      return _buildEmpty();
                    }

                    return _buildContent(
                      snapshot.data!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );

  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.blue.shade700,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý thu chi',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.tenCongTrinh?.isNotEmpty == true
                    ? widget.tenCongTrinh!
                    : 'Theo dõi thu chi công trình',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: _addThuChi,
          icon: const Icon(
            Icons.add,
            size: 19,
          ),
          label: const Text(
            'Thêm khoản thu chi',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
      ThuChiCongTrinhViewModel vm,
      ) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(_load);
        await _futureThuChi;
      },
      child: ListView(
        padding:
        const EdgeInsets.only(bottom: 30),
        children: [
          _buildSummary(vm),

          const SizedBox(height: 24),

          if (vm.thuChiDanhMucs.isNotEmpty)
            _buildSectionTitle(
              'Các khoản thu chi',
              Icons.receipt_long_outlined,
            ),

          const SizedBox(height: 10),

          ...vm.thuChiDanhMucs.map(
                (dmVM) => _buildDanhMucCard(
              dmVM,
            ),
          ),

          if (vm.thuChiKhacs.thuchis != null &&
              vm.thuChiKhacs.thuchis!.isNotEmpty) ...[
            const SizedBox(height: 10),

            _buildKhacCard(vm),
          ],
        ],
      ),
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
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              _summaryCard(
                title: 'Tổng thu',
                value: _currencyFormat
                    .format(vm.tongThu),
                icon: Icons.trending_up,
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              _summaryCard(
                title: 'Tổng chi',
                value: _currencyFormat
                    .format(vm.tongChi),
                icon: Icons.trending_down,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              _summaryCard(
                title: 'Còn lại',
                value: _currencyFormat
                    .format(vm.conLai),
                icon:
                Icons.account_balance_wallet,
                color: vm.conLai >= 0
                    ? Colors.blue
                    : Colors.red,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Tổng thu',
                value: _currencyFormat
                    .format(vm.tongThu),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _summaryCard(
                title: 'Tổng chi',
                value: _currencyFormat
                    .format(vm.tongChi),
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _summaryCard(
                title: 'Còn lại',
                value: _currencyFormat
                    .format(vm.conLai),
                icon:
                Icons.account_balance_wallet,
                color: vm.conLai >= 0
                    ? Colors.blue
                    : Colors.red,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                    color: color,
                  ),
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DANH MỤC
  // ============================================================

  Widget _buildDanhMucCard(dynamic dmVM) {
    final items = dmVM.thuchis ?? [];

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color:
              Colors.blue.withOpacity(0.06),
              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.blue
                        .withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 19,
                    color:
                    Colors.blue.shade700,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    dmVM.danhMucThuChi
                        ?.ten ??
                        'Chưa phân loại',
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  _currencyFormat
                      .format(dmVM.conLai),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    dmVM.conLai >= 0
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          if (items.isEmpty)
            Padding(
              padding:
              const EdgeInsets.all(20),
              child: Text(
                'Chưa có khoản thu chi',
                style: TextStyle(
                  color:
                  Colors.grey.shade500,
                ),
              ),
            )
          else
            Padding(
              padding:
              const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...items.map(
                        (tc) => Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        bottom: 6,
                      ),
                      child: ThuChiItem(
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
  // KHÁC
  // ============================================================

  Widget _buildKhacCard(
      ThuChiCongTrinhViewModel vm,
      ) {
    final items =
        vm.thuChiKhacs.thuchis ?? [];

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.grey
                  .withOpacity(0.08),
              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                  BoxDecoration(
                    color: Colors.grey
                        .withOpacity(0.15),
                    borderRadius:
                    BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    size: 19,
                    color:
                    Colors.grey.shade700,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Khác',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  _currencyFormat.format(
                    vm.thuChiKhacs.conLai,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color: vm.thuChiKhacs
                        .conLai >=
                        0
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(10),
            child: Column(
              children: [
                ...items.map(
                      (tc) => Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 6,
                    ),
                    child: ThuChiItem(
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
            Colors.blue.withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 19,
            color: Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xff263238),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR / EMPTY
  // ============================================================

  Widget _buildError(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                setState(_load);
              },
              icon:
              const Icon(Icons.refresh),
              label:
              const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu thu chi',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}