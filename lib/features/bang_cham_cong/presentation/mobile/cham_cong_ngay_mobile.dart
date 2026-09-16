import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/cham_cong_chi_tiet.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/cham_cong_chi_tiet_repo.dart';

import '../../../../core/enum/feature_enum.dart';
import '../../../../core/services/PermissionManager.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../../../core/utils/trang_thai_cham_cong.dart';
import '../../data/models/ChamCongModel.dart';
import '../../widgets/radioCompact.dart';
import '../widgets/_attendanceStatus.dart';
import '../widgets/_desktopCard.dart';
import '../widgets/_infoBox.dart';
import '../widgets/_salaryItem.dart';
import '../widgets/statusColor.dart';

class ChamCongNgayMobile extends StatefulWidget {
  final int? id;
  final int? idNhanVienCongTrinh;
  final int? idBangChamCong;
  final int? idCongTrinh;
  final String? ngay;
  final String? hoTen;
  final String? tenCongTrinh;
  final int? idPhienChot;
  final bool daKhoa;
  const ChamCongNgayMobile({
    super.key,
    this.id,
    this.idNhanVienCongTrinh,
    this.idBangChamCong,
    this.idCongTrinh,
    this.ngay,
    this.hoTen,
    this.tenCongTrinh,
    this.idPhienChot,
    required this.daKhoa,
  });
  @override
  State<ChamCongNgayMobile> createState() => _ChamCongNgayMobileState();
}
class _ChamCongNgayMobileState extends State<ChamCongNgayMobile> {
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
    await PermissionManager.instance.runWithPermission(
        context,
        feature: FeatureEnum.chamCongNgay,
        action: () async {
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
            showSuccessToast(context, "Lưu chấm công thành công");
            Navigator.of(context).pop(true);
            // await _load();
          } catch (e) {
            if (!mounted) return;
            setState(() {
              isSaving = false;
            });
            showErrorToast(context, e, "Không thể lưu chấm công");

          }
        }
    );
  }
  // ============================================================
  // ERROR
  // ============================================================
  void _showError(String message) {
    if (!mounted) return;
    showWarmToast(context, message: message);

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
                data == null? _buildEmptyAttendanceCard() : _buildAttendanceCard(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.hoTen?.trim().isNotEmpty == true
                      ? widget.hoTen!
                      : "Nhân viên",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildLockStatus(),
            ],
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

              Expanded(
                child: Text(
                  widget.tenCongTrinh?.trim().isNotEmpty == true
                      ? widget.tenCongTrinh!
                      : "---",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            widget.idPhienChot != null ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 17,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            widget.idPhienChot != null ? "Đã khóa" : "Chưa khóa",
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

  Widget _buildAttendanceCard() {
    final cc = data!.chamCong;
    return desktopCard(
      title: "Chấm công",
      icon: Icons.access_time_outlined,
      iconColor: Colors.green,
      headerAction: widget.idPhienChot != null ? _lockedLabel() : TextButton.icon(
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
              child: attendanceStatus(
                title: "Buổi sáng",
                value: cc.sang.label,
                icon: Icons.wb_sunny_outlined,
                status: cc.sang,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: attendanceStatus(
                title: "Buổi chiều",
                value: cc.chieu.label,
                icon: Icons.wb_twilight_outlined,
                status: cc.chieu,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        infoBox(
          icon: Icons.short_text,
          title: "Ký hiệu",
          value: cc.hienThi,
        ),
        const SizedBox(height: 10),
        infoBox(
          icon: Icons.calculate_outlined,
          title: "Công",
          value: cc.soCong.toString(),
          valueColor: Colors.blue.shade700,
        ),
        const SizedBox(height: 10),
        infoBox(
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
    required ValueChanged<TrangThaiChamCong?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            // Sử dụng List.unmodifiable để tránh tạo mảng mới và leak render ở Release
            children: List<Widget>.unmodifiable(
              TrangThaiChamCong.values.map(
                    (e) => KeyedSubtree(
                  key: ValueKey(e), // Thêm Key để Flutter định danh chính xác ở Release
                  child: radioCompact(
                    value: e,
                    groupValue: groupValue,
                    onChanged: (val) {
                      if (groupValue != val) {
                        onChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAttendanceCard() {
    return desktopCard(
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

    return desktopCard(
      title: "Thông tin tiền công",
      icon: Icons.payments_outlined,
      iconColor: Colors.green,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 160,
            child: salaryItem(
              title: "Lương ngày",
              value: formatCurrency(data!.luongNgay),
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          SizedBox(
            width: 160,
            child: salaryItem(
              title: "Tiền công",
              value: formatCurrency(data!.tienCongNgay),
              icon: Icons.payments_outlined,
              valueColor: Colors.green.shade700,
            ),
          ),
          SizedBox(
            width: 160,
            child: salaryItem(
              title: "Công",
              value: data!.chamCong.soCong.toString(),
              icon: Icons.calculate_outlined,
              valueColor: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================



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

}