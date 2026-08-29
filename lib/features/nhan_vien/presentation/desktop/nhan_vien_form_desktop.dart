import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

import '../../data/services/nhan_vien_service.dart';
import '../../data/models/NhanVien.dart';

class NhanVienFormDesktop extends StatefulWidget {
  final NhanVien? nhanVien;

  const NhanVienFormDesktop({
    super.key,
    this.nhanVien,
  });

  @override
  State<NhanVienFormDesktop> createState() =>
      _NhanVienFormDesktopState();
}

class _NhanVienFormDesktopState
    extends State<NhanVienFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _sdtController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _ngaySinhController = TextEditingController();

  final _service = NhanVienService();

  bool _isSaving = false;

  bool get _isEdit => widget.nhanVien != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      final nv = widget.nhanVien!;

      _hoTenController.text = nv.hoTen ?? '';
      _emailController.text = nv.email ?? '';
      _sdtController.text = nv.soDienThoai ?? '';
      _diaChiController.text = nv.diaChi ?? '';

      if (nv.ngaySinh != null) {
        _ngaySinhController.text =
        nv.ngaySinh!.toIso8601String().split('T')[0];
      }
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _sdtController.dispose();
    _diaChiController.dispose();
    _ngaySinhController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    DateTime? ngaySinh;

    if (_ngaySinhController.text.trim().isNotEmpty) {
      try {
        ngaySinh = DateTime.parse(
          _ngaySinhController.text.trim(),
        );
      } catch (_) {
        _showError("Ngày sinh không hợp lệ");
        return;
      }
    }

    final nv = NhanVien(
      id: widget.nhanVien?.id,
      hoTen: _hoTenController.text.trim(),
      email: _emailController.text.trim(),
      soDienThoai: _sdtController.text.trim(),
      diaChi: _diaChiController.text.trim(),
      ngaySinh: ngaySinh,
    );

    try {
      setState(() {
        _isSaving = true;
      });

      if (_isEdit) {
        await _service.updateNhanVien(nv);
      } else {
        await _service.insertNhanVien(nv);
      }

      if (!mounted) return;
showSuccessToast(context, _isEdit
    ? "Cập nhật nhân viên thành công"
    : "Thêm nhân viên thành công");


      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
showErrorToast(context, e, "Không thể lưu nhân viên:");
    }
  }

  void _showError(String message) {
    showErrorToast(context, "",message);

  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();

    if (_ngaySinhController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(
          _ngaySinhController.text,
        );
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "Chọn ngày sinh",
      cancelText: "Hủy",
      confirmText: "Chọn",
    );

    if (picked == null) return;

    setState(() {
      _ngaySinhController.text =
      picked.toIso8601String().split('T')[0];
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: Text(
          _isEdit ? "Sửa nhân viên" : "Thêm nhân viên",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text("Lưu"),
            ),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 20),

                  _buildFormCard(),

                  const SizedBox(height: 20),

                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEdit
                  ? Icons.edit_outlined
                  : Icons.person_add_outlined,
              color: Colors.blue.shade700,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit
                      ? "Cập nhật thông tin nhân viên"
                      : "Thêm nhân viên mới",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _isEdit
                      ? "Chỉnh sửa thông tin của nhân viên trong hệ thống."
                      : "Nhập thông tin để tạo nhân viên mới.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
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
  // FORM CARD
  // ============================================================

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 9),
              const Text(
                "Thông tin nhân viên",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 700) {
                return _buildDesktopForm();
              }

              return _buildMobileForm();
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP FORM
  // ============================================================

  Widget _buildDesktopForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _hoTenController,
                label: "Họ tên",
                hint: "Nhập họ và tên",
                icon: Icons.person_outline,
                required: true,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: "Email",
                hint: "Nhập địa chỉ email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _sdtController,
                label: "Số điện thoại",
                hint: "Nhập số điện thoại",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: _buildDateField(),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildTextField(
          controller: _diaChiController,
          label: "Địa chỉ",
          hint: "Nhập địa chỉ",
          icon: Icons.location_on_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE / SMALL FORM
  // ============================================================

  Widget _buildMobileForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _hoTenController,
          label: "Họ tên",
          hint: "Nhập họ và tên",
          icon: Icons.person_outline,
          required: true,
        ),

        const SizedBox(height: 18),

        _buildTextField(
          controller: _emailController,
          label: "Email",
          hint: "Nhập địa chỉ email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        _buildTextField(
          controller: _sdtController,
          label: "Số điện thoại",
          hint: "Nhập số điện thoại",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 18),

        _buildDateField(),

        const SizedBox(height: 18),

        _buildTextField(
          controller: _diaChiController,
          label: "Địa chỉ",
          hint: "Nhập địa chỉ",
          icon: Icons.location_on_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),

        filled: true,
        fillColor: const Color(0xfffafafa),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),

      validator: required
          ? (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return "$label không được để trống";
        }

        return null;
      }
          : null,
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    return TextFormField(
      controller: _ngaySinhController,
      readOnly: true,
      onTap: _selectDate,

      decoration: InputDecoration(
        labelText: "Ngày sinh",
        hintText: "Chọn ngày sinh",
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
        ),

        suffixIcon: IconButton(
          onPressed: _selectDate,
          icon: const Icon(
            Icons.date_range_outlined,
          ),
        ),

        filled: true,
        fillColor: const Color(0xfffafafa),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION
  // ============================================================

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text("Hủy"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 15,
            ),
          ),
        ),

        const SizedBox(width: 12),

        FilledButton.icon(
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
              : const Icon(Icons.save_outlined),
          label: Text(
            _isSaving
                ? "Đang lưu..."
                : (_isEdit ? "Cập nhật" : "Lưu nhân viên"),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }
}