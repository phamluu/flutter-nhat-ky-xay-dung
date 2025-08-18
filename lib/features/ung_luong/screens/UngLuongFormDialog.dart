import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/NhanVien.dart';
import '../../../data/models/UngLuong.dart';

class UngLuongFormDialog extends StatefulWidget {
  final Ungluong? ungLuong;
  final List<NhanVien> nhanViens;
  final Function(Ungluong) onSave;

  const UngLuongFormDialog({
    Key? key,
    this.ungLuong,
    required this.nhanViens,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UngLuongFormDialog> createState() => _UngLuongFormDialogState();
}

class _UngLuongFormDialogState extends State<UngLuongFormDialog> {
  NhanVien? selectedNhanVien;
  final TextEditingController soTienController = TextEditingController();
  final TextEditingController ngayUngController = TextEditingController();
  final TextEditingController lyDoController = TextEditingController();
  DateTime? ngayUng;

  @override
  void initState() {
    super.initState();
    selectedNhanVien = widget.ungLuong?.nhanVien;
    soTienController.text = widget.ungLuong?.soTien?.toString() ?? '';
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
              onChanged: (nv) => setState(() => selectedNhanVien = nv),
            ),
            TextField(
              controller: soTienController,
              decoration: const InputDecoration(labelText: 'Số tiền ứng'),
              keyboardType: TextInputType.number,
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

            final soTien = double.tryParse(soTienController.text) ?? 0;

            final newUngLuong = Ungluong(
              id: widget.ungLuong?.id,
              idNhanVien: selectedNhanVien!.id!,
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
