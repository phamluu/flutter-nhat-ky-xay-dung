import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';

import '../../../../../core/utils/trang_thai_tien_do.dart';
import '../../../data/models/TienDoCongTrinhModel.dart';
import '../../../data/respositories/TienDoRepository.dart';
import '../../../data/services/TienDoService.dart';

class TienDoFormDesktop extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  final TienDoCongTrinhModel? model;
  const TienDoFormDesktop({
    super.key,
    required this.idCongTrinh,
    this.tenCongTrinh,
    this.model,
  });

  @override
  State<TienDoFormDesktop> createState() => _TienDoFormDesktopState();
}

class _TienDoFormDesktopState extends State<TienDoFormDesktop> {
  final _formKey = GlobalKey<FormState>();
  final service = TienDoService( TienDoRepository(), );
  final _tenCtrl = TextEditingController();
  final _phanTramCtrl = TextEditingController();
  final _moTaCtrl = TextEditingController();
  final _ngayBatDauCtrl = TextEditingController();
  final _ngayKetThucCtrl = TextEditingController();
  final _trongSoCtrl = TextEditingController();
  int _trangThai = 0;
  bool _isSaving = false;
  bool get isEdit => widget.model != null;

  @override
  void initState() {
    super.initState();
    final m = widget.model;
    if (m != null) {
      _tenCtrl.text = m.tenCongViec;
      _phanTramCtrl.text = (m.phanTramThucTe ?? 0).toString();
      _moTaCtrl.text = m.moTa ?? '';
      _ngayBatDauCtrl.text = m.ngayBatDau ?? '';
      _ngayKetThucCtrl.text = m.ngayKetThuc ?? '';
      _trongSoCtrl.text = (m.trongSo ?? 1).toString();
      _trangThai = m.trangThai ?? 0;
    } else {
      _phanTramCtrl.text = '0';
      _trongSoCtrl.text = '1';
    }
  }
  @override
  void dispose() {
    _tenCtrl.dispose();
    _phanTramCtrl.dispose();
    _moTaCtrl.dispose();
    _ngayBatDauCtrl.dispose();
    _ngayKetThucCtrl.dispose();
    _trongSoCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> pickDate(
      TextEditingController controller, ) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(
        controller.text,
      );

      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      controller.text =
          picked.toIso8601String().split('T').first;
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final phanTram = double.tryParse(_phanTramCtrl.text) ?? 0;
    final trongSo = double.tryParse(_trongSoCtrl.text) ?? 1;
    final model = TienDoCongTrinhModel(
      id: widget.model?.id,
      idCongTrinh: widget.idCongTrinh,
      tenCongViec: _tenCtrl.text.trim(),
      moTa: _moTaCtrl.text.trim(),
      ngayBatDau: _ngayBatDauCtrl.text.trim(),
      ngayKetThuc: _ngayKetThucCtrl.text.trim(),
      phanTramThucTe: phanTram,
      trongSo: trongSo,
      trangThai: _trangThai,
    );
    setState(() {
      _isSaving = true;
    });
    try {
      await service.save(model);
      if (!mounted) return;
      showSuccessToast(context, "Lưu thành công");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      showErrorToast(context, e, 'Không thể lưu tiến độ: ');
    }
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
        // Nút Back
        Tooltip(
          message: 'Quay lại',
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_back, size: 21, color: Color(0xff37474f)),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Icon
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit ? Icons.edit_note_outlined : Icons.add_task_outlined,
            color: Colors.blue.shade700,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Title & Ten Cong Trinh
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isEdit ? 'Sửa tiến độ công việc' : 'Thêm công việc',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff263238),
                    ),
                  ),
                  // Badge Tên công trình
                  if (widget.tenCongTrinh != null && widget.tenCongTrinh!.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_city_outlined, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            widget.tenCongTrinh!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isEdit
                    ? 'Cập nhật thông tin và tiến độ công việc'
                    : 'Nhập thông tin công việc cần theo dõi',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        // Nút Hủy
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Hủy'),
        ),

        const SizedBox(width: 10),

        // Nút Lưu
        ElevatedButton.icon(
          onPressed: _isSaving ? null : save,
          icon: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.save_outlined, size: 19),
          label: Text(_isSaving ? 'Đang lưu...' : 'Lưu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM
  // ============================================================

  Widget _buildForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
            const EdgeInsets.only(bottom: 30),
            children: [
              _buildBasicCard(),

              const SizedBox(height: 16),

              _buildScheduleCard(),

              const SizedBox(height: 16),

              _buildProgressCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BASIC INFO
  // ============================================================

  Widget _buildBasicCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.assignment_outlined,
            title: 'Thông tin công việc',
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _tenCtrl,
            decoration: _inputDecoration(
              label: 'Tên công việc',
              icon: Icons.task_alt_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Vui lòng nhập tên công việc';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: _moTaCtrl,
            maxLines: 4,
            decoration: _inputDecoration(
              label: 'Mô tả',
              icon: Icons.description_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.calendar_month_outlined,
            title: 'Thời gian thực hiện',
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildDateField(
                      controller:
                      _ngayBatDauCtrl,
                      label: 'Ngày bắt đầu',
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller:
                      _ngayKetThucCtrl,
                      label: 'Ngày kết thúc',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller:
                      _ngayBatDauCtrl,
                      label: 'Ngày bắt đầu',
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildDateField(
                      controller:
                      _ngayKetThucCtrl,
                      label: 'Ngày kết thúc',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => pickDate(controller),
      decoration: _inputDecoration(
        label: label,
        icon: Icons.event_outlined,
        suffix: const Icon(
          Icons.calendar_today_outlined,
          size: 19,
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgressCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.speed_outlined,
            title: 'Tiến độ',
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _buildProgressField(),
                    const SizedBox(height: 16),
                    _buildWeightField(),
                    const SizedBox(height: 16),
                    _buildStatusField(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProgressField(),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildWeightField(),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildStatusField(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          _buildProgressPreview(),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS FIELD
  // ============================================================

  Widget _buildProgressField() {
    return TextFormField(
      controller: _phanTramCtrl,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: _inputDecoration(
        label: '% tiến độ thực tế',
        icon: Icons.percent_outlined,
        suffix:
        const Text('%'),
      ),
      validator: (value) {
        final v = double.tryParse(
          value ?? '',
        );

        if (v == null) {
          return 'Nhập số hợp lệ';
        }

        if (v < 0 || v > 100) {
          return 'Chỉ từ 0 đến 100';
        }

        return null;
      },
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  // ============================================================
  // WEIGHT
  // ============================================================

  Widget _buildWeightField() {
    return TextFormField(
      controller: _trongSoCtrl,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: _inputDecoration(
        label: 'Trọng số',
        icon: Icons.balance_outlined,
      ),
      validator: (value) {
        final v = double.tryParse(
          value ?? '',
        );

        if (v == null) {
          return 'Nhập số hợp lệ';
        }

        if (v <= 0) {
          return 'Trọng số phải > 0';
        }

        return null;
      },
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusField() {
    return DropdownButtonFormField<
        TrangThaiTienDo>(
      value: TrangThaiTienDo.fromValue(
        _trangThai,
      ),
      items: TrangThaiTienDo.values.map(
            (e) {
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                _statusDot(e.value),
                const SizedBox(width: 8),
                Text(e.label),
              ],
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        setState(() {
          _trangThai =
              value?.value ?? 0;
        });
      },
      decoration: _inputDecoration(
        label: 'Trạng thái',
        icon: Icons.flag_outlined,
      ),
    );
  }

  Widget _statusDot(int value) {
    Color color;

    switch (value) {
      case 2:
        color = Colors.green;
        break;
      case 1:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // PROGRESS PREVIEW
  // ============================================================

  Widget _buildProgressPreview() {
    final value =
        double.tryParse(
          _phanTramCtrl.text,
        ) ??
            0;

    final percent =
        value.clamp(0, 100) / 100;

    Color color;

    switch (_trangThai) {
      case 2:
        color = Colors.green;
        break;
      case 1:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tiến độ hiện tại',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w600,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(5),
            child:
            LinearProgressIndicator(
              value: percent,
              minHeight: 9,
              backgroundColor:
              Colors.grey.shade200,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
            Colors.blue.withOpacity(
              0.1,
            ),
            borderRadius:
            BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 19,
            color:
            Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.w600,
            color:
            Color(0xff263238),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor:
      const Color(0xfffafafa),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide:
        BorderSide(
          color:
          Colors.grey.shade300,
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide:
        BorderSide(
          color:
          Colors.grey.shade300,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide:
        BorderSide(
          color:
          Colors.blue.shade600,
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
    );
  }
}