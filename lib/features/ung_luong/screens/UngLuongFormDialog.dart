import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';

import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/NhanVien.dart';
import '../../../data/models/UngLuong.dart';

class UngLuongFormDialog extends StatefulWidget {
  final Ungluong? ungLuong;
  final List<NhanVien> nhanViens;
  final List<NhanVienCongTrinh>? nhanVienCongTrinhs;
  final Function(Ungluong) onSave;

  const UngLuongFormDialog({
    super.key,
    this.ungLuong,
    required this.nhanViens,
    this.nhanVienCongTrinhs,
    required this.onSave,
  });

  @override
  State<UngLuongFormDialog> createState() => _UngLuongFormDialogState();
}

class _UngLuongFormDialogState extends State<UngLuongFormDialog> {
  NhanVien? selectedNhanVien;
  NhanVienCongTrinh? selectedNhanVienCongTrinh;
  late TextEditingController soTienController;
  final TextEditingController ngayUngController = TextEditingController();
  final TextEditingController lyDoController = TextEditingController();
  DateTime? ngayUng;
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");
  @override
  void initState() {
    super.initState();
    selectedNhanVien = widget.ungLuong?.nhanVien;
    selectedNhanVienCongTrinh = widget.ungLuong?.nhanVienCongTrinh;
    soTienController = TextEditingController(
      text: widget.ungLuong?.soTien != null
          ? currencyFormat.format(widget.ungLuong!.soTien!)
          : "",
    );
    lyDoController.text = widget.ungLuong?.lyDo ?? '';
    ngayUng = widget.ungLuong?.ngayUng;
    if (ngayUng != null) {
      ngayUngController.text = DateFormat('dd/MM/yyyy').format(ngayUng!);
    }
  }

  @override
  void dispose() {
    soTienController.dispose();
    ngayUngController.dispose();
    lyDoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // lọc công trình theo nhân viên được chọn
    final filteredCongTrinhs = widget.nhanVienCongTrinhs
        ?.where((nvct) => nvct.idNhanVien == selectedNhanVien?.id)
        .toList() ??
        [];

    final congTrinhItems = [
      const DropdownMenuItem<NhanVienCongTrinh?>(
        value: null,
        child: Text('Chưa chọn'),
      ),
      ...filteredCongTrinhs.map(
            (nvct) => DropdownMenuItem<NhanVienCongTrinh?>(
          value: nvct,
          child: Text(nvct.congTrinh?.ten ?? 'Không tên'),
        ),
      ),
    ];
    return AlertDialog(
      title: Text(widget.ungLuong == null ? "Thêm ứng lương" : "Sửa ứng lương"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NhanVien>(
              value: selectedNhanVien,
              decoration: const InputDecoration(labelText: 'Nhân viên'),
              items: widget.nhanViens
                  .map((nv) => DropdownMenuItem(
                value: nv,
                child: Text(nv.hoTen ?? 'Không tên'),
              ))
                  .toList(),
              onChanged: (nv) {
                setState(() {
                  selectedNhanVien = nv;
                  // reset công trình khi đổi nhân viên
                  selectedNhanVienCongTrinh = null;
                });
              },
            ),
            DropdownButtonFormField<NhanVienCongTrinh?>(
              value: congTrinhItems.any((item) => item.value == selectedNhanVienCongTrinh)
                  ? selectedNhanVienCongTrinh
                  : null,
              decoration: const InputDecoration(labelText: 'Công trình'),
              items: congTrinhItems,
              onChanged: (nvct) => setState(() => selectedNhanVienCongTrinh = nvct),
            ),
            TextField(
              controller: soTienController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số tiền ứng"),
              onChanged: (value) {
                String cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

                if (cleaned.isEmpty) {
                  soTienController.value = TextEditingValue(
                    text: '',
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                  return;
                }

                final number = int.parse(cleaned);
                final formatted = currencyFormat.format(number);

                soTienController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
            ),
            TextField(
              controller: ngayUngController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Ngày ứng'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: ngayUng ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    ngayUng = picked;
                    ngayUngController.text =
                        DateFormat('dd/MM/yyyy').format(picked);
                  });
                }
              },
            ),
            TextField(
              controller: lyDoController,
              decoration: const InputDecoration(labelText: 'Lý do'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedNhanVien == null) return;
            final soTien = parseCurrency(soTienController.text);

            final newUngLuong = Ungluong(
              id: widget.ungLuong?.id,
              idNhanVien: selectedNhanVien!.id!,
              idNhanVienCongTrinh: selectedNhanVienCongTrinh?.id,
              soTien: soTien,
              ngayUng: ngayUng,
              lyDo: lyDoController.text,
              nhanVien: selectedNhanVien,
            );

            widget.onSave(newUngLuong);
            Navigator.pop(context);
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}
