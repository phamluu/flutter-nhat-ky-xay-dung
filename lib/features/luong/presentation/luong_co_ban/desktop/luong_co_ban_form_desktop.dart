import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/LuongCoBan.dart';
import '../../../data/repositories/luong_coban_repository.dart';
import '../../../data/services/luong_co_ban_service.dart';

class LuongCoBanFormDesktop extends StatefulWidget {
  final LuongCoBanNhanVienModel? luong;
  final int idNhanVien;
  final String? hoTen;

  const LuongCoBanFormDesktop({
    Key? key,
    this.luong,
    required this.idNhanVien,
    this.hoTen,
  }) : super(key: key);

  @override
  State<LuongCoBanFormDesktop> createState() =>
      _LuongCoBanFormDesktopState();
}

class _LuongCoBanFormDesktopState
    extends State<LuongCoBanFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _service = LuongCoBanService();
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
      // ==============================
      // EDIT
      // ==============================

      if (widget.luong!.soTien != null) {
        soTienCtrl.text =
            formatCurrency(widget.luong!.soTien!);
      }

      ghiChuCtrl.text =
          widget.luong!.ghiChu ?? "";

      if (widget.luong!.ngayApDung != null) {
        selectedDate =
            widget.luong!.ngayApDung;

        ngayCtrl.text =
            DateFormat('dd/MM/yyyy')
                .format(widget.luong!.ngayApDung!);
      }
    } else {
      // ==============================
      // ADD
      // ==============================

      selectedDate = DateTime.now();

      ngayCtrl.text =
          DateFormat('dd/MM/yyyy')
              .format(selectedDate!);
    }
  }

  @override
  void dispose() {
    soTienCtrl.dispose();
    ngayCtrl.dispose();
    ghiChuCtrl.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK DATE
  // ============================================================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày áp dụng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;

        ngayCtrl.text =
            DateFormat('dd/MM/yyyy')
                .format(picked);
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng chọn ngày",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final model = Luongcoban(
      idNhanVien: widget.idNhanVien,
      id: widget.luong?.id,
      mucLuong:
      parseCurrency(soTienCtrl.text),
      ngayApDung: selectedDate,
      ghiChu: ghiChuCtrl.text.trim(),
    );

    try {
      if (widget.luong == null) {
        // ADD
        await _repo.insert(
          model,
        );
      } else {
        // UPDATE
        await _repo.update(
          model,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Lưu thành công",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEdit =
        widget.luong != null;

    final theme =
    Theme.of(context);

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              theme,
              isEdit,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  32,
                  28,
                  32,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: _buildFormCard(
                      theme,
                      isEdit,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      ThemeData theme,
      bool isEdit,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // BACK
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: IconButton(
              tooltip: 'Quay lại',
              onPressed: isLoading
                  ? null
                  : () =>
                  Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ICON
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primary
                  .withOpacity(.10),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              isEdit
                  ? Icons.edit_note
                  : Icons.add_card,
              color:
              theme.colorScheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          // TITLE
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit
                      ? 'Sửa lương cơ bản'
                      : 'Thêm lương cơ bản',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.hoTen
                      ?.trim()
                      .isNotEmpty ==
                      true
                      ? 'Nhân viên: ${widget.hoTen}'
                      : 'Thiết lập mức lương cơ bản',
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // CANCEL
          OutlinedButton(
            onPressed: isLoading
                ? null
                : () =>
                Navigator.pop(context),
            child: const Text(
              'Hủy',
            ),
          ),

          const SizedBox(width: 10),

          // SAVE
          FilledButton.icon(
            onPressed:
            isLoading ? null : _save,
            icon: isLoading
                ? const SizedBox(
              width: 17,
              height: 17,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.save_outlined,
              size: 18,
            ),
            label: Text(
              isEdit
                  ? 'Cập nhật'
                  : 'Lưu',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard(
      ThemeData theme,
      bool isEdit,
      ) {
    return Form(
      key: _formKey,
      child: Container(
        padding:
        const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // FORM HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue
                        .withOpacity(.08),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color:
                    Colors.blue.shade700,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit
                          ? 'Thông tin mức lương'
                          : 'Thông tin mức lương mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Nhập đầy đủ thông tin bên dưới',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Divider(),

            const SizedBox(height: 28),

            // ==================================================
            // ROW 1
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSalaryField(),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _buildDateField(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // NOTE
            // ==================================================

            _buildNoteField(),

            const SizedBox(height: 28),

            // ==================================================
            // INFO
            // ==================================================

            _buildInfoBox(),

            const SizedBox(height: 28),

            // ==================================================
            // BUTTONS
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () =>
                      Navigator.pop(
                        context,
                      ),
                  style:
                  OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                  ),
                ),

                const SizedBox(width: 12),

                FilledButton.icon(
                  onPressed:
                  isLoading ? null : _save,
                  style:
                  FilledButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 15,
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.save_outlined,
                  ),
                  label: Text(
                    isEdit
                        ? 'Cập nhật'
                        : 'Lưu mức lương',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SALARY FIELD
  // ============================================================

  Widget _buildSalaryField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Lương / ngày',
          style: TextStyle(
            fontWeight:
            FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: soTienCtrl,
          keyboardType:
          TextInputType.number,

          inputFormatters: [
            FilteringTextInputFormatter
                .digitsOnly,
            CurrencyInputFormatter(),
          ],

          decoration:
          InputDecoration(
            hintText:
            'Nhập mức lương',
            prefixIcon: const Icon(
              Icons.payments_outlined,
            ),
            suffixText: 'VNĐ',
            filled: true,
            fillColor:
            const Color(0xFFF9FAFB),
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.blue.shade600,
                width: 1.5,
              ),
            ),
          ),

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Nhập số tiền';
            }

            final amount =
            parseCurrency(value);

            if (amount <= 0) {
              return 'Số tiền phải lớn hơn 0';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày áp dụng',
          style: TextStyle(
            fontWeight:
            FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: ngayCtrl,
          readOnly: true,

          onTap: _pickDate,

          decoration:
          InputDecoration(
            hintText:
            'Chọn ngày áp dụng',
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
            ),
            filled: true,
            fillColor:
            const Color(0xFFF9FAFB),
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.blue.shade600,
                width: 1.5,
              ),
            ),
          ),

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Chọn ngày áp dụng';
            }

            return null;
          },
        ),
      ],
    );
  }

  // ============================================================
  // NOTE FIELD
  // ============================================================

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú',
          style: TextStyle(
            fontWeight:
            FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: ghiChuCtrl,
          maxLines: 5,
          decoration:
          InputDecoration(
            hintText:
            'Nhập lý do điều chỉnh, ghi chú...',
            prefixIcon:
            const Padding(
              padding:
              EdgeInsets.only(
                bottom: 72,
              ),
              child: Icon(
                Icons.notes_outlined,
              ),
            ),
            filled: true,
            fillColor:
            const Color(0xFFF9FAFB),
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.grey.shade300,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              borderSide:
              BorderSide(
                color:
                Colors.blue.shade600,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue
            .withOpacity(.05),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue
              .withOpacity(.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color:
            Colors.blue.shade700,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Mức lương được áp dụng từ ngày đã chọn. '
                  'Thông tin này sẽ được lưu vào lịch sử lương '
                  'của nhân viên.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}