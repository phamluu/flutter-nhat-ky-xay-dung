import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/services/cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_service.dart';

import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../services/nhan_vien_cong_trinh_service.dart';

class NhanVienCongTrinhFormScreen extends StatefulWidget {
  final NhanVienCongTrinh? item;
  const NhanVienCongTrinhFormScreen({super.key, this.item});

  @override
  State<NhanVienCongTrinhFormScreen> createState() => _NhanVienCongTrinhFormScreenState();
}

class _NhanVienCongTrinhFormScreenState extends State<NhanVienCongTrinhFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaiTroController = TextEditingController();
  final _ngayBatDauController = TextEditingController();
  final _ngayKetThucController = TextEditingController();

  final _service = NhanVienCongTrinhService();
  final _nhanvienservice = NhanVienService();
  final _congtrinhservice = CongTrinhService();
  List<Map<String, dynamic>> _nhanViens = [];
  List<Map<String, dynamic>> _conTrinhs = [];

  int? _selectedNhanVienId;
  int? _selectedCongTrinhId;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final nvs = await _nhanvienservice.getAllNhanVien();
    final cts = await _congtrinhservice.getDanhSachCongTrinh();

    setState(() {
      _nhanViens = nvs.cast<Map<String, dynamic>>();
      _conTrinhs = cts.cast<Map<String, dynamic>>();

      if (widget.item != null) {
        _selectedNhanVienId = widget.item!.idNhanVien;
        _selectedCongTrinhId = widget.item!.idCongTrinh;
        _vaiTroController.text = widget.item!.vaiTro ?? '';
        _ngayBatDauController.text = widget.item!.ngayBatDau ?? '';
        _ngayKetThucController.text = widget.item!.ngayKetThuc ?? '';
      } else {
        if (_nhanViens.isNotEmpty) _selectedNhanVienId = _nhanViens.first['id'] as int;
      }
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNhanVienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhân viên')),
      );
      return;
    }

    final obj = NhanVienCongTrinh(
      id: widget.item?.id,
      idNhanVien: _selectedNhanVienId!,
      idCongTrinh: _selectedCongTrinhId,
      vaiTro: _vaiTroController.text.isEmpty ? null : _vaiTroController.text,
      ngayBatDau: _ngayBatDauController.text.isEmpty ? null : _ngayBatDauController.text,
      ngayKetThuc: _ngayKetThucController.text.isEmpty ? null : _ngayKetThucController.text,
    );

    if (widget.item == null) {
      await _service.insert(obj);
    } else {
      await _service.update(obj);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa NV-CT' : 'Thêm NV-CT')),
      body: _nhanViens.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedNhanVienId,
                items: _nhanViens
                    .map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['ten'])))
                    .toList(),
                onChanged: (v) => setState(() => _selectedNhanVienId = v),
                decoration: const InputDecoration(labelText: 'Nhân viên'),
                validator: (v) => v == null ? 'Chọn nhân viên' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _selectedCongTrinhId,
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Chọn công trình')),
                  ..._conTrinhs.map((e) =>
                      DropdownMenuItem<int?>(value: e['id'] as int?, child: Text(e['ten'])))
                ],
                onChanged: (v) => setState(() => _selectedCongTrinhId = v),
                decoration: const InputDecoration(labelText: 'Công trình (tùy chọn)'),
              )
              ,
              const SizedBox(height: 8),
              TextFormField(
                controller: _vaiTroController,
                decoration: const InputDecoration(labelText: 'Vai trò'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ngayBatDauController,
                readOnly: true,
                onTap: () => _pickDate(_ngayBatDauController),
                decoration: const InputDecoration(
                  labelText: 'Ngày bắt đầu',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ngayKetThucController,
                readOnly: true,
                onTap: () => _pickDate(_ngayKetThucController),
                decoration: const InputDecoration(
                  labelText: 'Ngày kết thúc',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}
