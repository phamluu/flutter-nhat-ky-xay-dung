import 'package:flutter/material.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/models/ThuChi.dart';
import '../../../services/danh_muc_thu_chi_service.dart';
import '../../../services/thu_chi_service.dart';

class ThemThuChiScreen extends StatefulWidget {
  final ThuChi? thuChi;
  const ThemThuChiScreen({super.key, this.thuChi});

  @override
  State<ThemThuChiScreen> createState() => _ThemThuChiScreenState();
}

class _ThemThuChiScreenState extends State<ThemThuChiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _soTienController = TextEditingController();
  final _ghiChuController = TextEditingController();
  final _ngayController = TextEditingController();

  final _thuChiService = ThuChiService();
  final _dmService = DanhMucThuChiService();

  int _loai = 0; // 0: chi, 1: thu
  List<DanhMucThuChi> _danhMucs = [];
  int? _selectedDanhMucId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final dms = await _dmService.getAll();
    setState(() => _danhMucs = dms);

    if (widget.thuChi != null) {
      _soTienController.text = widget.thuChi!.soTien.toString();
      _ghiChuController.text = widget.thuChi!.ghiChu ?? "";
      _ngayController.text = widget.thuChi!.ngay;
      _loai = widget.thuChi!.loai;
      _selectedDanhMucId = widget.thuChi!.idDanhMucThuChi;
    } else {
      _ngayController.text = DateTime.now().toIso8601String();
      if (_danhMucs.isNotEmpty) _selectedDanhMucId = _danhMucs.first.id;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_ngayController.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _ngayController.text = picked.toIso8601String();
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDanhMucId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    final tc = ThuChi(
      id: widget.thuChi?.id,
      idDanhMucThuChi: _selectedDanhMucId!,
      loai: _loai,
      soTien: double.parse(_soTienController.text),
      ghiChu: _ghiChuController.text.isEmpty ? null : _ghiChuController.text,
      ngay: _ngayController.text,
      idCongTrinh: widget.thuChi?.idCongTrinh,
      ngayTao: widget.thuChi?.ngayTao ?? DateTime.now().toIso8601String(),
    );

    if (widget.thuChi == null) {
      await _thuChiService.insert(tc);
    } else {
      await _thuChiService.update(tc);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (widget.thuChi?.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khoản thu/chi?'),
        content: const Text('Bạn chắc chắn muốn xóa khoản này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await _thuChiService.delete(widget.thuChi!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.thuChi != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa thu chi" : "Thêm thu chi"),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            )
        ],
      ),
      body: _danhMucs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _loai,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Chi")),
                  DropdownMenuItem(value: 1, child: Text("Thu")),
                ],
                onChanged: (v) => setState(() => _loai = v!),
                decoration: const InputDecoration(labelText: "Loại"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedDanhMucId,
                items: _danhMucs
                    .map((dm) => DropdownMenuItem(
                  value: dm.id,
                  child: Text(dm.ten),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDanhMucId = v),
                decoration: const InputDecoration(labelText: "Danh mục"),
                validator: (v) => v == null ? 'Chọn danh mục' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _soTienController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Số tiền"),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập số tiền';
                  final parsed = double.tryParse(v);
                  if (parsed == null) return 'Số tiền không hợp lệ';
                  if (parsed < 0) return 'Số tiền phải >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ghiChuController,
                decoration: const InputDecoration(labelText: "Ghi chú"),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ngayController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: "Ngày",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Chọn ngày' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text("Lưu")),
            ],
          ),
        ),
      ),
    );
  }
}
