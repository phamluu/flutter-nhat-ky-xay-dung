import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/cham_cong_chi_tiet.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';

import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../data/repositories/ChamCongRepository.dart';
import '../../data/services/cham_cong_service.dart';
import '../../data/models/ChamCongModel.dart';
import '../../widgets/radioCompact.dart';

class ChamCongNgayDesktop extends StatefulWidget {
  final int? id;
  final int? idNhanVienCongTrinh;
  final int? idBangChamCong;
  final int? idCongTrinh;
  final String? ngay;
  final String? hoTen;
  final String? tenCongTrinh;
  final bool daKhoa;
  const ChamCongNgayDesktop({
    super.key,
    this.id,
    this.idNhanVienCongTrinh,
    this.idBangChamCong,
    this.idCongTrinh,
    this.ngay,
    this.hoTen,
    this.tenCongTrinh,
    required this.daKhoa,
  });
  @override
  State<ChamCongNgayDesktop> createState() =>
      _ChamCongNgayDesktopState();
}
class _ChamCongNgayDesktopState extends State<ChamCongNgayDesktop> {
  late final ChamCongChiTietRepo _repo;
  final TextEditingController ghiChuCtrl = TextEditingController();
  ChamCongNgayLuong? data;
  bool isLoading = true;
  bool isSaving = false;
  TrangThaiChamCong? _sang;
  TrangThaiChamCong? _chieu;
  bool _isEdit = false;
  @override
  void initState() {
    super.initState();
    _repo = ChamCongChiTietRepo();
    _load();
  }
  @override
  void dispose() {
    ghiChuCtrl.dispose();
    super.dispose();
  }
  Future<void> _load() async {
    if (widget.idNhanVienCongTrinh == null || widget.ngay == null || widget.idBangChamCong == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      final result = await _repo.getChamCongNgayLuongForNhanVien(idBangChamCong: widget.idBangChamCong,
          idNhanVienCongTrinh: widget.idNhanVienCongTrinh, ngay: widget.ngay);
      if (!mounted) return;
      setState(() {
        data = result;
        isLoading = false;
        if (result != null) {
          _sang = result.chamCong.sang;
          _chieu = result.chamCong.chieu;
          ghiChuCtrl.text =
              result.chamCong.ghiChu ?? "";
        } else {
          _sang = null;
          _chieu = null;
          ghiChuCtrl.clear();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showError(
        "Không thể tải dữ liệu chấm công: $e",
      );
    }
  }
  Future<void> _save() async {
    if (widget.idNhanVienCongTrinh == null || widget.ngay == null || widget.idBangChamCong == null) {
      return;
    }
    if (_sang == null && _chieu == null) {
      _showError("Bạn chưa chọn trạng thái chấm công.");
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      UpsertChamCongNgayParam param = UpsertChamCongNgayParam(
        idChamCongNgay: widget.id,
        idBangChamCong: widget.idBangChamCong,
        idCongTrinh: widget.idCongTrinh,
        idNhanVienCongTrinh: widget.idNhanVienCongTrinh ?? 0,
        ngay: widget.ngay ?? '',
        trangThaiSang: _sang?.value,
        trangThaiChieu: _chieu?.value,
        ghiChu: ghiChuCtrl.text.trim()
      );
      await _repo.upsertChamCong(param);
      if (!mounted) return;
      setState(() {
        _isEdit = false;
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lưu chấm công thành công",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
      _showError(
        "Không thể lưu chấm công: $e",
      );
    }
  }
  // ============================================================
  // ERROR
  // ============================================================
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              24,
              28,
              40,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildMainContent(),
                const SizedBox(height: 20),
                _buildSalaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      // backgroundColor: Colors.white,
      // foregroundColor: Colors.black87,
      centerTitle: false,
      titleSpacing: 24,
      title: const Text(
        "Chi tiết chấm công",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: Colors.blue.shade700,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hoTen?.trim().isNotEmpty == true
                      ? widget.hoTen!
                      : "Nhân viên",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 6),

                    Flexible(
                      child: Text(
                        widget.tenCongTrinh
                            ?.trim()
                            .isNotEmpty ==
                            true
                            ? widget.tenCongTrinh!
                            : "---",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      widget.ngay ?? "---",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          _buildLockStatus(),
        ],
      ),
    );
  }

  Widget _buildLockStatus() {
    final color = widget.daKhoa? Colors.red.shade700 : Colors.green.shade700;
    final background = widget.daKhoa ? Colors.red.withOpacity(.08) : Colors.green.withOpacity(.08);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.daKhoa
                ? Icons.lock_outline
                : Icons.lock_open_outlined,
            size: 17,
            color: color,
          ),

          const SizedBox(width: 7),

          Text(
            widget.daKhoa
                ? "Đã khóa"
                : "Chưa khóa",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded( flex: 4, child: _buildInformationCard(),),
        const SizedBox(width: 20),
        Expanded(
          flex: 7,
          child: data == null? _buildEmptyAttendanceCard() : _buildAttendanceCard(),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return _desktopCard(
      title: "Thông tin",
      icon: Icons.person_outline,
      iconColor: Colors.blue,
      child: Column(
        children: [
          _infoRow(
            icon: Icons.business_outlined,
            label: "Công trình",
            value:
            widget.tenCongTrinh ?? "---",
          ),
          const Divider(height: 24),
          _infoRow(
            icon: Icons.person_outline,
            label: "Họ tên",
            value:
            widget.hoTen ?? "---",
          ),
          const Divider(height: 24),
          _infoRow(
            icon: Icons.calendar_today_outlined,
            label: "Ngày",
            value:
            widget.ngay ?? "---",
          ),
          const Divider(height: 24),
          _infoRow(
            icon: Icons.lock_outline,
            label: "Trạng thái",
            value: widget.daKhoa
                ? "Đã khóa chấm công"
                : "Đang mở chấm công",
            valueColor: widget.daKhoa
                ? Colors.red.shade700
                : Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final cc = data!.chamCong;
    return _desktopCard(
      title: "Chấm công",
      icon: Icons.access_time_outlined,
      iconColor: Colors.green,
      headerAction: widget.daKhoa ? _lockedLabel() : TextButton.icon(
        onPressed: isSaving ? null : _toggleEdit,
        icon: Icon( _isEdit ? Icons.close : Icons.edit_outlined, size: 17, ),
        label: Text( _isEdit  ? "Hủy" : "Cập nhật", ),
      ),
      child: _isEdit ? _buildEditAttendance() : _buildViewAttendance(cc),
    );
  }

  Widget _buildViewAttendance( dynamic cc, ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _attendanceStatus(
                title: "Buổi sáng",
                value: cc.sang.label,
                icon: Icons.wb_sunny_outlined,
                status: cc.sang,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _attendanceStatus(
                title: "Buổi chiều",
                value: cc.chieu.label,
                icon: Icons.wb_twilight_outlined,
                status: cc.chieu,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _infoBox(
          icon: Icons.short_text,
          title: "Ký hiệu",
          value: cc.hienThi,
        ),
        const SizedBox(height: 10),
        _infoBox(
          icon: Icons.calculate_outlined,
          title: "Công",
          value: cc.soCong.toString(),
          valueColor: Colors.blue.shade700,
        ),
        const SizedBox(height: 10),
        _infoBox(
          icon: Icons.notes_outlined,
          title: "Ghi chú",
          value: ghiChuCtrl.text.isEmpty
              ? "Không có ghi chú"
              : ghiChuCtrl.text,
        ),
      ],
    );
  }

  Widget _buildEditAttendance() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildAttendanceSelector(
          title: "Buổi sáng",
          icon: Icons.wb_sunny_outlined,
          groupValue: _sang,
          onChanged: (value) {
            setState(() {
              _sang = value;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildAttendanceSelector(
          title: "Buổi chiều",
          icon: Icons.wb_twilight_outlined,
          groupValue: _chieu,
          onChanged: (value) {
            setState(() {
              _chieu = value;
            });
          },
        ),
        const SizedBox(height: 24),
        const Text(
          "Ghi chú",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ghiChuCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
            "Nhập ghi chú nếu có...",
            prefixIcon: const Padding(
              padding: EdgeInsets.only(
                bottom: 45,
              ),
              child: Icon(
                Icons.notes_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
            ),
            filled: true,
            fillColor:
            Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: isSaving ? null  : () {
                setState(() {
                  _isEdit = false;
                  if (data != null) {
                    _sang = data!.chamCong.sang;
                    _chieu = data!.chamCong.chieu;
                    ghiChuCtrl.text = data!.chamCong.ghiChu ?? "";
                  }
                });
              },
              child: const Text("Hủy"),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: isSaving ? null : _save,
              icon: isSaving ? const SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
                size: 18,
              ),
              label: Text(
                isSaving ? "Đang lưu...": "Lưu chấm công",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.green.shade700,
                foregroundColor:
                Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ATTENDANCE SELECTOR
  // ============================================================

  Widget _buildAttendanceSelector({
    required String title,
    required IconData icon,
    required TrangThaiChamCong? groupValue,
    required ValueChanged<
        TrangThaiChamCong?>
    onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
            TrangThaiChamCong.values
                .map(
                  (e) {
                return radioCompact(
                  value: e,
                  groupValue:
                  groupValue,
                  onChanged:
                  onChanged,
                );
              },
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDANCE STATUS
  // ============================================================

  Widget _attendanceStatus({
    required String title,
    required String value,
    required IconData icon,
    required TrangThaiChamCong status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _statusColor(status)
            .withOpacity(.07),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: _statusColor(status)
              .withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _statusColor(status)
                  .withOpacity(.12),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: _statusColor(status),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 14,
                    color:
                    _statusColor(status),
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
  // EMPTY ATTENDANCE
  // ============================================================

  Widget _buildEmptyAttendanceCard() {
    return _desktopCard(
      title: "Chấm công",
      icon: Icons.access_time_outlined,
      iconColor: Colors.orange,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.orange
                  .withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pending_actions_outlined,
              color: Colors.orange.shade700,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Chưa có dữ liệu chấm công",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            widget.daKhoa
                ? "Ngày này đã khóa nên không thể thêm chấm công."
                : "Chưa có dữ liệu cho ngày này. Hãy nhập chấm công.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          if (!widget.daKhoa) ...[
            const SizedBox(height: 20),
            _buildNewAttendanceForm(),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // NEW ATTENDANCE FORM
  // ============================================================

  Widget _buildNewAttendanceForm() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildAttendanceSelector(
          title: "Buổi sáng",
          icon: Icons.wb_sunny_outlined,
          groupValue: _sang,
          onChanged: (value) {
            setState(() {
              _sang = value;
            });
          },
        ),

        const SizedBox(height: 18),

        _buildAttendanceSelector(
          title: "Buổi chiều",
          icon: Icons.wb_twilight_outlined,
          groupValue: _chieu,
          onChanged: (value) {
            setState(() {
              _chieu = value;
            });
          },
        ),

        const SizedBox(height: 18),

        const Text(
          "Ghi chú",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: ghiChuCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
            "Nhập ghi chú nếu có...",
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
            ),
            filled: true,
            fillColor:
            Colors.grey.shade50,
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
            isSaving ? null : _save,
            icon: isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.save_outlined,
            ),
            label: Text(
              isSaving
                  ? "Đang lưu..."
                  : "Lưu chấm công",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Colors.green.shade700,
              foregroundColor:
              Colors.white,
              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SALARY CARD
  // ============================================================

  Widget _buildSalaryCard() {
    if (data == null) {
      return const SizedBox.shrink();
    }

    return _desktopCard(
      title: "Thông tin tiền công",
      icon: Icons.payments_outlined,
      iconColor: Colors.green,
      child: Row(
        children: [
          Expanded(
            child: _salaryItem(
              title: "Lương ngày",
              value:
              formatCurrency(
                data!.luongNgay,
              ),
              icon:
              Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _salaryItem(
              title: "Tiền công",
              value:
              formatCurrency(
                data!.tienCongNgay,
              ),
              icon:
              Icons.payments_outlined,
              valueColor:
              Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _salaryItem(
              title: "Công",
              value: data!.chamCong.soCong.toString(),
              icon:
              Icons.calculate_outlined,
              valueColor:
              Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SALARY ITEM
  // ============================================================

  Widget _salaryItem({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue
                  .withOpacity(.08),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
              valueColor ??
                  Colors.blue.shade700,
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
                    fontSize: 11,
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    valueColor,
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
  // DESKTOP CARD
  // ============================================================

  Widget _desktopCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? headerAction,
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor
                      .withOpacity(.10),
                  borderRadius:
                  BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              if (headerAction != null)
                headerAction,
            ],
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade500,
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
              color:
              valueColor ??
                  Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(9),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 9),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w700,
                color:
                valueColor ??
                    Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOCKED LABEL
  // ============================================================

  Widget _lockedLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.07),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 15,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            "Đã khóa",
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOGGLE EDIT
  // ============================================================

  void _toggleEdit() {
    setState(() {
      _isEdit = !_isEdit;

      if (_isEdit && data != null) {
        _sang = data!.chamCong.sang;
        _chieu = data!.chamCong.chieu;

        ghiChuCtrl.text =
            data!.chamCong.ghiChu ?? "";
      }
    });
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
      TrangThaiChamCong status,
      ) {
    switch (status) {
      case TrangThaiChamCong.coMat:
        return Colors.green.shade700;

      case TrangThaiChamCong.khongXacDinh:
        return Colors.orange.shade800;

      case TrangThaiChamCong.vang:
        return Colors.red.shade700;

      default:
        return Colors.grey.shade700;
    }
  }
}