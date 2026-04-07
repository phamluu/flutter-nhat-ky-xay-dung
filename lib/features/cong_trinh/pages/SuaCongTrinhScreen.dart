import 'package:flutter/material.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
class SuaCongTrinhScreen extends StatefulWidget {
  final CongTrinh congTrinh;

  const SuaCongTrinhScreen({super.key, required this.congTrinh});

  @override
  State<SuaCongTrinhScreen> createState() => _SuaCongTrinhScreenState();
}

class _SuaCongTrinhScreenState extends State<SuaCongTrinhScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CongTrinhService();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
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
      hinhAnh: _imageFile?.path ?? widget.congTrinh.hinhAnh,
    );

    try {
      await _service.updateCongTrinh(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu công trình thành công", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật: $e', style: const TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
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
              const SizedBox(height: 12),

              // Hình ảnh
              const SizedBox(height: 12),

// Hiển thị ảnh
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : (widget.congTrinh.hinhAnh != null &&
                    widget.congTrinh.hinhAnh!.isNotEmpty)
                    ? Image.file(
                  File(widget.congTrinh.hinhAnh!),
                  height: 150,
                )
                    : Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.add_a_photo, size: 40),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn hình'),
              ),
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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }
}
