
// Màn hình thêm công trình
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';

class ThemCongTrinhScreen extends StatefulWidget {
  const ThemCongTrinhScreen({super.key});

  @override
  State<ThemCongTrinhScreen> createState() => _ThemCongTrinhScreenState();
}

class _ThemCongTrinhScreenState extends State<ThemCongTrinhScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _moTaController = TextEditingController();
  final _ngayBatDauController = TextEditingController();
  final _ngayKetThucController = TextEditingController();
  final _service = CongTrinhService();

  @override
  void dispose() {
    _tenController.dispose();
    _diaChiController.dispose();
    _moTaController.dispose();
    _ngayBatDauController.dispose();
    _ngayKetThucController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final congTrinh = CongTrinh(
        ten: _tenController.text,
        diaChi: _diaChiController.text,
        moTa: _moTaController.text,
        ngayBatDau: _ngayBatDauController.text,
        ngayKetThuc: _ngayKetThucController.text,
      );
      await _service.themCongTrinh(congTrinh);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công trình')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên công trình'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nhập tên công trình' : null,
              ),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
              ),
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextFormField(
                controller: _ngayBatDauController,
                decoration: const InputDecoration(labelText: 'Ngày bắt đầu (yyyy-MM-dd)'),
              ),
              TextFormField(
                controller: _ngayKetThucController,
                decoration: const InputDecoration(labelText: 'Ngày kết thúc (yyyy-MM-dd)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Lưu'),
              )
            ],
          ),
        ),
      ),
    );
  }
}