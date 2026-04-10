import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../data/models/NhatKy.dart';
import '../../../services/nhat_ky_service.dart';
import '../../../services/cong_trinh_service.dart';
import '../../../data/models/CongTrinh.dart';
import '../widgets/weather_dropdown.dart';

class ThemSuaNhatKyScreen extends StatefulWidget {
  final NhatKy? nhatKy;
  final int? idCongTrinh;
  const ThemSuaNhatKyScreen({super.key, this.nhatKy,  this.idCongTrinh,});

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

  List<File> _images = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCongTrinh();
    if (widget.nhatKy != null) {
      _loadImages();
      _tenController.text = widget.nhatKy!.tenNhatKy ?? '';
      _noiDungController.text = widget.nhatKy!.noiDung ?? '';
      _ngayTrienKhaiController.text = widget.nhatKy!.ngayTrienKhai ?? '';
      _thoiTietSang = widget.nhatKy!.thoiTietSang;
      _thoiTietChieu = widget.nhatKy!.thoiTietChieu;
      _selectedCongTrinhId = widget.nhatKy!.idCongTrinh;
    }else{
      _selectedCongTrinhId = widget.idCongTrinh;
    }
  }

  void _loadCongTrinh() async {
    _dsCongTrinh = await _congTrinhService.getDanhSachCongTrinh();
    if (mounted) setState(() {});
  }
  Future<void> _loadImages() async {
    final paths = await _nhatKyService.getImages(widget.nhatKy!.id!);
    setState(() {
      _images = paths.map((e) => File(e)).toList();
    });
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
    final imagePaths = _images.map((e) => e.path).toList();
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
      // hinhAnhList: imagePaths,
    );
    int nhatKyId;
    if (widget.nhatKy == null) {
      nhatKyId  = await _nhatKyService.insertNhatKy(nk);
    } else {
      if (nk.id == null) {
        throw Exception("ID nhật ký bị null khi update");
      }
      await _nhatKyService.updateNhatKy(nk);
      nhatKyId = nk.id!;
      await _nhatKyService.deleteImages(nk.id!);
    }
    if (imagePaths.isNotEmpty) {
      await _nhatKyService.insertImages(nhatKyId, imagePaths);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nhatKy == null ? "Thêm nhật ký" : "Sửa nhật ký"),
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
                    onChanged: widget.idCongTrinh != null
                        ? null
                        : (val) => setState(() => _selectedCongTrinhId = val),
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
                TextFormField(
                  controller: _noiDungController,
                  decoration: const InputDecoration(labelText: "Nội dung"),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hình ảnh",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library),
                        ),
                        IconButton(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 8),

                _buildImagePreview(),
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

  Future<void> _pickImages() async {
    if (_images.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 9 ảnh')),
      );
      return;
    }
    final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 60,);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll( pickedFiles.take(9 - _images.length).map((e) => File(e.path)),);
      });
    }
  }
  Future<void> _takePhoto() async {
    if (_images.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 9 ảnh')),
      );
      return;
    }
    final XFile? photo =
    await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }
  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: Text("Chưa có hình ảnh"),
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: _images.length > 9 ? 9 : _images.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      cacheExtent: 300,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: ResizeImage(
                  FileImage(_images[index]),
                  width: 200,
                  height: 200,
                ),
                fit: BoxFit.cover,
              )
            ),

            // ❌ nút xoá ảnh
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
