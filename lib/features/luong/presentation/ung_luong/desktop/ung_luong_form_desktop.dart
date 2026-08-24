import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';

class UngLuongFormDesktop extends StatefulWidget {
  final Ungluong? ul;
  final int? idNhanVienCongTrinh;
  final String? tenCongTrinh;
  final String? hoTen;
  final String? kyLuong;
  const UngLuongFormDesktop({
    Key? key,
    this.ul,
    this.idNhanVienCongTrinh,
    this.tenCongTrinh,
    this.hoTen,
    this.kyLuong,
  }) : super(key: key);

  @override
  State<UngLuongFormDesktop> createState() =>
      _UngLuongFormScreenState();
}

class _UngLuongFormScreenState
    extends State<UngLuongFormDesktop> {
  final _formKey =GlobalKey<FormState>();
  final _service =UngLuongRepository();
  final soTienCtrl =TextEditingController();
  final ngayCtrl =TextEditingController();
  final lyDoCtrl =TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.ul != null) {
      if (widget.ul!.soTien != null) {
        soTienCtrl.text =formatCurrency( widget.ul!.soTien!);
      }
      lyDoCtrl.text = widget.ul!.lyDo ?? '';
      if (widget.ul!.ngayUng != null) {
        selectedDate = widget.ul!.ngayUng;
        ngayCtrl.text =DateFormat( 'dd/MM/yyyy').format(widget.ul!.ngayUng!);
      }
    } else {
      final today =DateTime.now();
      selectedDate = today;
      ngayCtrl.text =DateFormat('dd/MM/yyyy' ).format( selectedDate!);
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
    final initialDate = selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày ứng lương',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked == null) return;
    setState(() {
      selectedDate = picked;
      ngayCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }

  // ============================================================
  // KIỂM TRA NGÀY
  // ============================================================

  // bool _isDateInCurrentPeriod(
  //     DateTime date,
  //     ) {
  //   return !date.isBefore(
  //     firstDayOfMonth,
  //   ) &&
  //       !date.isAfter(
  //         lastDayOfMonth,
  //       );
  // }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    // ==========================================
    // KIỂM TRA NGÀY
    // ==========================================

    if (selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chọn ngày ứng lương',
          ),
          backgroundColor:
          Colors.red,
        ),
      );

      return;
    }

    // if (!_isDateInCurrentPeriod(
    //   selectedDate!,
    // )) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         'Ngày ứng phải thuộc tháng '
    //             '${widget.thang}/${widget.nam}',
    //       ),
    //       backgroundColor:
    //       Colors.red,
    //     ),
    //   );
    //
    //   return;
    // }

    setState(() {
      isLoading = true;
    });

    final model = Ungluong(
      id: widget.ul?.id,

      idNhanVienCongTrinh:
      widget.idNhanVienCongTrinh,

      soTien:
      parseCurrency(
        soTienCtrl.text,
      ),

      ngayUng:
      selectedDate,

      lyDo:
      lyDoCtrl.text.trim(),
    );

    try {
      // ==========================================
      // THÊM
      // ==========================================

      if (widget.ul == null) {
        await _service.addUngLuong(
          model,
        );
      }

      // ==========================================
      // SỬA
      // ==========================================

      else {
        await _service.updateUngLuong(
          model,
        );
      }

      if (!mounted) {
        return;
      }

      // Trả true về màn hình danh sách
      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
          ),
          backgroundColor:
          Colors.red,
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
        widget.ul != null;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
        Colors.white,

        foregroundColor:
        const Color(0xFF111827),

        titleSpacing: 24,

        title: Row(
          children: [
            Icon(
              isEdit
                  ? Icons.edit_outlined
                  : Icons
                  .add_card_outlined,

              color:
              Colors.blue,
            ),

            const SizedBox(
              width: 10,
            ),

            Text(
              isEdit
                  ? 'Sửa ứng lương'
                  : 'Thêm ứng lương',

              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            // ==================================
            // KỲ LƯƠNG
            // ==================================

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.blue.shade50,

                borderRadius:
                BorderRadius.circular(
                  6,
                ),
              ),

              // child: Text(
              //   'Tháng ${widget.thang}/${widget.nam}',
              //
              //   style:
              //   TextStyle(
              //     fontSize: 13,
              //     color:
              //     Colors.blue.shade700,
              //     fontWeight:
              //     FontWeight.w600,
              //   ),
              // ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final maxWidth =
          constraints.maxWidth >
              1000
              ? 900.0
              : constraints.maxWidth;

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              24,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints:
                BoxConstraints(
                  maxWidth:
                  maxWidth,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

                  children: [
                    _buildEmployeeCard(),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPLOYEE CARD
  // ============================================================

  Widget _buildEmployeeCard() {
    return Container(
      padding:
      const EdgeInsets.all(
        20,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          12,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFE5E7EB,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration:
            BoxDecoration(
              color:
              Colors.blue.shade50,

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child:
            const Icon(
              Icons
                  .person_outline,
              color:
              Colors.blue,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  widget.hoTen
                      ?.isNotEmpty ==
                      true
                      ? widget.hoTen!
                      : 'Chưa có tên nhân viên',

                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Row(
                  children: [
                    Icon(
                      Icons
                          .location_on_outlined,
                      size: 16,
                      color:
                      Colors.grey
                          .shade600,
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Flexible(
                      child: Text(
                        widget.tenCongTrinh
                            ?.isNotEmpty ==
                            true
                            ? widget
                            .tenCongTrinh!
                            : 'Chưa có công trình',

                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        TextStyle(
                          fontSize: 14,
                          color:
                          Colors.grey
                              .shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==================================
          // KỲ LƯƠNG
          // ==================================

          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            decoration:
            BoxDecoration(
              color:
              Colors.blue.shade50,

              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons
                      .calendar_month_outlined,
                  size: 17,
                  color:
                  Colors.blue,
                ),

                const SizedBox(
                  width: 6,
                ),

                // Text(
                //   'Tháng ${widget.thang}/${widget.nam}',
                //
                //   style:
                //   const TextStyle(
                //     color:
                //     Colors.blue,
                //     fontWeight:
                //     FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard() {
    final isEdit =
        widget.ul != null;

    return Container(
      padding:
      const EdgeInsets.all(
        24,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          12,
        ),

        border:
        Border.all(
          color:
          const Color(
            0xFFE5E7EB,
          ),
        ),
      ),

      child: Form(
        key:
        _formKey,

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,

          children: [
            const Text(
              'Thông tin khoản ứng',

              style:
              TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            // Text(
            //   'Khoản ứng thuộc kỳ lương '
            //       'tháng ${widget.thang}/${widget.nam}',
            //
            //   style:
            //   TextStyle(
            //     fontSize: 13,
            //     color:
            //     Colors.grey
            //         .shade600,
            //   ),
            // ),
            //
            // const SizedBox(
            //   height: 24,
            // ),

            // ==========================================
            // SỐ TIỀN + NGÀY
            // ==========================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Expanded(
                  child:
                  _buildMoneyField(),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child:
                  _buildDateField(),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // ==========================================
            // LÝ DO
            // ==========================================

            _buildReasonField(),

            const SizedBox(
              height: 28,
            ),

            const Divider(),

            const SizedBox(
              height: 16,
            ),

            // ==========================================
            // BUTTON
            // ==========================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .end,

              children: [
                OutlinedButton(
                  onPressed:
                  isLoading
                      ? null
                      : () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                  OutlinedButton
                      .styleFrom(
                    minimumSize:
                    const Size(
                      110,
                      44,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),

                  child:
                  const Text(
                    'Hủy',
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                FilledButton.icon(
                  onPressed:
                  isLoading
                      ? null
                      : _save,

                  icon: isLoading
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
                      : Icon(
                    isEdit
                        ? Icons
                        .save_outlined
                        : Icons
                        .check,
                  ),

                  label: Text(
                    isEdit
                        ? 'Cập nhật'
                        : 'Lưu khoản ứng',
                  ),

                  style:
                  FilledButton
                      .styleFrom(
                    minimumSize:
                    const Size(
                      150,
                      44,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        8,
                      ),
                    ),
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
  // MONEY
  // ============================================================

  Widget _buildMoneyField() {
    return TextFormField(
      controller:
      soTienCtrl,

      keyboardType:
      TextInputType.number,

      inputFormatters: [
        FilteringTextInputFormatter
            .digitsOnly,

        CurrencyInputFormatter(),
      ],

      decoration:
      InputDecoration(
        labelText:
        'Số tiền',

        hintText:
        'Nhập số tiền ứng',

        prefixIcon:
        const Icon(
          Icons
              .account_balance_wallet_outlined,
        ),

        suffixText:
        'VNĐ',

        filled: true,

        fillColor:
        const Color(
          0xFFF9FAFB,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFD1D5DB,
            ),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Colors.blue,
            width: 2,
          ),
        ),
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Nhập số tiền';
        }

        final amount =
        parseCurrency(
          value,
        );

        if (amount <= 0) {
          return 'Số tiền phải lớn hơn 0';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateField() {
    return TextFormField(
      controller:
      ngayCtrl,
      readOnly: true,
      onTap: isLoading ? null: _pickDate,
      decoration:
      InputDecoration(
        labelText:
        'Ngày ứng',
        hintText:
        'Chọn ngày ứng',
        prefixIcon:
        const Icon(
          Icons
              .calendar_today_outlined,
        ),

        suffixIcon:
        const Icon(
          Icons
              .keyboard_arrow_down,
        ),

        filled: true,

        fillColor:
        const Color(
          0xFFF9FAFB,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFD1D5DB,
            ),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Colors.blue,
            width: 2,
          ),
        ),
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Chọn ngày ứng';
        }

        return null;
      },
    );
  }

  // ============================================================
  // REASON
  // ============================================================

  Widget _buildReasonField() {
    return TextFormField(
      controller:
      lyDoCtrl,
      maxLines: 4,
      decoration:
      InputDecoration(
        labelText:
        'Lý do ứng lương',
        hintText:
        'Nhập lý do ứng lương...',

        alignLabelWithHint:
        true,

        prefixIcon:
        const Padding(
          padding:
          EdgeInsets.only(
            bottom: 48,
          ),

          child: Icon(
            Icons
                .description_outlined,
          ),
        ),

        filled: true,

        fillColor:
        const Color(
          0xFFF9FAFB,
        ),

        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFD1D5DB,
            ),
          ),
        ),

        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            8,
          ),

          borderSide:
          const BorderSide(
            color:
            Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }
}