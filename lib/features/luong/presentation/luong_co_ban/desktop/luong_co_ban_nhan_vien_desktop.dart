import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

import '../../../data/models/LuongCoBan.dart';
import '../../../data/repositories/luong_coban_repository.dart';
import '../../../data/services/luong_co_ban_service.dart';
import 'luong_co_ban_form_desktop.dart';

class LuongCoBanNhanVienDesktop extends StatefulWidget {
  final int idNhanVien;
  final String? hoTen;

  const LuongCoBanNhanVienDesktop({
    super.key,
    required this.idNhanVien,
    this.hoTen,
  });

  @override
  State<LuongCoBanNhanVienDesktop> createState() =>
      _LuongCoBanNhanVienDesktopState();
}

class _LuongCoBanNhanVienDesktopState
    extends State<LuongCoBanNhanVienDesktop> {
  final LuongCoBanService _service = LuongCoBanService();
  final _repo = LuongCoBanRepository();
  final NumberFormat currencyFormat =
  NumberFormat("#,##0", "vi_VN");

  late Future<List<LuongCoBanNhanVienModel>> _futureNhanVien;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureNhanVien =
        _service.getLuongCoBanNhanVien(widget.idNhanVien);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futureNhanVien;
  }

  Future<void> _openForm({
    LuongCoBanNhanVienModel? luong,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LuongCoBanFormDesktop(
          idNhanVien: widget.idNhanVien,
          hoTen: widget.hoTen,
          luong: luong,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(_load);
    }
  }

  Future<void> _delete(
      LuongCoBanNhanVienModel luong,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa mức lương '
              '${currencyFormat.format(luong.soTien ?? 0)} đ không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await _repo.delete(luong.id!);

    if (!mounted) return;
      showSuccessToast(context, 'Xóa lương cơ bản thành công');
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
          title: _buildHeader(theme),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<
                  List<LuongCoBanNhanVienModel>>(
                future: _futureNhanVien,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(
                      snapshot.error,
                    );
                  }

                  final nhanViens =
                      snapshot.data ?? [];

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: nhanViens.isEmpty
                        ? _emptyState()
                        : _buildContent(nhanViens),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            child: Icon(
              Icons.payments_outlined,
              color: theme.colorScheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Lương cơ bản',
                  style:
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.hoTen?.trim().isNotEmpty == true
                      ? 'Nhân viên: ${widget.hoTen}'
                      : 'Quản lý lịch sử lương cơ bản của nhân viên',
                  style:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const Text('Làm mới'),
          ),

          const SizedBox(width: 10),

          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(
              Icons.add,
              size: 19,
            ),
            label: const Text(
              'Thêm mức lương',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
      List<LuongCoBanNhanVienModel> nhanViens,
      ) {
    final latestSalary =
        nhanViens.first.soTien ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        32,
        28,
        32,
        32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 1400,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildSummary(
                nhanViens,
                latestSalary,
              ),

              const SizedBox(height: 22),

              _buildTableCard(nhanViens),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      List<LuongCoBanNhanVienModel> nhanViens,
      num latestSalary,
      ) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.payments_outlined,
            title: 'Mức lương hiện tại',
            value:
            '${currencyFormat.format(latestSalary)} đ',
            subtitle:
            'Theo bản ghi mới nhất',
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _summaryCard(
            icon: Icons.history,
            title: 'Số lần điều chỉnh',
            value: '${nhanViens.length}',
            subtitle:
            'Bản ghi lịch sử lương',
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _summaryCard(
            icon: Icons.event_available_outlined,
            title: 'Ngày áp dụng gần nhất',
            value: _formatDate(
              nhanViens.first.ngayApDung,
            ),
            subtitle:
            'Theo bản ghi đầu tiên',
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.08),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
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
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
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
  // TABLE
  // ============================================================

  Widget _buildTableCard(
      List<LuongCoBanNhanVienModel> nhanViens,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                20,
                22,
                16,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lịch sử lương',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Danh sách các mức lương đã áp dụng',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                      Colors.grey.shade100,
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${nhanViens.length} bản ghi',
                      style: TextStyle(
                        color:
                        Colors.grey.shade700,
                        fontWeight:
                        FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 68,
                dataRowMaxHeight: 82,
                columnSpacing: 30,
                horizontalMargin: 22,

                headingTextStyle: TextStyle(
                  color:
                  Colors.grey.shade700,
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 13,
                ),

                columns: const [
                  DataColumn(
                    label: Text('STT'),
                  ),
                  DataColumn(
                    label: Text('MỨC LƯƠNG'),
                  ),
                  DataColumn(
                    label: Text('NGÀY ÁP DỤNG'),
                  ),
                  DataColumn(
                    label: Text('GHI CHÚ'),
                  ),
                  DataColumn(
                    label: Text('TRẠNG THÁI'),
                  ),
                  DataColumn(
                    label: Text('THAO TÁC'),
                  ),
                ],

                rows: List.generate(
                  nhanViens.length,
                      (index) => _buildDataRow(
                    nhanViens[index],
                    index,
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
  // DATA ROW
  // ============================================================

  DataRow _buildDataRow(
      LuongCoBanNhanVienModel luong,
      int index,
      ) {
    final isLatest = index == 0;

    final note =
    luong.ghiChu?.trim();

    return DataRow(
      cells: [
        DataCell(
          Text(
            '${index + 1}',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),

        DataCell(
          Text(
            '${currencyFormat.format(luong.soTien ?? 0)} đ',
            style: const TextStyle(
              fontWeight:
              FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),

        DataCell(
          Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color:
                Colors.grey.shade500,
              ),

              const SizedBox(width: 8),

              Text(
                _formatDate(
                  luong.ngayApDung,
                ),
              ),
            ],
          ),
        ),

        DataCell(
          SizedBox(
            width: 360,
            child: Text(
              note?.isNotEmpty == true
                  ? note!
                  : 'Không có ghi chú',
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color:
                note?.isNotEmpty == true
                    ? Colors.grey.shade800
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ),

        DataCell(
          _statusBadge(
            isLatest
                ? 'Đang áp dụng'
                : 'Lịch sử',
            isLatest,
          ),
        ),

        DataCell(
          Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Sửa',
                child: IconButton(
                  onPressed: () =>
                      _openForm(
                        luong: luong,
                      ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                  color:
                  Colors.blue.shade700,
                ),
              ),

              Tooltip(
                message: 'Xóa',
                child: IconButton(
                  onPressed: () =>
                      _delete(luong),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                  ),
                  color:
                  Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
      String label,
      bool active,
      ) {
    final color =
    active ? Colors.green : Colors.grey;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(Object? error) {
    return Center(
      child: Container(
        padding:
        const EdgeInsets.all(24),
        constraints:
        const BoxConstraints(
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52,
              color:
              Colors.red.shade300,
            ),

            const SizedBox(height: 14),

            const Text(
              'Không thể tải lịch sử lương',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$error',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Thử lại',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
          MediaQuery.sizeOf(context)
              .height *
              .65,
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    size: 36,
                    color:
                    Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Chưa có lịch sử lương',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Hãy thêm mức lương đầu tiên cho nhân viên này.',
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 18),

                FilledButton.icon(
                  onPressed: () =>
                      _openForm(),
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Thêm mức lương',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Chưa có';
    }

    return DateFormat(
      'dd/MM/yyyy',
    ).format(date);
  }
}