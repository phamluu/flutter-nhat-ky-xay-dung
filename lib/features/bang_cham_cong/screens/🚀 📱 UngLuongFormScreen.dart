import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/services/ung_luong_service.dart';
import '../../../data/models/UngLuong.dart';

class UngLuongFormScreen extends StatefulWidget {
  final Ungluong? ul;
  final int? idNhanVienCongTrinh;
  final String? tenCongTrinh;
  final String? hoTen;
  const UngLuongFormScreen({
    Key? key,
    this.ul,
    this.idNhanVienCongTrinh,
    this.tenCongTrinh,
    this.hoTen
  }) : super(key: key);

  @override
  State<UngLuongFormScreen> createState() => _UngLuongFormScreenState();
}

class _UngLuongFormScreenState extends State<UngLuongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UngLuongService();

  final soTienCtrl = TextEditingController();
  final ngayCtrl = TextEditingController();
  final lyDoCtrl = TextEditingController();

  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.ul != null) {
      soTienCtrl.text = widget.ul!.soTien?.toString() ?? "";
      lyDoCtrl.text = widget.ul!.lyDo ?? "";

      if (widget.ul!.ngayUng != null) {
        selectedDate = widget.ul!.ngayUng;
        ngayCtrl.text =
            DateFormat('dd/MM/yyyy').format(widget.ul!.ngayUng!);
      }
    } else {
      selectedDate = DateTime.now();
      ngayCtrl.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
    }
  }

  @override
  void dispose() {
    soTienCtrl.dispose();
    ngayCtrl.dispose();
    lyDoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        ngayCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final model = Ungluong(
      id: widget.ul?.id,
      idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
      soTien: double.tryParse(soTienCtrl.text) ?? 0,
      ngayUng: selectedDate,
      lyDo: lyDoCtrl.text,
    );

    try {
      if (widget.ul == null) {
        await _service.addUngLuong(model);
      } else {
        await _service.updateUngLuong(model);
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu thành công"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ul != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa ứng lương" : "Thêm ứng lương"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
        Column(
          children: [
            Text('xx'),
            Form(
              key: _formKey,
              child: ListView(
                children: [
                  // 💰 Số tiền
                  TextFormField(
                    controller: soTienCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số tiền",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nhập số tiền";
                      }
                      if (double.tryParse(value) == null) {
                        return "Số tiền không hợp lệ";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 📅 Ngày
                  TextFormField(
                    controller: ngayCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Ngày",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
                  // 📝 Lý do
                  TextFormField(
                    controller: lyDoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Lý do",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔘 Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEdit ? "Cập nhật" : "Lưu"),
                    ),
                  )
                ],
              ),
            ),
          ],
        )

      ),
    );
  }
}