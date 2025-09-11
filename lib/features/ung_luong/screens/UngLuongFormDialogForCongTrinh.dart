import 'package:flutter/material.dart';

import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../data/models/UngLuong.dart';
import '../widgets/UngLuongFormFields.dart';

class UngLuongFormDialogForCongTrinh extends StatefulWidget {
  final Ungluong? ungLuong;
  final List<NhanVienCongTrinh> nhanVienCongTrinhs;
  final int idCongTrinh;
  final Future<void> Function(Ungluong) onSave;

  const UngLuongFormDialogForCongTrinh({
    Key? key,
    this.ungLuong,
    required this.nhanVienCongTrinhs,
    required this.idCongTrinh,
    required this.onSave,
  }) : super(key: key);

  @override
  _UngLuongFormDialogForCongTrinhState createState() =>
      _UngLuongFormDialogForCongTrinhState();
}

class _UngLuongFormDialogForCongTrinhState
    extends State<UngLuongFormDialogForCongTrinh> {
  NhanVienCongTrinh? selectedNvct;
  final TextEditingController soTienCtrl = TextEditingController();
  final TextEditingController lyDoCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedNvct =
        widget.nhanVienCongTrinhs
        .firstWhere((nvct) => nvct.id == widget.ungLuong?.idNhanVienCongTrinh,
        orElse: () => widget.nhanVienCongTrinhs.first);

    if (widget.ungLuong?.soTien != null)
      soTienCtrl.text = widget.ungLuong!.soTien.toString();
    if (widget.ungLuong?.lyDo != null) lyDoCtrl.text = widget.ungLuong!.lyDo!;
    selectedDate = widget.ungLuong?.ngayUng;
  }

  @override
  void dispose() {
    soTienCtrl.dispose();
    lyDoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNvct = widget.nhanVienCongTrinhs
        .where((nvct) => nvct.idCongTrinh == widget.idCongTrinh)
        .toList();

    return AlertDialog(
      title: Text(widget.ungLuong == null ? 'Thêm ứng lương' : 'Sửa ứng lương'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NhanVienCongTrinh>(
              value: selectedNvct,
              items: filteredNvct
                  .map((nvct) => DropdownMenuItem(
                value: nvct,
                child: Text(nvct.nhanVien?.hoTen ?? 'Không tên'),
              ))
                  .toList(),
              onChanged: (v) => setState(() => selectedNvct = v),
              decoration: const InputDecoration(labelText: 'Chọn nhân viên'),
            ),
            const SizedBox(height: 12),
            UngLuongFormFields(
              soTienCtrl: soTienCtrl,
              lyDoCtrl: lyDoCtrl,
              ngayUng: selectedDate,
              onSelectDate: (dt) => setState(() => selectedDate = dt),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            if (selectedNvct == null) return;
            final u = widget.ungLuong ??  Ungluong();
            u.idNhanVienCongTrinh  = selectedNvct!.id;
            u.idNhanVien = selectedNvct!.idNhanVien;
            u.soTien = double.tryParse(soTienCtrl.text) ?? 0;
            u.lyDo = lyDoCtrl.text;
            u.ngayUng = selectedDate;
            await widget.onSave(u);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Ứng lương thành công",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );

          },
          child: const Text('Lưu'),
        )
      ],
    );
  }
}
