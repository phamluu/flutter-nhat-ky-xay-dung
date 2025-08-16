import 'package:flutter/material.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';

class SuaCongTrinhScreen extends StatefulWidget {
  final CongTrinh congTrinh;

  const SuaCongTrinhScreen({super.key, required this.congTrinh});

  @override
  State<SuaCongTrinhScreen> createState() => _SuaCongTrinhScreenState();
}

class _SuaCongTrinhScreenState extends State<SuaCongTrinhScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CongTrinhService();

  late TextEditingController _tenController;
  late TextEditingController _diaChiController;
  late TextEditingController _moTaController;
  late TextEditingController _ngayBatDauController;
  late TextEditingController _ngayKetThucController;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController(text: widget.congTrinh.ten);
    _diaChiController = TextEditingController(text: widget.congTrinh.diaChi);
    _moTaController = TextEditingController(text: widget.congTrinh.moTa);
    _ngayBatDauController =
        TextEditingController(text: widget.congTrinh.ngayBatDau ?? '');
    _ngayKetThucController =
        TextEditingController(text: widget.congTrinh.ngayKetThuc ?? '');
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaChiController.dispose();
    _moTaController.dispose();
    _ngayBatDauController.dispose();
    _ngayKetThucController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.congTrinh.copyWith(
      ten: _tenController.text,
      diaChi: _diaChiController.text,
      moTa: _moTaController.text,
      ngayBatDau: _ngayBatDauController.text,
      ngayKetThuc: _ngayKetThucController.text,
    );

    try {
      await _service.updateCongTrinh(updated);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa công trình')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên công trình'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nhập tên công trình' : null,
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
                decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
              ),
              TextFormField(
                controller: _ngayKetThucController,
                decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
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
