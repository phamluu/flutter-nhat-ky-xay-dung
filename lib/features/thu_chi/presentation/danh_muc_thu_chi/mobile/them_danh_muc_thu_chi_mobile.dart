import 'package:flutter/material.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/services/danh_muc_thu_chi_service.dart';

class ThemDanhMucThuChiScreen extends StatefulWidget {
  final DanhMucThuChi? danhMuc;
  const ThemDanhMucThuChiScreen({super.key, this.danhMuc});

  @override
  State<ThemDanhMucThuChiScreen> createState() => _ThemDanhMucThuChiScreenState();
}

class _ThemDanhMucThuChiScreenState extends State<ThemDanhMucThuChiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _service = DanhMucThuChiService();

  @override
  void initState() {
    super.initState();
    if (widget.danhMuc != null) {
      _tenController.text = widget.danhMuc!.ten;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.danhMuc == null) {
      await _service.insert(DanhMucThuChi(ten: _tenController.text));
    } else {
      await _service.update(DanhMucThuChi(
        id: widget.danhMuc!.id,
        ten: _tenController.text,
      ));
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.danhMuc == null ? "Thêm danh mục" : "Sửa danh mục"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: "Tên danh mục"),
                validator: (val) =>
                val == null || val.isEmpty ? "Không được để trống" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Lưu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
