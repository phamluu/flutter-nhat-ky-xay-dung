import 'package:flutter/material.dart';

import '../../core/utils/trang_thai_tien_do.dart';
import 'data/models/TienDoCongTrinhModel.dart';
import 'data/repositories/TienDoRepository.dart';
import 'data/services/TienDoService.dart';

class TienDoFormScreen extends StatefulWidget {
  final int idCongTrinh;
  final TienDoCongTrinhModel? model;

  const TienDoFormScreen({
    super.key,
    required this.idCongTrinh,
    this.model,
  });

  @override
  State<TienDoFormScreen> createState() => _TienDoFormScreenState();
}

class _TienDoFormScreenState extends State<TienDoFormScreen> {
  final service = TienDoService(TienDoRepository());

  final _tenCtrl = TextEditingController();
  final _phanTramCtrl = TextEditingController();
  final _moTaCtrl = TextEditingController();
  final _ngayBatDauCtrl = TextEditingController();
  final _ngayKetThucCtrl = TextEditingController();
  final _trongSoCtrl = TextEditingController();
  int _trangThai = 0;

  @override
  void initState() {
    super.initState();

    if (widget.model != null) {
      final m = widget.model!;
      _tenCtrl.text = m.tenCongViec;
      _phanTramCtrl.text = (m.phanTramThucTe ?? 0).toString();
      _moTaCtrl.text = m.moTa ?? "";
      _ngayBatDauCtrl.text = m.ngayBatDau ?? "";
      _ngayKetThucCtrl.text = m.ngayKetThuc ?? "";
      _trongSoCtrl.text = (m.trongSo ?? 1).toString();
      _trangThai = m.trangThai ?? 0;
    }
  }

  void save() async {
    final model = TienDoCongTrinhModel(
      id: widget.model?.id,
      idCongTrinh: widget.idCongTrinh,
      tenCongViec: _tenCtrl.text,
      moTa: _moTaCtrl.text,
      ngayBatDau: _ngayBatDauCtrl.text,
      ngayKetThuc: _ngayKetThucCtrl.text,
      phanTramThucTe: double.tryParse(_phanTramCtrl.text) ?? 0,
      trongSo: double.tryParse(_trongSoCtrl.text) ?? 1,
      trangThai: _trangThai,
    );
    await service.save(model);
    Navigator.pop(context);
  }
  Future<void> pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split("T").first;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm/Sửa tiến độ")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _tenCtrl,
                decoration: const InputDecoration(labelText: "Tên công việc",
                  border: OutlineInputBorder(),),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Nhập tên' : null,
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _moTaCtrl,
                decoration: const InputDecoration(
                  labelText: "Mô tả",
                  border: OutlineInputBorder(),),
              ),
              const SizedBox(height: 10),
              /// Ngày bắt đầu
              TextFormField(
                controller: _ngayBatDauCtrl,
                readOnly: true,
                onTap: () => pickDate(_ngayBatDauCtrl),
                decoration: const InputDecoration(labelText: "Ngày bắt đầu", border: OutlineInputBorder(),),
              ),
              const SizedBox(height: 10),
              /// Ngày kết thúc
              TextFormField(
                controller: _ngayKetThucCtrl,
                readOnly: true,
                onTap: () => pickDate(_ngayKetThucCtrl),
                decoration: const InputDecoration(labelText: "Ngày kết thúc", border: OutlineInputBorder(),),
              ),
              const SizedBox(height: 10),
              /// % tiến độ
              TextFormField(
                controller: _phanTramCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "% tiến độ", border: OutlineInputBorder(),),
                validator: (value) {
                  final v = double.tryParse(value ?? "");
                  if (v == null) return "Nhập số hợp lệ";
                  if (v < 0 || v > 100) return "Chỉ từ 0 đến 100";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              /// Trọng số
              TextFormField(
                controller: _trongSoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Trọng số", border: OutlineInputBorder(),),
              ),

              const SizedBox(height: 10),

              /// Trạng thái
              DropdownButtonFormField<TrangThaiTienDo>(
                value: TrangThaiTienDo.fromValue(_trangThai),
                items: TrangThaiTienDo.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _trangThai = value?.value ?? 0;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Trạng thái",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: save,
                child: const Text("Lưu",),
              )
            ],
          ),
        ),
      ),
    );
  }
}