import 'package:flutter/material.dart';
import '../../../data/models/NhatKy.dart';
import '../../../services/nhat_ky_service.dart';
import '../../../services/cong_trinh_service.dart';
import '../../../data/models/CongTrinh.dart';
import '../widgets/weather_dropdown.dart';

class ThemSuaNhatKyScreen extends StatefulWidget {
  final NhatKy? nhatKy;

  const ThemSuaNhatKyScreen({super.key, this.nhatKy});

  @override
  State<ThemSuaNhatKyScreen> createState() => _ThemSuaNhatKyScreenState();
}

class _ThemSuaNhatKyScreenState extends State<ThemSuaNhatKyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _noiDungController = TextEditingController();
  final _ngayTrienKhaiController = TextEditingController();

  final _nhatKyService = NhatKyService();
  final _congTrinhService = CongTrinhService();

  List<CongTrinh> _dsCongTrinh = [];
  int? _selectedCongTrinhId;
  int? _thoiTietSang;
  int? _thoiTietChieu;

  @override
  void initState() {
    super.initState();
    _loadCongTrinh();

    if (widget.nhatKy != null) {
      _tenController.text = widget.nhatKy!.tenNhatKy ?? '';
      _noiDungController.text = widget.nhatKy!.noiDung ?? '';
      _ngayTrienKhaiController.text = widget.nhatKy!.ngayTrienKhai ?? '';
      _selectedCongTrinhId = widget.nhatKy!.idCongTrinh;
      _thoiTietSang = widget.nhatKy!.thoiTietSang;
      _thoiTietChieu = widget.nhatKy!.thoiTietChieu;
    }
  }

  void _loadCongTrinh() async {
    _dsCongTrinh = await _congTrinhService.getDanhSachCongTrinh();
    if (mounted) setState(() {});
  }

  void _selectNgayTrienKhai() async {
    final initialDate = widget.nhatKy?.ngayTrienKhai != null
        ? DateTime.tryParse(widget.nhatKy!.ngayTrienKhai!)
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _ngayTrienKhaiController.text = date.toIso8601String().split('T').first;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCongTrinhId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn công trình')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final nk = NhatKy(
      id: widget.nhatKy?.id,
      tenNhatKy: _tenController.text,
      noiDung: _noiDungController.text,
      ngayTao: widget.nhatKy?.ngayTao ?? now,
      idCongTrinh: _selectedCongTrinhId!,
      ngayTrienKhai: _ngayTrienKhaiController.text.isNotEmpty
          ? _ngayTrienKhaiController.text
          : null,
      thoiTietSang: _thoiTietSang,
      thoiTietChieu: _thoiTietChieu,
    );

    if (widget.nhatKy == null) {
      await _nhatKyService.insertNhatKy(nk);
    } else {
      await _nhatKyService.updateNhatKy(nk);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nhatKy == null ? "Thêm nhật ký" : "Sửa nhật ký"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _tenController,
                  decoration: const InputDecoration(labelText: "Tên nhật ký"),
                  validator: (val) =>
                  val == null || val.isEmpty ? "Không được để trống" : null,
                ),
                TextFormField(
                  controller: _noiDungController,
                  decoration: const InputDecoration(labelText: "Nội dung"),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedCongTrinhId,
                  decoration: const InputDecoration(labelText: "Công trình"),
                  items: _dsCongTrinh
                      .map((ct) => DropdownMenuItem(
                    value: ct.id,
                    child: Text(ct.ten ?? 'Không tên'),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCongTrinhId = val),
                  validator: (val) =>
                  val == null ? "Vui lòng chọn công trình" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ngayTrienKhaiController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: "Ngày triển khai",
                      suffixIcon: Icon(Icons.calendar_today)),
                  onTap: _selectNgayTrienKhai,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildWeatherDropdown(
                        value: _thoiTietSang,
                        label: "Thời tiết sáng",
                        onChanged: (val) => setState(() => _thoiTietSang = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: buildWeatherDropdown(
                        value: _thoiTietChieu,
                        label: "Thời tiết chiều",
                        onChanged: (val) => setState(() => _thoiTietChieu = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text("Lưu"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
