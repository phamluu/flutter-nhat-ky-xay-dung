import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nhat_ky_xay_dung/features/cong_trinh/data/models/CongTrinh.dart';

import '../../../../cong_trinh/data/respositories/CongTrinhReponsitory.dart';
import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/models/ThuChi.dart';
import '../../../data/services/danh_muc_thu_chi_service.dart';
import '../../../data/services/thu_chi_service.dart';


class ThuChiFormDesktop extends StatefulWidget {
  final ThuChi? thuChi;
  final int? idCongTrinh;

  const ThuChiFormDesktop({
    super.key,
    this.thuChi,
    this.idCongTrinh,
  });

  @override
  State<ThuChiFormDesktop> createState() => _ThuChiFormDesktopState();
}

class _ThuChiFormDesktopState extends State<ThuChiFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _soTienController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _ngayController = TextEditingController();

  final _thuChiService = ThuChiService();

  final _dmService = DanhMucThuChiService();

  final _ctService = CongtrinhReponsitory();

  final _dateFormat = DateFormat("dd/MM/yyyy");

  int _loai = 0;

  List<DanhMucThuChi> _danhMucs = [];
  int? _selectedDanhMucId;

  List<CongTrinh> _conTrinhs = [];
  int? _selectedCongTrinhId;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _soTienController.dispose();
    _ghiChuController.dispose();
    _ngayController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _initData() async {
    try {
      final dms = await _dmService.getAll();
      final cts = await _ctService.getDanhSachCongTrinh();

      if (!mounted) return;

      setState(() {
        _danhMucs = dms;
        _conTrinhs = cts;

        if (widget.thuChi != null) {
          final tc = widget.thuChi!;

          _soTienController.text = tc.soTien.toString();

          _ghiChuController.text = tc.ghiChu ?? '';

          try {
            _ngayController.text = _dateFormat.format(
              DateTime.parse(tc.ngay),
            );
          } catch (_) {
            _ngayController.text = _dateFormat.format(
              DateTime.now(),
            );
          }

          _loai = tc.loai;

          _selectedDanhMucId = tc.idDanhMucThuChi;

          _selectedCongTrinhId = tc.idCongTrinh;
        } else {
          _selectedCongTrinhId = widget.idCongTrinh;

          _ngayController.text = _dateFormat.format(
            DateTime.now(),
          );

          if (_danhMucs.isNotEmpty) {
            _selectedDanhMucId = _danhMucs.first.id;
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BACK
  // ============================================================

  void _goBack() {
    Navigator.pop(context);
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _pickDate() async {
    final now = DateTime.now();

    DateTime initial;

    try {
      final parts = _ngayController.text.split('/');

      initial = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        _ngayController.text = _dateFormat.format(picked);
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateParts = _ngayController.text.split('/');

    final tcDate = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );

    final soTien = double.tryParse(
      _soTienController.text
          .replaceAll(',', '')
          .replaceAll('.', ''),
    );

    if (soTien == null) {
      return;
    }

    final tc = ThuChi(
      id: widget.thuChi?.id,
      idDanhMucThuChi: _selectedDanhMucId,
      loai: _loai,
      soTien: soTien,
      ghiChu: _ghiChuController.text.isEmpty
          ? null
          : _ghiChuController.text.trim(),
      ngay: tcDate.toIso8601String(),
      idCongTrinh: _selectedCongTrinhId,
      ngayTao: widget.thuChi?.ngayTao ??
          DateTime.now().toIso8601String(),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.thuChi == null) {
        await _thuChiService.insert(tc);
      } else {
        await _thuChiService.update(tc);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lưu khoản thu chi thất bại: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _delete() async {
    if (widget.thuChi?.id == null) {
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khoản thu/chi?'),
        content: const Text(
          'Bạn chắc chắn muốn xóa khoản này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _thuChiService.delete(
        widget.thuChi!.id!,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa: $e'),
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
    final isEdit = widget.thuChi != null;

    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isEdit),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _buildForm(isEdit),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(bool isEdit) {
    return Row(
      children: [


        // ==============================
        // TITLE
        // ==============================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? 'Sửa khoản thu chi'
                    : 'Thêm khoản thu chi',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.idCongTrinh != null
                    ? 'Khoản thu chi của công trình'
                    : 'Nhập thông tin khoản thu hoặc chi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // ==============================
        // DELETE
        // ==============================

        if (isEdit)
          OutlinedButton.icon(
            onPressed: _delete,
            icon: const Icon(
              Icons.delete_outline,
              size: 19,
            ),
            label: const Text('Xóa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(
                color: Colors.red,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

        const SizedBox(width: 10),
        // Quay lại
        // ==============================
        // NÚT QUAY LẠI
        // ==============================

        Tooltip(
          message: 'Quay lại',
          child: InkWell(
            onTap: _goBack,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 21,
                color: Color(0xff37474f),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ==============================
        // ICON
        // ==============================

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _loai == 1
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit
                ? Icons.edit_outlined
                : Icons.receipt_long_outlined,
            color: _loai == 1
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        ),

        const SizedBox(width: 12),
        // ==============================
        // SAVE
        // ==============================

        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 19,
          ),
          label: Text(
            _isSaving ? 'Đang lưu...' : 'Lưu',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
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

  // ============================================================
  // FORM
  // ============================================================

  Widget _buildForm(bool isEdit) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            children: [
              _buildMainCard(),

              const SizedBox(height: 16),

              _buildNoteCard(),

              const SizedBox(height: 16),

              _buildDateCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CARD
  // ============================================================

  Widget _buildMainCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Thông tin khoản thu chi',
          ),

          const SizedBox(height: 20),

          const Text(
            'Loại giao dịch',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _typeButton(
                  value: 0,
                  title: 'Khoản chi',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _typeButton(
                  value: 1,
                  title: 'Khoản thu',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDanhMucField(),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildCongTrinhField(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildAmountField(),
        ],
      ),
    );
  }

  // ============================================================
  // TYPE BUTTON
  // ============================================================

  Widget _typeButton({
    required int value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final selected = _loai == value;

    return InkWell(
      onTap: () {
        setState(() {
          _loai = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? color
                    : Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? color
                    : Colors.grey.shade700,
              ),
            ),

            const Spacer(),

            if (selected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DANH MỤC
  // ============================================================

  Widget _buildDanhMucField() {
    return DropdownButtonFormField<int?>(
      value: _danhMucs.any(
            (dm) => dm.id == _selectedDanhMucId,
      )
          ? _selectedDanhMucId
          : null,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text(
            'Không chọn danh mục',
          ),
        ),
        ..._danhMucs.map(
              (dm) => DropdownMenuItem<int?>(
            value: dm.id,
            child: Text(dm.ten),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedDanhMucId = value;
        });
      },
      decoration: _inputDecoration(
        label: 'Danh mục',
        icon: Icons.category_outlined,
      ),
    );
  }

  // ============================================================
  // CÔNG TRÌNH
  // ============================================================

  Widget _buildCongTrinhField() {
    final disabled = widget.idCongTrinh != null;

    return DropdownButtonFormField<int?>(
      value: _conTrinhs.any(
            (ct) => ct.id == _selectedCongTrinhId,
      )
          ? _selectedCongTrinhId
          : null,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text(
            'Chọn công trình',
          ),
        ),
        ..._conTrinhs.map(
              (ct) => DropdownMenuItem<int?>(
            value: ct.id,
            child: Text(
              ct.ten,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: disabled
          ? null
          : (value) {
        setState(() {
          _selectedCongTrinhId = value;
        });
      },
      decoration: _inputDecoration(
        label: 'Công trình',
        icon: Icons.business_outlined,
      ),
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountField() {
    return TextFormField(
      controller: _soTienController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      decoration: _inputDecoration(
        label: 'Số tiền',
        icon: Icons.payments_outlined,
        suffix: const Text('₫'),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập số tiền';
        }

        final parsed = double.tryParse(
          value
              .replaceAll(',', '')
              .replaceAll('.', ''),
        );

        if (parsed == null) {
          return 'Số tiền không hợp lệ';
        }

        if (parsed < 0) {
          return 'Số tiền phải >= 0';
        }

        return null;
      },
    );
  }

  // ============================================================
  // NOTE
  // ============================================================

  Widget _buildNoteCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.notes_outlined,
            title: 'Ghi chú',
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: _ghiChuController,
            maxLines: 4,
            decoration: _inputDecoration(
              label: 'Nội dung ghi chú',
              icon: Icons.description_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.calendar_month_outlined,
            title: 'Thời gian',
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: 420,
            child: TextFormField(
              controller: _ngayController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _inputDecoration(
                label: 'Ngày giao dịch',
                icon: Icons.event_outlined,
                suffix: const Icon(
                  Icons.calendar_today_outlined,
                  size: 19,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng chọn ngày';
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff263238),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xfffafafa),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.blue.shade600,
          width: 1.5,
        ),
      ),
    );
  }
}