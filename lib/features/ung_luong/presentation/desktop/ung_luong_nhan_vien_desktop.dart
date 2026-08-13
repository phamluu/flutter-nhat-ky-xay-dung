// Danh sách đã ứng trong 1 tháng của từng nhân viên công trình
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/ung_luong/presentation/desktop/ung_luong_form_desktop.dart';
import 'package:nhat_ky_xay_dung/services/ChotChiLuongService.dart';
import 'package:nhat_ky_xay_dung/services/ung_luong_service.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/UngLuong.dart';
import '../../screens/🚀 📱 UngLuongFormScreen.dart';

class UngLuongNhanVienDesktop extends StatefulWidget {
  final int? idNhanVienCongTrinh;
  final String? hoTen;
  final String? congTrinh;
  final int thang;
  final int nam;

  const UngLuongNhanVienDesktop({
    Key? key,
    this.idNhanVienCongTrinh,
    this.hoTen,
    this.congTrinh,
    required this.thang,
    required this.nam,
  }) : super(key: key);

  @override
  State<UngLuongNhanVienDesktop> createState() => _UngLuongNhanVienDesktopState();
}

class _UngLuongNhanVienDesktopState extends State<UngLuongNhanVienDesktop> {
  final _service = UngLuongService();

  late final Chotchiluongservice _chotLuong;
  late bool daChotLuong = false;
  late Future<List<Ungluong>> _future;

  @override
  void initState() {
    super.initState();

    _chotLuong = Chotchiluongservice(
      ChotChiLuongRepository(),
    );

    _future = _service.getUngLuongNhanVien(
      widget.idNhanVienCongTrinh!,
      widget.thang,
      widget.nam,
    );

    _loadChotLuong();
  }

  Future<void> _loadChotLuong() async {
    final chot = await _chotLuong.isDaChotLuong(
      widget.idNhanVienCongTrinh!,
      widget.thang,
      widget.nam,
    );

    if (!mounted) return;

    setState(() {
      daChotLuong = chot;
    });
  }

  Future<void> _reload() async {
    final chot = await _chotLuong.isDaChotLuong(
      widget.idNhanVienCongTrinh!,
      widget.thang,
      widget.nam,
    );

    if (!mounted) return;

    setState(() {
      daChotLuong = chot;

      _future = _service.getUngLuongNhanVien(
        widget.idNhanVienCongTrinh!,
        widget.thang,
        widget.nam,
      );
    });
  }

  // ============================================================
  // THÊM ỨNG LƯƠNG
  // ============================================================

  void _openAddForm() {
    if (daChotLuong) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongFormDesktop(
          idNhanVienCongTrinh:
          widget.idNhanVienCongTrinh,
          hoTen: widget.hoTen,
          tenCongTrinh: widget.congTrinh,
          thang: widget.thang, nam: widget.nam,
        ),
      ),
    ).then((_) => _reload());
  }

  // ============================================================
  // SỬA ỨNG LƯƠNG
  // ============================================================

  void _openEditForm(Ungluong ul) {
    if (daChotLuong) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongFormScreen(
          ul: ul,
          idNhanVienCongTrinh:
          widget.idNhanVienCongTrinh,
        ),
      ),
    ).then((_) => _reload());
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ========================================================
      // HEADER DESKTOP
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        titleSpacing: 24,

        title: Row(
          children: [
            const Icon(
              Icons.payments_outlined,
              color: Colors.blue,
            ),

            const SizedBox(width: 10),

            Text(
              'Quản lý ứng lương tháng ${widget.thang}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              '/ ${widget.nam}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [
          // ----------------------------------------------------
          // TRẠNG THÁI CHỐT LƯƠNG
          // ----------------------------------------------------

          if (daChotLuong)
            Container(
              margin: const EdgeInsets.only(right: 12),

              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade100,
                ),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 17,
                    color: Colors.red.shade700,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    'Đã chốt lương',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // ----------------------------------------------------
          // BUTTON THÊM
          // ----------------------------------------------------

          Padding(
            padding: const EdgeInsets.only(
              right: 24,
            ),

            child: FilledButton.icon(
              onPressed:
              daChotLuong ? null : _openAddForm,

              icon: const Icon(
                Icons.add,
                size: 19,
              ),

              label: const Text(
                'Thêm ứng lương',
              ),

              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  160,
                  42,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: FutureBuilder<List<Ungluong>>(
        future: _future,

        builder: (
            context,
            snapshot,
            ) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          final data =
              snapshot.data ?? [];

          // ----------------------------------------------------
          // DESKTOP CONTENT
          // ----------------------------------------------------

          return LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final maxWidth =
              constraints.maxWidth > 1400
                  ? 1400.0
                  : constraints.maxWidth;

              return SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  40,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(
                      maxWidth: maxWidth,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,

                      children: [
                        // Thông tin nhân viên
                        _buildEmployeeInfo(),

                        const SizedBox(
                          height: 18,
                        ),

                        // Thống kê
                        _buildStatistics(
                          data,
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // Danh sách
                        _buildHistorySection(
                          data,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // THÔNG TIN NHÂN VIÊN
  // ============================================================

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: Colors.blue.shade50,

              borderRadius:
              BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.person_outline,
              color: Colors.blue,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  widget.hoTen ?? '',

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons
                          .location_on_outlined,
                      size: 16,
                      color:
                      Colors.grey.shade600,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Flexible(
                      child: Text(
                        widget.congTrinh ??
                            '',

                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                          fontSize: 14,
                        ),

                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Status
          _statusBadge(),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge() {
    final color =
    daChotLuong
        ? Colors.red
        : Colors.green;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),

      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius:
        BorderRadius.circular(8),
      ),

      child: Row(
        children: [
          Icon(
            daChotLuong
                ? Icons.lock_outline
                : Icons.check_circle_outline,

            size: 17,

            color: color.shade700,
          ),

          const SizedBox(width: 7),

          Text(
            daChotLuong
                ? 'Đã chốt lương'
                : 'Chưa chốt lương',

            style: TextStyle(
              color: color.shade700,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THỐNG KÊ
  // ============================================================

  Widget _buildStatistics(
      List<Ungluong> data,
      ) {
    final total = data.fold<num>(
      0,
          (
          sum,
          item,
          ) =>
      sum + (item.soTien ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon:
            Icons.receipt_long_outlined,
            title: 'Số lần ứng',
            value:
            '${data.length} lần',
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            icon: Icons
                .account_balance_wallet_outlined,
            title:
            'Tổng tiền đã ứng',
            value:
            formatCurrency(total),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            icon:
            Icons.calendar_month_outlined,
            title: 'Kỳ lương',
            value:
            'Tháng ${widget.thang}/${widget.nam}',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: Colors.blue.shade50,

              borderRadius:
              BorderRadius.circular(10),
            ),

            child: Icon(
              icon,
              color: Colors.blue,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

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

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(0xFF111827),
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
  // HISTORY
  // ============================================================

  Widget _buildHistorySection(
      List<Ungluong> data,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [
          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              16,
            ),

            child: Row(
              children: [
                const Text(
                  'Lịch sử ứng lương',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(0xFF111827),
                  ),
                ),

                const Spacer(),

                Text(
                  '${data.length} bản ghi',

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          if (data.isEmpty)
            _noData()
          else
            _buildDesktopTable(
              data,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DATA TABLE DESKTOP
  // ============================================================

  Widget _buildDesktopTable(
      List<Ungluong> data,
      ) {
    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,

      child: SizedBox(
        width: 900,

        child: DataTable(
          headingRowHeight: 48,

          dataRowMinHeight: 62,
          dataRowMaxHeight: 72,

          horizontalMargin: 20,
          columnSpacing: 28,

          headingTextStyle:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
            color:
            Color(0xFF4B5563),
            fontSize: 13,
          ),

          columns: const [
            DataColumn(
              label: Text('#'),
            ),

            DataColumn(
              label: Text('Ngày ứng'),
            ),

            DataColumn(
              label: Text('Số tiền'),
            ),

            DataColumn(
              label: Text('Lý do'),
            ),

            DataColumn(
              label: Text('Thao tác'),
            ),
          ],

          rows: List.generate(
            data.length,
                (index) {
              final ul = data[index];

              return DataRow(
                cells: [
                  // STT
                  DataCell(
                    Text(
                      '${(index + 1).toString().padLeft(2, '0')}',

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  // NGÀY
                  DataCell(
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,

                      children: [
                        Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 16,
                          color: Colors
                              .grey
                              .shade500,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          ul.ngayUng != null
                              ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            ul.ngayUng!,
                          )
                              : 'Chưa có',
                        ),
                      ],
                    ),
                  ),

                  // SỐ TIỀN
                  DataCell(
                    Text(
                      formatCurrency(
                        ul.soTien ?? 0,
                      ),

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                        color:
                        Color(0xFF111827),
                      ),
                    ),
                  ),

                  // LÝ DO
                  DataCell(
                    SizedBox(
                      width: 330,

                      child: Text(
                        ul.lyDo
                            ?.isNotEmpty ==
                            true
                            ? ul.lyDo!
                            : '—',

                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ),
                  ),

                  // THAO TÁC
                  DataCell(
                    Row(
                      mainAxisSize:
                      MainAxisSize.min,

                      children: [
                        IconButton(
                          tooltip: 'Sửa',

                          onPressed:
                          daChotLuong
                              ? null
                              : () =>
                              _openEditForm(
                                ul,
                              ),

                          icon: const Icon(
                            Icons
                                .edit_outlined,
                            size: 20,
                          ),

                          color: Colors.blue,
                        ),

                        IconButton(
                          tooltip: 'Xóa',

                          onPressed:
                          daChotLuong
                              ? null
                              : () =>
                              _deleteUngLuong(
                                ul,
                              ),

                          icon: const Icon(
                            Icons
                                .delete_outline,
                            size: 20,
                          ),

                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _noData() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),

      child: Column(
        children: [
          Icon(
            Icons.money_off_outlined,
            size: 52,
            color:
            Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          Text(
            'Tháng này ${widget.hoTen ?? ''} chưa ứng lương',

            textAlign:
            TextAlign.center,

            style: TextStyle(
              fontSize: 15,
              color:
              Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

          if (!daChotLuong)
            OutlinedButton.icon(
              onPressed:
              _openAddForm,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Thêm khoản ứng đầu tiên',
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteUngLuong(
      Ungluong ul,
      ) async {
    final confirm =
    await showDialog<bool>(
      context: context,

      builder: (ctx) =>
          AlertDialog(
            title: const Text(
              'Xác nhận xóa',
            ),

            content: const Text(
              'Bạn có chắc muốn xóa khoản ứng lương này?',
            ),

            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(
                      ctx,
                      false,
                    ),

                child: const Text(
                  'Hủy',
                ),
              ),

              FilledButton(
                style:
                FilledButton.styleFrom(
                  backgroundColor:
                  Colors.red,
                ),

                onPressed: () =>
                    Navigator.pop(
                      ctx,
                      true,
                    ),

                child: const Text(
                  'Xóa',
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _service.deleteUngLuong(
        ul.id!,
      );

      await _reload();
    }
  }
}