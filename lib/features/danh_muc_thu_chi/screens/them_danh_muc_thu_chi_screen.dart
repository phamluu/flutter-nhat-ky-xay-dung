import 'package:flutter/material.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../services/danh_muc_thu_chi_service.dart';
import '../../../services/thu_chi_service.dart';

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

  void _delete() async {
    if (widget.danhMuc == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: const Text('Bạn chắc chắn muốn xóa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final inUse = await ThuChiService().countByDanhMuc(widget.danhMuc!.id!);
    if (inUse > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa: đang có $inUse khoản thu/chi dùng danh mục này')),
      );
      return;
    }

    await _service.delete(widget.danhMuc!.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.danhMuc == null ? "Thêm danh mục" : "Sửa danh mục"),
        actions: [
          if (widget.danhMuc != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
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
                child: const Text("Lưu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
