// Danh sách đã ứng trong 1 tháng của từng nhân viên công trình
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/services/ChotChiLuongService.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/luong/presentation/ung_luong/desktop/ung_luong_form_desktop.dart';

import '../../../../../core/utils/date_utils.dart';
import '../../../data/models/UngLuong.dart';
import '../../../data/repositories/ung_luong_repository.dart';
import '../screens/🚀 📱 UngLuongFormScreen.dart';
import 'ung_luong_detail_desktop.dart';

class UngLuongNhanVienDesktop extends StatefulWidget {
  final int? idNhanVienCongTrinh;
  final String? hoTen;
  final String? congTrinh;
  final int? thang;
  final int? nam;
  final int? idBangChamCong;
  final String? kyLuong;
  const UngLuongNhanVienDesktop(
      {Key? key,
      this.idNhanVienCongTrinh,
      this.hoTen,
      this.congTrinh,
      this.thang,
      this.nam,
      this.idBangChamCong,
      this.kyLuong})
      : super(key: key);
  @override
  State<UngLuongNhanVienDesktop> createState() =>
      _UngLuongNhanVienDesktopState();
}

class _UngLuongNhanVienDesktopState extends State<UngLuongNhanVienDesktop> {
  final _service = UngLuongRepository();
  late final Chotchiluongservice _chotLuong;
  late final ChotChiLuongRepository _chotLuongRepo;
  late bool daChotLuong = false;
  late Future<List<Ungluong>> _future;
  @override
  void initState() {
    super.initState();
    _chotLuong = Chotchiluongservice(
      ChotChiLuongRepository(),
    );
    _chotLuongRepo = ChotChiLuongRepository();
    _future = _service.getUngLuongNhanVien(widget.idNhanVienCongTrinh!,
        kyLuong: widget.kyLuong);
    _loadChotLuong();
  }

  Future<void> _loadChotLuong() async {
    final chot = await _chotLuongRepo.checkDaChotLuong(
        idBangChamCong: widget.idBangChamCong,
        idNhanVienCongTrinh: widget.idNhanVienCongTrinh!);
    if (!mounted) return;
    setState(() {
      daChotLuong = chot;
    });
  }

  Future<void> _reload() async {
    final chot = await _chotLuongRepo.checkDaChotLuong(
        idBangChamCong: widget.idBangChamCong,
        idNhanVienCongTrinh: widget.idNhanVienCongTrinh!);
    if (!mounted) return;
    setState(() {
      daChotLuong = chot;

      _future = _service.getUngLuongNhanVien(widget.idNhanVienCongTrinh!,
          kyLuong: widget.kyLuong);
    });
  }

  void _openAddForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongFormDesktop(
          idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
          hoTen: widget.hoTen,
          tenCongTrinh: widget.congTrinh,
        ),
      ),
    ).then((_) => _reload());
  }

  void _openEditForm(Ungluong ul) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongFormDesktop(
          ul: ul,
          idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
          hoTen: widget.hoTen,
          tenCongTrinh: widget.congTrinh,
        ),
      ),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
              'Quản lý ứng lương ${widget.kyLuong ?? ''}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
      body: FutureBuilder<List<Ungluong>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final data = snapshot.data ?? [];
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth > 1400 ? 1400.0 : constraints.maxWidth;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildEmployeeInfo(),
                        const SizedBox(
                          height: 18,
                        ),
                        // Thống kê
                        _buildStatistics(
                          data,
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hoTen ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Text(
                        widget.congTrinh ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.only(
              right: 24,
            ),
            child: FilledButton.icon(
              onPressed: _openAddForm,
              icon: const Icon(
                Icons.add,
                size: 19,
              ),
              label: const Text('Thêm ứng lương'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  160,
                  42,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


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
            icon: Icons.receipt_long_outlined,
            title: 'Số lần ứng',
            value: '${data.length} lần',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Tổng tiền đã ứng',
            value: formatCurrency(total),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.money,
            title: 'Đã đối trừ',
            value: '0',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.money,
            title: 'Còn phải đối trừ',
            value: '0',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(10),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    List<Ungluong> data,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
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
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Text(
                  '${data.length} bản ghi',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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

  Widget _buildDesktopTable(
    List<Ungluong> data,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 900,
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 62,
          dataRowMaxHeight: 72,
          horizontalMargin: 20,
          columnSpacing: 28,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B5563),
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
              label: Text('Đối trừ'),
            ),
            DataColumn(
              label: Text('Còn lại'),
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
                  DataCell(
                    Text(
                      '${(index + 1).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ), //STT
                  // Ngày ứng
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey.shade500,
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
                  ), // Ngày
                  // Số tiền
                  DataCell(
                    Text(
                      formatCurrency(
                        ul.soTien ?? 0,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ), // Số tiền
                  // Số tiền đã trừ
                  DataCell(
                    Text(
                      formatCurrency(ul.soTienDaTru ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text(
                              'Chi tiết đối trừ ứng lương',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: SizedBox(
                              width: 500,
                              child: (ul.lstDoiTru ?? []).isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text('Chưa có khoản đối trừ'),
                                    )
                                  : ListView.separated(
                                shrinkWrap: true,
                                itemCount: ul.lstDoiTru!.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, index) {
                                  final item = ul.lstDoiTru![index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        // STT
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),

                                        // Ngày
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Ngày đối trừ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                DateUtilsCore.formatDate(
                                                  item.ngayDoiTru.toString(),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Kỳ lương
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Kỳ lương',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${item.thang}/${item.nam}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Số tiền
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'Số tiền',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                formatCurrency(
                                                  item.soTienDoiTru ?? 0,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Đóng'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ), // Đã đối trừ
                  DataCell(
                    Text(
                      formatCurrency(
                        ul.conLai ?? 0,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  // THAO TÁC
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Xem',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UngLuongDetailDesktop(
                                  model: ul,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.remove_red_eye,
                            size: 20,
                          ),
                          color: Colors.blue,
                        ),
                        IconButton(
                          tooltip: 'Sửa',
                          onPressed:
                              daChotLuong ? null : () => _openEditForm(ul),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                          color: Colors.blue,
                        ),
                        IconButton(
                          tooltip: 'Xóa',
                          onPressed:
                              daChotLuong ? null : () => _deleteUngLuong(ul),
                          icon: const Icon(
                            Icons.delete_outline,
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

  Widget _noData() {
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 60,
          horizontal: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.money_off_outlined,
              size: 52,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'Tháng này ${widget.hoTen ?? ''} chưa ứng lương',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            if (!daChotLuong) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.add),
                label: const Text('Thêm khoản ứng đầu tiên'),
              ),
            ],
          ],
        ));
  }

  Future<void> _deleteUngLuong(Ungluong ul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa khoản ứng lương này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    try{
      if (confirm == true) {
        await _service.deleteUngLuong(ul.id!);
        await _reload();
        if (!mounted) return;
        showSuccessToast(context, "Đã xóa ứng lương");
      }
    }catch(e){
      if (!mounted) return;
      showErrorToast(context, e, "Lỗi:");
    }

  }
}
