import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/data/services/nhan_vien_service.dart';

import '../../../../../core/utils/date_utils.dart';
import '../../../../nhan_vien/data/models/NhanVien.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../data/respositories/CongTrinhReponsitory.dart' show CongtrinhReponsitory;
import '../../../data/services/nhan_vien_cong_trinh_service.dart';


class NhanVienCongTrinhFormScreen extends StatefulWidget {
  final NhanVienCongTrinh? item;
  final int? idCongTrinh;
  const NhanVienCongTrinhFormScreen({super.key, this.item, this.idCongTrinh});

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
  final _congtrinhservice = CongtrinhReponsitory();

  List<NhanVien> _nhanViens = [];
  List<CongTrinh> _conTrinhs = [];

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
      _nhanViens = nvs;
      _conTrinhs = cts;

      if (widget.item != null) {
        _selectedNhanVienId = widget.item!.idNhanVien;
        _selectedCongTrinhId = widget.item!.idCongTrinh;
        _vaiTroController.text = widget.item!.vaiTro ?? '';
        _ngayBatDauController.text = widget.item!.ngayBatDau ?? '';
        _ngayKetThucController.text = widget.item!.ngayKetThuc ?? '';
      } else {
        _selectedCongTrinhId = widget.idCongTrinh;
        if (_nhanViens.isNotEmpty) _selectedNhanVienId = _nhanViens.first.id;
      }
    });
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNhanVienId == null) {
        showWarmToast(context, message: 'Vui lòng chọn nhân viên');
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
      appBar: AppBar(
          title: Text(isEdit ? 'Sửa Nhân viên Công Trình' : 'Thêm Nhân viên vào công trình'),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _nhanViens.isEmpty
          ? const Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Chưa có nhân viên, hãy thêm nhân viên trước'),
            )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: 
          ListView(
            children: [
              // Dropdown nhân viên
              DropdownButtonFormField<int>(
                value: _selectedNhanVienId,
                items: _nhanViens
                    .map((nv) => DropdownMenuItem(
                  value: nv.id,
                  child: Text(nv.hoTen ?? "Không tên"),
                ))
                    .toList(),
                onChanged: (v) => setState(() =>
                _selectedNhanVienId = v),
                decoration: const InputDecoration(labelText: 'Nhân viên'),
                validator: (v) => v == null ? 'Chọn nhân viên' : null,
              ),
              const SizedBox(height: 8),

              // Dropdown công trình
              DropdownButtonFormField<int?>(
                value: _selectedCongTrinhId,
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Chọn công trình')),
                  ..._conTrinhs.map((ct) =>
                      DropdownMenuItem<int?>(value: ct.id, child: Text(ct.ten ?? "Không tên")))
                ],
                onChanged: widget.idCongTrinh != null
                    ? null
                    : (v) => setState(() => _selectedCongTrinhId = v),
                decoration: const InputDecoration(labelText: 'Công trình (tùy chọn)'),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _vaiTroController,
                decoration: const InputDecoration(labelText: 'Vai trò'),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _ngayBatDauController,
                readOnly: true,
                onTap: () => DateUtilsCore.pickDate(context, _ngayBatDauController, format: "dd/MM/yyyy"),
                decoration: const InputDecoration(
                  labelText: 'Ngày bắt đầu',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _ngayKetThucController,
                readOnly: true,
                onTap: () => DateUtilsCore.pickDate(context, _ngayKetThucController, format: "dd/MM/yyyy"),
                decoration: const InputDecoration(
                  labelText: 'Ngày kết thúc',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}

