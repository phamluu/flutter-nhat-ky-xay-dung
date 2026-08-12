import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/services/luong_co_ban_service.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/data/services/nhan_vien_service.dart';
import '../../../data/models/LuongCoBan.dart';
import '../../nhan_vien/data/models/NhanVien.dart';

class LuongCoBanFormScreen extends StatefulWidget {
  final Luongcoban? luong;
  const LuongCoBanFormScreen({
    super.key,
    this.luong,
  });

  @override
  State<LuongCoBanFormScreen> createState() => _LuongCoBanFormDialogState();
}

class _LuongCoBanFormDialogState extends State<LuongCoBanFormScreen> {
  late TextEditingController mucLuongController;
  late TextEditingController ngayApDungController;
  late TextEditingController ghiChuController;
  NhanVien? selectedNhanVien;
  DateTime? ngayApDung;

  NhanVienService _nhanVienService = NhanVienService();
  LuongCoBanService _service = LuongCoBanService();
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  late List<NhanVien> nhanViens = [];
  @override
  void initState() {
    super.initState();
    mucLuongController = TextEditingController(
      text: widget.luong?.mucLuong != null
          ? currencyFormat.format(widget.luong!.mucLuong!)
          : "",
    );
    ngayApDungController = TextEditingController(
      text: widget.luong?.ngayApDung != null
          ? DateFormat("dd/MM/yyyy").format(widget.luong!.ngayApDung!)
          : "",
    );
    ghiChuController = TextEditingController(text: widget.luong?.ghiChu ?? "");
    selectedNhanVien = widget.luong?.nhanVien;
    ngayApDung = widget.luong?.ngayApDung;
    _loadNhanVien();
  }
  Future<void> _loadNhanVien() async {
    final data = await _nhanVienService.getAllNhanVien(); // chờ Future
    setState(() {
      nhanViens = data;
    });
  }
  @override
  void dispose() {
    mucLuongController.dispose();
    ngayApDungController.dispose();
    ghiChuController.dispose();
    super.dispose();
  }

  // Hàm parse giá trị tiền từ text có format
  double _parseCurrency(String text) {
    final cleaned = text.replaceAll(RegExp(r'[.,]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.luong == null
            ? "Thêm lương cơ bản"
            : "Sửa lương cơ bản"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NhanVien>(
              value: selectedNhanVien,
              decoration: const InputDecoration(labelText: "Nhân viên"),
              items: nhanViens
                  .map((nv) => DropdownMenuItem(
                value: nv,
                child: Text(nv.hoTen ?? "Không tên"),
              ))
                  .toList(),
              onChanged: (nv) => setState(() => selectedNhanVien = nv),
            ),
            TextField(
              controller: mucLuongController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Mức lương"),
              onChanged: (value) {
                String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.isEmpty) cleaned = '0';
                final number = int.parse(cleaned);
                final formatted = currencyFormat.format(number);
                mucLuongController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
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
      // actions: [
      //   TextButton(
      //       onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
      //   ElevatedButton(
      //     onPressed: () {
      //       if (selectedNhanVien == null) return;
      //       final mucLuong = _parseCurrency(mucLuongController.text);
      //       final newLuong = Luongcoban(
      //         id: widget.luong?.id,
      //         idNhanVien: selectedNhanVien!.id!,
      //         mucLuong: mucLuong,
      //         ngayApDung: ngayApDung,
      //         ghiChu: ghiChuController.text,
      //         nhanVien: selectedNhanVien,
      //       );
      //       widget.onSave(newLuong);
      //       Navigator.pop(context);
      //     },
      //     child: const Text("Lưu"),
      //   ),
      // ],
    );
  }

  Future<void> _save() async {
    if (selectedNhanVien == null) return;

    final mucLuong = _parseCurrency(mucLuongController.text);

    final newLuong = Luongcoban(
      id: widget.luong?.id,
      idNhanVien: selectedNhanVien!.id!,
      mucLuong: mucLuong,
      ngayApDung: ngayApDung,
      ghiChu: ghiChuController.text,
      nhanVien: selectedNhanVien,
    );

    try {
      if (widget.luong == null) {
        await _service.addLuongCoBan(newLuong);
      } else {
        await _service.updateLuongCoBan(newLuong);
      }

      Navigator.pop(context, true); // trả về reload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }
}
