import 'package:flutter/material.dart';

import '../../../data/models/NhanVien.dart';
import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../data/models/UngLuong.dart';
import '../widgets/UngLuongFormFields.dart';

class UngLuongFormDialogGeneral extends StatefulWidget {
  final Ungluong? ungLuong;
  final List<NhanVienCongTrinh> nhanVienCongTrinhs;
  final List<NhanVien> nhanViens;
  final Future<void> Function(Ungluong) onSave;

  const UngLuongFormDialogGeneral({
    Key? key,
    this.ungLuong,
    required this.nhanViens,
    required this.nhanVienCongTrinhs,
    required this.onSave,
  }) : super(key: key);

  @override
  _UngLuongFormDialogGeneralState createState() =>
      _UngLuongFormDialogGeneralState();
}

class _UngLuongFormDialogGeneralState
    extends State<UngLuongFormDialogGeneral> {
  NhanVienCongTrinh? selectedNhanVienCongTrinh;
  NhanVien? selectedNhanVien;
  List<NhanVienCongTrinh> nvctForSelectedCongTrinh = [];
  final TextEditingController soTienCtrl = TextEditingController();
  final TextEditingController lyDoCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedNhanVien = widget.ungLuong?.nhanVien;
    selectedNhanVienCongTrinh = widget.ungLuong?.nhanVienCongTrinh;
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
      title: Text(widget.ungLuong == null ? 'Thêm ứng lương' : 'Sửa ứng lương'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NhanVien>(
              value: selectedNhanVien,
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
              decoration: const InputDecoration(labelText: 'Chọn nhân viên'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<NhanVienCongTrinh?>(
              value: congTrinhItems.any((item) => item.value == selectedNhanVienCongTrinh)
                  ? selectedNhanVienCongTrinh
                  : null,
              decoration: const InputDecoration(labelText: 'Công trình'),
              items: congTrinhItems,
              onChanged: (nvct) => setState(() => selectedNhanVienCongTrinh = nvct),
            ),
            const SizedBox(height: 8),

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
            if (selectedNhanVien == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Vui lòng chọn nhân viên"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            try{
              final u = widget.ungLuong ?? Ungluong();
              u.idNhanVienCongTrinh = selectedNhanVienCongTrinh?.id;
              u.idNhanVien = selectedNhanVien!.id;
              u.soTien = double.tryParse(soTienCtrl.text) ?? 0;
              u.lyDo = lyDoCtrl.text;
              u.ngayUng = selectedDate;
              await widget.onSave(u);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lưu ứng lương thành công"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Lỗi khi lưu: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }

          },
          child: const Text('Lưu'),
        )
      ],
    );
  }
}
