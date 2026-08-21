import 'package:flutter/material.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/services/danh_muc_thu_chi_service.dart';

class DanhMucThuChiFormDeskTop extends StatefulWidget {
  final DanhMucThuChi? danhMuc;

  const DanhMucThuChiFormDeskTop({
    super.key,
    this.danhMuc,
  });

  @override
  State<DanhMucThuChiFormDeskTop> createState() =>
      _ThemDanhMucThuChiScreenState();
}

class _ThemDanhMucThuChiScreenState
    extends State<DanhMucThuChiFormDeskTop> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();

  final _service = DanhMucThuChiService();

  bool _isSaving = false;

  bool get _isEdit => widget.danhMuc != null;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      _tenController.text = widget.danhMuc!.ten;
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (!_isEdit) {
        await _service.insert(
          DanhMucThuChi(
            ten: _tenController.text.trim(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thêm hạng mục thu chi thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _service.update(
          DanhMucThuChi(
            id: widget.danhMuc!.id,
            ten: _tenController.text.trim(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                  'Sửa hạng mục thu chi thành công'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Có lỗi xảy ra: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit
        ? "Sửa danh mục"
        : "Thêm danh mục";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(28),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // Header
                      Row(
                        children: [

                          Container(
                            width: 46,
                            height: 46,

                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),

                            child: Icon(
                              _isEdit
                                  ? Icons.edit_outlined
                                  : Icons.category_outlined,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _isEdit
                                    ? "Cập nhật thông tin danh mục"
                                    : "Tạo một danh mục thu chi mới",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                  Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Label
                      const Text(
                        "Tên danh mục",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // TextField
                      TextFormField(
                        controller: _tenController,
                        autofocus: true,

                        textInputAction:
                        TextInputAction.done,

                        onFieldSubmitted: (_) {
                          if (!_isSaving) {
                            _save();
                          }
                        },

                        decoration: InputDecoration(
                          hintText:
                          "Ví dụ: Ăn uống, Mua sắm, Lương...",
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                          ),

                          filled: true,
                          fillColor:
                          Colors.grey.shade50,

                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                              Colors.grey.shade300,
                            ),
                          ),

                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                              Colors.grey.shade300,
                            ),
                          ),

                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),

                          errorBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(
                              color: Colors.red,
                            ),
                          ),

                          focusedErrorBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),

                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),

                        validator: (value) {
                          final text =
                              value?.trim() ?? '';

                          if (text.isEmpty) {
                            return "Vui lòng nhập tên danh mục";
                          }

                          if (text.length < 2) {
                            return "Tên danh mục phải có ít nhất 2 ký tự";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      const Divider(),

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.end,

                        children: [

                          OutlinedButton(
                            onPressed:
                            _isSaving
                                ? null
                                : _cancel,

                            style:
                            OutlinedButton.styleFrom(
                              foregroundColor:
                              Colors.grey.shade700,

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(8),
                              ),
                            ),

                            child:
                            const Text("Hủy"),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            onPressed:
                            _isSaving
                                ? null
                                : _save,

                            icon: _isSaving
                                ? const SizedBox(
                              width: 17,
                              height: 17,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.save_outlined,
                              size: 18,
                            ),

                            label: Text(
                              _isSaving
                                  ? "Đang lưu..."
                                  : "Lưu",
                            ),

                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.blue.shade600,

                              foregroundColor:
                              Colors.white,

                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),

                              elevation: 0,

                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(8),
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
        ),
      ),
    );
  }
}