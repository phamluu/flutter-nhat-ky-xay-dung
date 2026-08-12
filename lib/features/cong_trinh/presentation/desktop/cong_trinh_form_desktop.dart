import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/CongTrinh.dart';
import '../../../../data/repositories/CongTrinhReponsitory.dart';
import '../../data/services/cong_trinh_service.dart';

class CongTrinhFormDesktop extends StatefulWidget {
  final CongTrinh? congTrinh;

  const CongTrinhFormDesktop({
    super.key,
    this.congTrinh,
  });

  @override
  State<CongTrinhFormDesktop> createState() =>
      _CongTrinhFormDesktopState();
}

class _CongTrinhFormDesktopState
    extends State<CongTrinhFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _service = CongTrinhService(
    repo: CongtrinhReponsitory(),
  );

  final _tenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _moTaController = TextEditingController();
  final _ngayBatDauController = TextEditingController();
  final _ngayKetThucController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  bool _isSaving = false;

  bool get isEdit => widget.congTrinh != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final ct = widget.congTrinh!;

      _tenController.text = ct.ten ?? '';
      _diaChiController.text = ct.diaChi ?? '';
      _moTaController.text = ct.moTa ?? '';
      _ngayBatDauController.text =
          ct.ngayBatDau ?? '';
      _ngayKetThucController.text =
          ct.ngayKetThuc ?? '';
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaChiController.dispose();
    _moTaController.dispose();
    _ngayBatDauController.dispose();
    _ngayKetThucController.dispose();

    super.dispose();
  }

  // ==========================================================
  // CHỌN HÌNH
  // ==========================================================

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (picked == null) return;

      setState(() {
        _imageFile = File(picked.path);
      });
    } catch (e) {
      _showError(
        'Không thể chọn hình ảnh: $e',
      );
    }
  }

  // ==========================================================
  // LƯU
  // ==========================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final model = CongTrinh(
      id: widget.congTrinh?.id,
      ten: _tenController.text.trim(),
      diaChi: _diaChiController.text.trim(),
      moTa: _moTaController.text.trim(),
      ngayBatDau:
      _ngayBatDauController.text.trim(),
      ngayKetThuc:
      _ngayKetThucController.text.trim(),
      hinhAnh:
      _imageFile?.path ??
          widget.congTrinh?.hinhAnh,
    );

    try {
      if (isEdit) {
        await _service.updateCongTrinh(model);
      } else {
        await _service.themCongTrinh(model);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Cập nhật công trình thành công'
                : 'Thêm công trình thành công',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showError(
        'Không thể lưu công trình: $e',
      );
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  Widget _buildImage() {
    File? image;

    if (_imageFile != null) {
      image = _imageFile;
    } else if (isEdit &&
        widget.congTrinh!.hinhAnh != null &&
        widget.congTrinh!.hinhAnh!.isNotEmpty) {
      final file = File(
        widget.congTrinh!.hinhAnh!,
      );

      if (file.existsSync()) {
        image = file;
      }
    }

    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          image,
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildEmptyImage();
          },
        ),
      );
    }

    return _buildEmptyImage();
  }

  Widget _buildEmptyImage() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 52,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có hình ảnh',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn để chọn hình ảnh',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // ==========================================================
  // DATE FIELD
  // ==========================================================

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 18,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder:
        const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        final now = DateTime.now();

        final initialDate =
            _parseDate(
              controller.text,
            ) ??
                now;

        final selected =
        await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate:
          DateTime(2000),
          lastDate:
          DateTime(2100),
        );

        if (selected == null) {
          return;
        }

        final value =
            '${selected.year.toString().padLeft(4, '0')}-'
            '${selected.month.toString().padLeft(2, '0')}-'
            '${selected.day.toString().padLeft(2, '0')}';

        setState(() {
          controller.text = value;
        });
      },
    );
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) {
      return null;
    }

    try {
      return DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange
                      .withOpacity(.1),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFF2C3E50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F6F8),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Sửa công trình'
              : 'Thêm công trình',
        ),
        actions: [
          TextButton.icon(
            onPressed:
            _isSaving
                ? null
                : () {
              Navigator.pop(
                context,
              );
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            label: const Text(
              'Hủy',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: ElevatedButton.icon(
              onPressed:
              _isSaving
                  ? null
                  : _save,
              icon: _isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
              ),
              label: Text(
                _isSaving
                    ? 'Đang lưu...'
                    : 'Lưu công trình',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.white,
                foregroundColor:
                Colors.orange,
              ),
            ),
          ),

          const SizedBox(width: 16),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    isEdit
                        ? 'Thông tin công trình'
                        : 'Tạo công trình mới',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isEdit
                        ? 'Cập nhật thông tin công trình'
                        : 'Nhập thông tin để tạo công trình mới',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // 2 CỘT
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ==============================================
                      // CỘT TRÁI
                      // ==============================================

                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildSection(
                              title:
                              'Thông tin cơ bản',
                              icon:
                              Icons.apartment_outlined,
                              child:
                              Column(
                                children: [
                                  _buildTextField(
                                    label:
                                    'Tên công trình',
                                    controller:
                                    _tenController,
                                    icon:
                                    Icons.folder_outlined,
                                    hint:
                                    'Nhập tên công trình',
                                    validator:
                                        (value) {
                                      if (value ==
                                          null ||
                                          value
                                              .trim()
                                              .isEmpty) {
                                        return 'Vui lòng nhập tên công trình';
                                      }

                                      return null;
                                    },
                                  ),

                                  const SizedBox(
                                      height: 16),

                                  _buildTextField(
                                    label:
                                    'Địa chỉ',
                                    controller:
                                    _diaChiController,
                                    icon:
                                    Icons.location_on_outlined,
                                    hint:
                                    'Nhập địa chỉ công trình',
                                  ),

                                  const SizedBox(
                                      height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                        _buildDateField(
                                          label:
                                          'Ngày bắt đầu',
                                          controller:
                                          _ngayBatDauController,
                                          icon:
                                          Icons.calendar_today_outlined,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 16),

                                      Expanded(
                                        child:
                                        _buildDateField(
                                          label:
                                          'Ngày kết thúc',
                                          controller:
                                          _ngayKetThucController,
                                          icon:
                                          Icons.event_outlined,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 16),

                                  _buildTextField(
                                    label:
                                    'Mô tả',
                                    controller:
                                    _moTaController,
                                    icon:
                                    Icons.notes_outlined,
                                    hint:
                                    'Nhập mô tả công trình',
                                    maxLines:
                                    5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // ==============================================
                      // CỘT PHẢI
                      // ==============================================

                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildSection(
                              title:
                              'Hình ảnh công trình',
                              icon:
                              Icons.image_outlined,
                              child:
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap:
                                    _pickImage,
                                    child:
                                    _buildImage(),
                                  ),

                                  const SizedBox(
                                      height: 16),

                                  SizedBox(
                                    width:
                                    double.infinity,
                                    child:
                                    OutlinedButton.icon(
                                      onPressed:
                                      _pickImage,
                                      icon:
                                      const Icon(
                                        Icons
                                            .photo_library_outlined,
                                      ),
                                      label:
                                      const Text(
                                        'Chọn hình ảnh',
                                      ),
                                      style:
                                      OutlinedButton.styleFrom(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical:
                                          14,
                                        ),
                                        foregroundColor:
                                        Colors.orange,
                                        side:
                                        const BorderSide(
                                          color:
                                          Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_imageFile !=
                                      null) ...[
                                    const SizedBox(
                                        height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .check_circle,
                                          size: 16,
                                          color:
                                          Colors.green,
                                        ),
                                        const SizedBox(
                                            width: 6),
                                        Expanded(
                                          child:
                                          Text(
                                            'Đã chọn hình ảnh mới',
                                            style:
                                            TextStyle(
                                              fontSize:
                                              12,
                                              color:
                                              Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 20),

                            // ==========================================
                            // THÔNG TIN
                            // ==========================================

                            Container(
                              width:
                              double.infinity,
                              padding:
                              const EdgeInsets.all(
                                  18),
                              decoration:
                              BoxDecoration(
                                color: Colors.orange
                                    .withOpacity(.06),
                                borderRadius:
                                BorderRadius.circular(
                                    12),
                                border:
                                Border.all(
                                  color: Colors.orange
                                      .withOpacity(.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  const Icon(
                                    Icons
                                        .info_outline,
                                    color:
                                    Colors.orange,
                                  ),
                                  const SizedBox(
                                      width: 10),
                                  Expanded(
                                    child: Text(
                                      isEdit
                                          ? 'Thay đổi thông tin rồi nhấn "Lưu công trình" để cập nhật.'
                                          : 'Điền đầy đủ thông tin công trình rồi nhấn "Lưu công trình".',
                                      style:
                                      TextStyle(
                                        fontSize:
                                        13,
                                        height:
                                        1.5,
                                        color: Colors
                                            .grey
                                            .shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // FOOTER BUTTON
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed:
                        _isSaving
                            ? null
                            : () {
                          Navigator.pop(
                            context,
                          );
                        },
                        style:
                        OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child:
                        const Text('Hủy'),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
                        onPressed:
                        _isSaving
                            ? null
                            : _save,
                        icon: _isSaving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                            color:
                            Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons
                              .save_outlined,
                        ),
                        label: Text(
                          _isSaving
                              ? 'Đang lưu...'
                              : isEdit
                              ? 'Cập nhật công trình'
                              : 'Tạo công trình',
                        ),
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.orange,
                          foregroundColor:
                          Colors.white,
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}