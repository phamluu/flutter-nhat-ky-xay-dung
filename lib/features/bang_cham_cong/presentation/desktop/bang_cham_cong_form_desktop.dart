import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/bang_cham_cong.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/bang_cham_cong_repo.dart';

class BangChamCongFormDesktop extends StatefulWidget {
  final BangChamCong? bangChamCong;
  const BangChamCongFormDesktop({
    super.key,
    this.bangChamCong,
  });
  @override
  State<BangChamCongFormDesktop> createState() =>
      _BangChamCongFormDesktopState();
}

class _BangChamCongFormDesktopState extends State<BangChamCongFormDesktop> {
  final _formKey = GlobalKey<FormState>();
  final _repo = BangChamCongRepository();
  bool _isSaving = false;
  int? _selectedMonth;
  int? _selectedYear;
  bool get isEdit => widget.bangChamCong?.id != null;
  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final ct = widget.bangChamCong!;
      _selectedMonth = ct.thang;
      _selectedYear = ct.nam;
    } else {
      final now = DateTime.now();
      _selectedMonth = now.month;
      _selectedYear = now.year;
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedMonth == null || _selectedYear == null) {
      _showError('Vui lòng chọn tháng và năm');
      return;
    }
    setState(() {
      _isSaving = true;
    });
    final model = BangChamCong(
      id: widget.bangChamCong?.id,
      idCongTrinh: widget.bangChamCong?.idCongTrinh,
      thang: _selectedMonth,
      nam: _selectedYear,
    );
    try {
      if (isEdit) {
        // await _repo.update(model);
      } else {
        await _repo.insert(model);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Cập nhật bảng chấm công thành công'
                : 'Thêm bảng chấm công thành công',
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
        isEdit
            ? 'Không thể cập nhật bảng chấm công: $e'
            : 'Không thể thêm bảng chấm công: $e',
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
  // MONTH DROPDOWN
  // ==========================================================

  Widget _buildMonthField() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      decoration: InputDecoration(
        labelText: 'Tháng',
        hintText: 'Chọn tháng',
        prefixIcon: const Icon(
          Icons.calendar_month_outlined,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: List.generate(
        12,
            (index) {
          final month = index + 1;

          return DropdownMenuItem<int>(
            value: month,
            child: Text('Tháng $month'),
          );
        },
      ),
      onChanged: _isSaving
          ? null
          : (value) {
        setState(() {
          _selectedMonth = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn tháng';
        }

        return null;
      },
    );
  }

  Widget _buildYearField() {
    final currentYear = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      decoration: InputDecoration(
        labelText: 'Năm',
        hintText: 'Chọn năm',
        prefixIcon: const Icon(
          Icons.event_outlined,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: List.generate(
        21,
            (index) {
          final year = currentYear - 10 + index;

          return DropdownMenuItem<int>(
            value: year,
            child: Text(year.toString()),
          );
        },
      ),
      onChanged: _isSaving
          ? null
          : (value) {
        setState(() {
          _selectedYear = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn năm';
        }

        return null;
      },
    );
  }
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
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
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
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
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
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
            : isEdit
            ? 'Cập nhật'
            : 'Lưu bảng chấm công',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
      ),
    );
  }
  void _cancel() {
    if (_isSaving) return;

    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Sửa bảng chấm công'
              : 'Thêm bảng chấm công',
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _cancel,
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
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: _buildSaveButton(),
          ),

          const SizedBox(width: 16),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    isEdit
                        ? 'Thông tin bảng chấm công'
                        : 'Tạo bảng chấm công',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isEdit
                        ? 'Cập nhật tháng và năm của bảng chấm công'
                        : 'Chọn tháng và năm để tạo bảng chấm công',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // THÔNG TIN
                  // ==================================================

                  _buildSection(
                    title: 'Thông tin bảng chấm công',
                    icon: Icons.access_time_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMonthField(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildYearField(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // PREVIEW
                  // ==================================================

                  if (_selectedMonth != null &&
                      _selectedYear != null)
                    _buildPreview(),

                  const SizedBox(height: 32),

                  // ==================================================
                  // BOTTOM BUTTONS
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed:
                        _isSaving ? null : _cancel,
                        style:
                        OutlinedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                        ),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
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
                        ),
                        label: Text(
                          _isSaving
                              ? 'Đang lưu...'
                              : isEdit
                              ? 'Cập nhật'
                              : 'Tạo bảng chấm công',
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

  // ==========================================================
  // PREVIEW
  // ==========================================================

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.orange,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảng chấm công',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Tháng $_selectedMonth/$_selectedYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}