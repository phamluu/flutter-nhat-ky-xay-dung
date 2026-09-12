import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';

import '../../../../../core/enum/feature_enum.dart';
import '../../../../../core/services/PermissionManager.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../data/models/NhatKyCongTrinh.dart';
import '../../../data/respositories/CongTrinhReponsitory.dart';
import '../../../data/services/nhat_ky_service.dart';
import '../widgets/weather_dropdown.dart';

class NhatKyFormDesktop extends StatefulWidget {
  final NhatKyCongTrinh? nhatKy;
  final int? idCongTrinh;

  const NhatKyFormDesktop({
    super.key,
    this.nhatKy,
    this.idCongTrinh,
  });

  @override
  State<NhatKyFormDesktop> createState() =>
      _NhatKyFormDesktopState();
}

class _NhatKyFormDesktopState
    extends State<NhatKyFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _tenController = TextEditingController();
  final _noiDungController = TextEditingController();
  final _ngayTrienKhaiController = TextEditingController();

  final _nhatKyService = NhatKyService();

  final _congTrinhService = CongtrinhReponsitory();

  final ImagePicker _picker = ImagePicker();

  List<CongTrinh> _dsCongTrinh = [];

  int? _selectedCongTrinhId;
  int? _thoiTietSang;
  int? _thoiTietChieu;

  List<File> _images = [];

  bool _isSaving = false;

  bool get isEdit => widget.nhatKy != null;

  @override
  void initState() {
    super.initState();

    _selectedCongTrinhId = widget.idCongTrinh;

    _loadCongTrinh();

    if (widget.nhatKy != null) {
      _loadData();
      _loadImages();
    }
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  void _loadData() {
    final nk = widget.nhatKy!;

    _tenController.text = nk.tenNhatKy ?? '';
    _noiDungController.text = nk.noiDung ?? '';
    _ngayTrienKhaiController.text = nk.ngayTrienKhai ?? '';

    _thoiTietSang = nk.thoiTietSang;
    _thoiTietChieu = nk.thoiTietChieu;

    _selectedCongTrinhId = nk.idCongTrinh;
  }

  Future<void> _loadCongTrinh() async {
    try {
      final data =
      await _congTrinhService.getDanhSachCongTrinh();

      if (!mounted) return;

      setState(() {
        _dsCongTrinh = data;
      });
    } catch (e) {
      if (!mounted) return;
showErrorToast(context, e, "Không thể tải danh sách công trình: ");

    }
  }

  Future<void> _loadImages() async {
    try {
      final paths =
      await _nhatKyService.getImages(widget.nhatKy!.id!);

      if (!mounted) return;

      setState(() {
        _images = paths.map((e) => File(e)).toList();
      });
    } catch (e) {
      debugPrint(
        "Lỗi load hình ảnh: $e",
      );
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectNgayTrienKhai() async {
    final currentValue =
        _ngayTrienKhaiController.text;

    DateTime initialDate =
        DateTime.tryParse(currentValue) ??
            DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "Chọn ngày triển khai",
    );

    if (date == null) return;

    setState(() {
      _ngayTrienKhaiController.text =
          date.toIso8601String().split('T').first;
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCongTrinhId == null) {
      showErrorToast(context, "","Vui lòng chọn công trình");
      return;
    }
    await PermissionManager.instance.runWithPermission(
        context,
        feature: FeatureEnum.luuNhatKyCongTrinh,
        action: () async {
          setState(() {
            _isSaving = true;
          });
          try {
            final imagePaths =
            _images.map((e) => e.path).toList();
            final now = DateTime.now().toIso8601String();
            final nk = NhatKyCongTrinh(
              id: widget.nhatKy?.id,
              tenNhatKy: _tenController.text.trim(),
              noiDung: _noiDungController.text.trim(),
              ngayTao:
              widget.nhatKy?.ngayTao ?? now,
              idCongTrinh: _selectedCongTrinhId!,
              ngayTrienKhai:
              _ngayTrienKhaiController.text.isNotEmpty
                  ? _ngayTrienKhaiController.text
                  : null,
              thoiTietSang: _thoiTietSang,
              thoiTietChieu: _thoiTietChieu,
            );
            int nhatKyId;
            if (widget.nhatKy == null) {
              nhatKyId = await _nhatKyService.insertNhatKy(nk);
            } else {
              if (nk.id == null) {
                throw Exception(
                  "ID nhật ký bị null khi update",
                );
              }
              await _nhatKyService.updateNhatKy(nk);
              nhatKyId = nk.id!;
              await _nhatKyService.deleteImages( nk.id!,);
            }
            if (imagePaths.isNotEmpty) {
              await _nhatKyService.insertImages( nhatKyId, imagePaths,);
            }
            if (!mounted) return;
            showSuccessToast(context, isEdit ? "Đã cập nhật nhật ký" : "Đã thêm nhật ký");
            Navigator.pop(context, true);
          } catch (e) {
            if (!mounted) return;
            showErrorToast(context, e, "Lỗi lưu nhật ký: $e");
          } finally {
            if (mounted) {
              setState(() {
                _isSaving = false;
              });
            }
          }
        }
    );

  }

  // ============================================================
  // IMAGE
  // ============================================================

  Future<void> _pickImages() async {
    if (_images.length >= 9) {
      _showMaxImageMessage();
      return;
    }

    final files = await _picker.pickMultiImage(
      imageQuality: 60,
    );

    if (files.isEmpty) return;

    setState(() {
      _images.addAll(
        files
            .take(9 - _images.length)
            .map(
              (e) => File(e.path),
        ),
      );
    });
  }

  Future<void> _takePhoto() async {
    if (_images.length >= 9) {
      _showMaxImageMessage();
      return;
    }

    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (photo == null) return;

    setState(() {
      _images.add(
        File(photo.path),
      );
    });
  }

  void _showMaxImageMessage() {
    showWarmToast(context, message:  "Tối đa 9 hình ảnh");

  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            Expanded(
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? "Sửa nhật ký"
                    : "Thêm nhật ký",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                isEdit
                    ? "Cập nhật thông tin nhật ký công trình"
                    : "Ghi nhận hoạt động và tình hình thi công",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
          child: const Text("Hủy"),
        ),

        const SizedBox(width: 10),

        FilledButton.icon(
          onPressed:
          _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 19,
          ),
          label: Text(
            _isSaving
                ? "Đang lưu..."
                : "Lưu nhật ký",
          ),
          style: FilledButton.styleFrom(
            backgroundColor:
            Colors.blue.shade700,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  Widget _buildForm() {
    return Form(
      key: _formKey,

      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildInformationCard(),
                  const SizedBox(height: 18),
                  _buildImageCard(),
                ],
              ),
            );
          }

          return Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: _buildInformationCard(),
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: _buildImageCard(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.description_outlined,
            title: "Thông tin nhật ký",
          ),

          const SizedBox(height: 22),

          _fieldLabel("Tên nhật ký"),

          const SizedBox(height: 7),

          TextFormField(
            controller: _tenController,
            decoration: _inputDecoration(
              hint: "Nhập tên nhật ký",
              icon: Icons.title_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return "Không được để trống";
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _fieldLabel("Công trình"),

          const SizedBox(height: 7),

          DropdownButtonFormField<int>(
            value: _selectedCongTrinhId,

            decoration: _inputDecoration(
              hint: "Chọn công trình",
              icon: Icons.business_outlined,
            ),

            items: _dsCongTrinh
                .map(
                  (ct) => DropdownMenuItem<int>(
                value: ct.id,
                child: Text(
                  ct.ten ?? "Không tên",
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),

            onChanged:
            widget.idCongTrinh != null
                ? null
                : (value) {
              setState(() {
                _selectedCongTrinhId =
                    value;
              });
            },

            validator: (value) {
              if (value == null) {
                return "Vui lòng chọn công trình";
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _fieldLabel("Ngày triển khai"),

          const SizedBox(height: 7),

          TextFormField(
            controller:
            _ngayTrienKhaiController,
            readOnly: true,

            decoration: _inputDecoration(
              hint: "Chọn ngày triển khai",
              icon:
              Icons.calendar_today_outlined,
            ).copyWith(
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
              ),
            ),

            onTap: _selectNgayTrienKhai,
          ),

          const SizedBox(height: 18),

          _fieldLabel("Thời tiết"),

          const SizedBox(height: 7),

          Row(
            children: [
              Expanded(
                child: buildWeatherDropdown(
                  value: _thoiTietSang,
                  label: "Thời tiết sáng",
                  onChanged: (value) {
                    setState(() {
                      _thoiTietSang = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: buildWeatherDropdown(
                  value: _thoiTietChieu,
                  label: "Thời tiết chiều",
                  onChanged: (value) {
                    setState(() {
                      _thoiTietChieu = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _fieldLabel("Nội dung"),

          const SizedBox(height: 7),

          TextFormField(
            controller: _noiDungController,

            minLines: 8,
            maxLines: 12,

            decoration: _inputDecoration(
              hint:
              "Nhập nội dung công việc, tình hình thi công...",
              icon: Icons.notes_outlined,
              alignIcon: true,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  icon: Icons.photo_library_outlined,
                  title: "Hình ảnh",
                ),
              ),

              Text(
                "${_images.length}/9",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "Thêm hình ảnh thực tế tại công trường",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _images.length >= 9
                      ? null
                      : _pickImages,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    "Thư viện",
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _images.length >= 9
                      ? null
                      : _takePhoto,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    "Chụp ảnh",
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildImagePreview(),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,

        child: Container(
          height: 280,
          width: double.infinity,

          decoration: BoxDecoration(
            color: const Color(0xfffafafa),
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 12),

              Text(
                "Chưa có hình ảnh",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Nhấn để chọn hình ảnh",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: _images.length,

      shrinkWrap: true,

      physics:
      const NeverScrollableScrollPhysics(),

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),

      itemBuilder: (context, index) {
        return _buildImageItem(
          _images[index],
          index,
        );
      },
    );
  }

  Widget _buildImageItem(
      File file,
      int index,
      ) {
    return Stack(
      fit: StackFit.expand,

      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(9),

          child: Image.file(
            file,
            fit: BoxFit.cover,

            cacheWidth: 500,
            cacheHeight: 500,

            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 35,
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 7,
          right: 7,

          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),

            child: InkWell(
              customBorder:
              const CircleBorder(),

              onTap: () {
                _removeImage(index);
              },

              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 7,
          bottom: 7,

          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),

            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius:
              BorderRadius.circular(5),
            ),

            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: child,
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.09),
            borderRadius:
            BorderRadius.circular(8),
          ),

          child: Icon(
            icon,
            size: 19,
            color: Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff263238),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(
      String text,
      ) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xff37474f),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool alignIcon = false,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,
        size: 19,
      ),

      prefixIconConstraints:
      alignIcon
          ? const BoxConstraints(
        minWidth: 45,
        minHeight: 45,
      )
          : null,

      filled: true,

      fillColor: const Color(0xfffafafa),

      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.blue.shade600,
          width: 1.5,
        ),
      ),

      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenController.dispose();
    _noiDungController.dispose();
    _ngayTrienKhaiController.dispose();

    super.dispose();
  }
}