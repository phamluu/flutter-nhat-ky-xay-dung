import 'package:flutter/material.dart';
import '../../data/models/NhanVien.dart';
import '../../data/services/nhan_vien_service.dart';

class ThemSuaNhanVienScreen extends StatefulWidget {
  final NhanVien? nhanVien;

  const ThemSuaNhanVienScreen({super.key, this.nhanVien});

  @override
  State<ThemSuaNhanVienScreen> createState() => _ThemSuaNhanVienScreenState();
}

class _ThemSuaNhanVienScreenState extends State<ThemSuaNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _sdtController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _ngaySinhController = TextEditingController();

  final _service = NhanVienService();

  @override
  void initState() {
    super.initState();
    if (widget.nhanVien != null) {
      _hoTenController.text = widget.nhanVien!.hoTen ?? '';
      _emailController.text = widget.nhanVien!.email ?? '';
      _sdtController.text = widget.nhanVien!.soDienThoai ?? '';
      _diaChiController.text = widget.nhanVien!.diaChi ?? '';
      _ngaySinhController.text = widget.nhanVien!.ngaySinh != null
          ? widget.nhanVien!.ngaySinh!.toIso8601String().split('T')[0]
          : '';
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nv = NhanVien(
      id: widget.nhanVien?.id,
      hoTen: _hoTenController.text,
      email: _emailController.text,
      soDienThoai: _sdtController.text,
      diaChi: _diaChiController.text,
      ngaySinh: _ngaySinhController.text.isNotEmpty
          ? DateTime.parse(_ngaySinhController.text)
          : null,
    );

    if (widget.nhanVien == null) {
      await _service.insertNhanVien(nv);
    } else {
      await _service.updateNhanVien(nv);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.nhanVien == null ? "Thêm nhân viên" : "Sửa nhân viên"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hoTenController,
                decoration: const InputDecoration(labelText: "Họ tên"),
                validator: (val) =>
                val == null || val.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _sdtController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
              ),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(labelText: "Địa chỉ"),
              ),
              TextFormField(
                controller: _ngaySinhController,
                decoration: const InputDecoration(labelText: "Ngày sinh"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Lưu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
