import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/LuongCoBan.dart';
import '../../../data/repositories/luong_coban_repository.dart';
class LuongcobannhanvienformScreen extends StatefulWidget{
  final LuongCoBanNhanVienModel? luong;
  final int idNhanVien;
  final String? hoTen;
  const LuongcobannhanvienformScreen({
    Key? key,
    this.luong,
    required this.idNhanVien,
    this.hoTen
}) : super(key: key);

  @override
  State<LuongcobannhanvienformScreen> createState() => _LuongcobannhanvienformScreenState();
}
class _LuongcobannhanvienformScreenState extends State<LuongcobannhanvienformScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = LuongCoBanRepository();
  final soTienCtrl = TextEditingController();
  final ngayCtrl = TextEditingController();
  final ghiChuCtrl = TextEditingController();

  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.luong != null) {
      if (widget.luong!.soTien != null) {
        soTienCtrl.text = formatCurrency(widget.luong!.soTien!);
      }
      ghiChuCtrl.text = widget.luong!.ghiChu ?? "";

      if (widget.luong!.ngayApDung != null) {
        selectedDate = widget.luong!.ngayApDung;
        ngayCtrl.text =
            DateFormat('dd/MM/yyyy').format(widget.luong!.ngayApDung!);
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
    ghiChuCtrl.dispose();
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
    if (selectedDate == null) {
      showWarmToast(context, message: "Vui lòng chọn ngày");
      return;
    }
    setState(() => isLoading = true);
    final model = Luongcoban(
      idNhanVien: widget.idNhanVien,
      id: widget.luong?.id,
      mucLuong: parseCurrency(soTienCtrl.text),
      ngayApDung: selectedDate.toString(),
      ghiChu: ghiChuCtrl.text,
    );
    try {
      if (widget.luong == null) {
        await _repo.insert(model);
      } else {
        await _repo.update(model);
      }
      showSuccessToast(context, "Lưu thành công");
      Navigator.pop(context, true);
    } catch (e) {
      showErrorToast(context, e, "Lỗi: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEdit = widget.luong != null;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(isEdit ? "Sửa lương cơ bản" : "Thêm lương cơ bản"),
            Text(
              widget.hoTen ?? "",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body:
      SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _form(context)
      ),
    );
  }

  Widget _form(BuildContext context){
    final isEdit = widget.luong != null;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 💰 Số tiền
          TextFormField(
            controller: soTienCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // chỉ cho nhập số
              CurrencyInputFormatter(), // format tiền
            ],
            decoration: InputDecoration(
              labelText: "Lương/ ngày",
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Nhập số tiền";
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
              labelText: "Ngày áp dụng",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          // 📝 Lý do
          TextFormField(
            controller: ghiChuCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Ghi chú",
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
    );
  }
}