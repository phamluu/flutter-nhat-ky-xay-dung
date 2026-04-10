import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';

class CongTrinhFormScreen extends StatefulWidget {
  final CongTrinh? congTrinh;

  const CongTrinhFormScreen({super.key, this.congTrinh});

  @override
  State<CongTrinhFormScreen> createState() => _CongTrinhFormScreenState();
}

class _CongTrinhFormScreenState extends State<CongTrinhFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CongTrinhService();

  final _tenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _moTaController = TextEditingController();
  final _ngayBatDauController = TextEditingController();
  final _ngayKetThucController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  bool get isEdit => widget.congTrinh != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final ct = widget.congTrinh!;
      _tenController.text = ct.ten ?? '';
      _diaChiController.text = ct.diaChi ?? '';
      _moTaController.text = ct.moTa ?? '';
      _ngayBatDauController.text = ct.ngayBatDau ?? '';
      _ngayKetThucController.text = ct.ngayKetThuc ?? '';
    }
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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final model = CongTrinh(
      id: widget.congTrinh?.id,
      ten: _tenController.text,
      diaChi: _diaChiController.text,
      moTa: _moTaController.text,
      ngayBatDau: _ngayBatDauController.text,
      ngayKetThuc: _ngayKetThucController.text,
      hinhAnh: _imageFile?.path ?? widget.congTrinh?.hinhAnh,
    );

    try {
      if (isEdit) {
        await _service.updateCongTrinh(model);
      } else {
        await _service.themCongTrinh(model);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? "Cập nhật thành công"
              : "Thêm công trình thành công"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, height: 150);
    }

    if (isEdit &&
        widget.congTrinh!.hinhAnh != null &&
        widget.congTrinh!.hinhAnh!.isNotEmpty) {
      return Image.file(
        File(widget.congTrinh!.hinhAnh!),
        height: 150,
      );
    }

    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.add_a_photo, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa công trình" : "Thêm công trình"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(
                  labelText: "Tên công trình",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nhập tên công trình' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ngayBatDauController,
                decoration:
                const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ngayKetThucController,
                decoration:
                const InputDecoration(
                    labelText: 'Ngày kết thúc',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: _buildImage(),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn hình'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Cập nhật' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}