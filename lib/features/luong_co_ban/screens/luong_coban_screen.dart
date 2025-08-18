import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/LuongCoBan.dart';
import '../../../data/models/NhanVien.dart';
import '../../../services/luong_co_ban_service.dart';
import '../../../services/nhan_vien_service.dart';
class LuongCoBanScreen extends StatefulWidget {
  const LuongCoBanScreen({super.key});

  @override
  State<LuongCoBanScreen> createState() => _LuongCoBanScreenState();
}

class _LuongCoBanScreenState extends State<LuongCoBanScreen> {
  final LuongCoBanService _service = LuongCoBanService();
  final NhanVienService _nhanVienService = NhanVienService();
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  List<Luongcoban> _luongs = [];
  List<NhanVien> _nhanViens = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dsLuong = await _service.getAllLuongCoBan();
    final dsNhanVien = await _nhanVienService.getAllNhanVien();
    setState(() {
      _luongs = dsLuong;
      _nhanViens = dsNhanVien;
    });
  }

  Future<void> _showForm({Luongcoban? luong}) async {
    final mucLuongController =
    TextEditingController(text: luong?.mucLuong?.toString() ?? "");
    final ngayApDungController = TextEditingController(
        text: luong?.ngayApDung != null
            ? DateFormat("dd/MM/yyyy").format(luong!.ngayApDung!)
            : "");
    final ghiChuController = TextEditingController(text: luong?.ghiChu ?? "");

    NhanVien? selectedNhanVien = luong?.nhanVien;
    DateTime? ngayApDung = luong?.ngayApDung;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(luong == null ? "Thêm lương cơ bản" : "Sửa lương cơ bản"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<NhanVien>(
                value: selectedNhanVien,
                decoration: const InputDecoration(labelText: "Nhân viên"),
                items: _nhanViens
                    .map((nv) => DropdownMenuItem(
                  value: nv,
                  child: Text(nv.hoTen ?? "Không tên"),
                ))
                    .toList(),
                onChanged: (nv) {
                  setState(() => selectedNhanVien = nv);
                },
              ),
              TextField(
                controller: mucLuongController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Mức lương"),
              ),
              TextField(
                controller: ngayApDungController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Ngày áp dụng"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: ngayApDung ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      ngayApDung = picked;
                      ngayApDungController.text =
                          DateFormat("dd/MM/yyyy").format(picked);
                    });
                  }
                },
              ),
              TextField(
                controller: ghiChuController,
                decoration: const InputDecoration(labelText: "Ghi chú"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (selectedNhanVien == null) return;

              final mucLuong = double.tryParse(mucLuongController.text) ?? 0;

              final newLuong = Luongcoban(
                id: luong?.id,
                idNhanVien: selectedNhanVien!.id!,
                mucLuong: mucLuong,
                ngayTao: DateTime.now(),
                ngayApDung: ngayApDung,
                ghiChu: ghiChuController.text,
                nhanVien: selectedNhanVien,
              );

              if (luong == null) {
                await _service.addLuongCoBan(newLuong);
              } else {
                await _service.updateLuongCoBan(newLuong);
              }

              Navigator.pop(context);
              _loadData();
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  Future<void> _delete(int id) async {
    await _service.deleteLuongCoBan(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Lương cơ bản"),
      ),
      body: ListView.builder(
        itemCount: _luongs.length,
        itemBuilder: (context, index) {
          final luong = _luongs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text("${luong.nhanVien?.hoTen ?? "Không tên"}"),
              subtitle: Text(
                "Mức lương: ${currencyFormat.format(luong.mucLuong ?? 0)}\n"
                    "Ngày áp dụng: ${luong.ngayApDung != null ? DateFormat("dd/MM/yyyy").format(luong.ngayApDung!) : "Chưa có"}\n"
                    "Ghi chú: ${luong.ghiChu ?? ""}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(luong: luong)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(luong.id!)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
