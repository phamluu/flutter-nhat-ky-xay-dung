import 'package:flutter/material.dart';

import '../../../../core/utils/currencyFormat.dart';
import '../../../../data/models/ChiLuong.dart';
import '../../../../data/repositories/ChiLuongRepository.dart';
import '../../../../services/ChiLuongService.dart';


class ChiLuongDesktop extends StatefulWidget {
  final int idBangLuong;

  /// Tên nhân viên
  final String? tenNhanVien;

  /// Tổng tiền phải trả
  final double tongPhaiTra;

  /// Tháng lương
  final int thang;

  /// Năm lương
  final int nam;

  /// Tên công trình
  final String? tenCongTrinh;

  const ChiLuongDesktop({
    super.key,
    required this.idBangLuong,
    this.tenNhanVien,
    required this.tongPhaiTra,
    required this.thang,
    required this.nam,
    this.tenCongTrinh,
  });

  @override
  State<ChiLuongDesktop> createState() => _ChiLuongDesktopState();
}

class _ChiLuongDesktopState extends State<ChiLuongDesktop> {
  late ChiLuongService _service;

  final TextEditingController _tienCtrl =
  TextEditingController();

  final TextEditingController _noteCtrl =
  TextEditingController();

  List<ChiLuongModel> lichSu = [];

  double daChi = 0;

  bool loading = false;

  bool loadingData = false;

  double get conLai {
    final value =
        widget.tongPhaiTra - daChi;

    return value < 0 ? 0 : value;
  }

  @override
  void initState() {
    super.initState();

    _service = ChiLuongService(
      ChiLuongRepository(),
    );

    _load();
  }

  @override
  void dispose() {
    _tienCtrl.dispose();
    _noteCtrl.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loadingData = true;
      });
    }

    try {
      final ls =
      await _service.getLichSu(
        widget.idBangLuong,
      );

      final tong =
      await _service.getTongDaChi(
        widget.idBangLuong,
      );

      if (!mounted) return;

      setState(() {
        lichSu = ls;

        daChi = tong;

        loadingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingData = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Không thể tải lịch sử chi lương: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CHI LƯƠNG
  // ============================================================

  Future<void> _submit() async {
    final tien = double.tryParse(
      _tienCtrl.text
          .replaceAll(',', '')
          .replaceAll('.', ''),
    ) ??
        0;

    if (tien <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng nhập số tiền hợp lệ",
          ),
        ),
      );

      return;
    }

    if (tien > conLai) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Số tiền chi vượt quá số tiền còn lại",
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _service.chiLuong(
        idBangLuong: widget.idBangLuong,
        soTien: tien,
        ghiChu: _noteCtrl.text.trim(),
      );

      _tienCtrl.clear();

      _noteCtrl.clear();

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Chi lương thành công",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Chi lương thất bại: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteChiLuong(
      ChiLuongModel item,
      ) async {
    final confirm =
    await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Xác nhận xóa",
          ),
          content: Text(
            "Bạn có chắc muốn xóa khoản chi "
                "${formatCurrency(item.soTien)}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  false,
                );
              },
              child: const Text(
                "Hủy",
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  ctx,
                  true,
                );
              },
              child: const Text(
                "Xóa",
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await _service.deleteChiLuong(
        item.id!,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Đã xóa khoản chi lương",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Xóa thất bại: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xfff5f6f8),

      appBar: AppBar(
        elevation: 0,

        title: const Text(
          "Chi lương",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final width =
              constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 1500,
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    _buildHeader(),

                    const SizedBox(
                      height: 20,
                    ),

                    // CONTENT
                    Expanded(
                      child: width >= 1050
                          ? Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          SizedBox(
                            width: 370,
                            child:
                            _buildPaymentForm(),
                          ),

                          const SizedBox(
                            width: 20,
                          ),

                          Expanded(
                            child:
                            _buildHistory(),
                          ),
                        ],
                      )
                          : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildPaymentForm(),

                            const SizedBox(
                              height: 20,
                            ),

                            SizedBox(
                              height: 550,
                              child:
                              _buildHistory(),
                            ),
                          ],
                        ),
                      ),
                    ),
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Card(
      elevation: 0,

      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ICON
            Container(
              width: 58,
              height: 58,

              decoration:
              BoxDecoration(
                color:
                Colors.blue.withOpacity(
                  .1,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: const Icon(
                Icons
                    .payments_outlined,
                color: Colors.blue,
                size: 32,
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            // THÔNG TIN
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    "CHI LƯƠNG THÁNG "
                        "${widget.thang}/${widget.nam}",

                    style:
                    const TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // CÔNG TRÌNH
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .business_outlined,
                        size: 19,
                        color:
                        Colors.grey,
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      const Text(
                        "Công trình:",
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontWeight:
                          FontWeight
                              .w500,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Flexible(
                        child: Text(
                          widget.tenCongTrinh ??
                              "Chưa xác định",

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .w600,
                          ),

                          overflow:
                          TextOverflow
                              .ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  // NHÂN VIÊN
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .person_outline,
                        size: 19,
                        color:
                        Colors.grey,
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      const Text(
                        "Nhân viên:",
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontWeight:
                          FontWeight
                              .w500,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        widget.tenNhanVien ??
                            "Chưa xác định",

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 30,
            ),

            // TỔNG PHẢI TRẢ
            _buildMoneyInfo(
              title:
              "Tổng phải trả",
              value:
              widget.tongPhaiTra,
              color:
              Colors.blue,
            ),

            const SizedBox(
              width: 35,
            ),

            // ĐÃ CHI
            _buildMoneyInfo(
              title: "Đã chi",
              value: daChi,
              color:
              Colors.orange,
            ),

            const SizedBox(
              width: 35,
            ),

            // CÒN LẠI
            _buildMoneyInfo(
              title: "Còn lại",
              value: conLai,
              color:
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONEY INFO
  // ============================================================

  Widget _buildMoneyInfo({
    required String title,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.end,

      children: [
        Text(
          title,

          style:
          const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          formatCurrency(value),

          style: TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORM CHI LƯƠNG
  // ============================================================

  Widget _buildPaymentForm() {
    return Card(
      elevation: 0,

      child: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Row(
              children: [
                Icon(
                  Icons
                      .payments_outlined,
                  color: Colors.blue,
                ),

                SizedBox(
                  width: 8,
                ),

                Text(
                  "Thực hiện chi lương",
                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // CÒN LẠI
            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.green
                    .withOpacity(.08),

                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  const Text(
                    "Số tiền còn lại",

                    style:
                    TextStyle(
                      color:
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    formatCurrency(
                      conLai,
                    ),

                    style:
                    const TextStyle(
                      fontSize: 23,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // SỐ TIỀN
            TextField(
              controller:
              _tienCtrl,

              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),

              decoration:
              const InputDecoration(
                labelText:
                "Số tiền",

                hintText:
                "Nhập số tiền cần chi",

                prefixIcon:
                Icon(
                  Icons
                      .attach_money,
                ),

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // GHI CHÚ
            TextField(
              controller:
              _noteCtrl,

              maxLines: 3,

              decoration:
              const InputDecoration(
                labelText:
                "Ghi chú",

                hintText:
                "Ví dụ: Tạm ứng, chi lương...",

                prefixIcon:
                Padding(
                  padding:
                  EdgeInsets.only(
                    bottom: 45,
                  ),

                  child: Icon(
                    Icons.notes,
                  ),
                ),

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // BUTTON
            SizedBox(
              width:
              double.infinity,

              height: 46,

              child:
              ElevatedButton.icon(
                onPressed:
                loading ||
                    conLai <= 0
                    ? null
                    : _submit,

                icon: loading
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
                  Icons.check,
                ),

                label: Text(
                  loading
                      ? "Đang xử lý..."
                      : conLai <= 0
                      ? "Đã chi đủ"
                      : "Chi lương",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LỊCH SỬ CHI
  // ============================================================

  Widget _buildHistory() {
    return Card(
      elevation: 0,

      clipBehavior:
      Clip.antiAlias,

      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.blue,
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  "Lịch sử chi lương",
                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  "${lichSu.length} lần chi",

                  style:
                  const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                IconButton(
                  tooltip:
                  "Tải lại",

                  onPressed:
                  loadingData
                      ? null
                      : _load,

                  icon:
                  const Icon(
                    Icons.refresh,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          Expanded(
            child: loadingData
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : lichSu.isEmpty
                ? _buildEmptyHistory()
                : _buildHistoryTable(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyHistory() {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            Icons
                .receipt_long_outlined,
            size: 55,
            color: Colors.grey,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            "Chưa có lịch sử chi lương",

            style:
            TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATA TABLE
  // ============================================================

  Widget _buildHistoryTable() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,

        child: DataTable(
          headingRowHeight:
          50,

          dataRowMinHeight:
          58,

          dataRowMaxHeight:
          70,

          columnSpacing:
          35,

          columns: const [
            DataColumn(
              label: Text(
                "STT",
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            DataColumn(
              label: Text(
                "Ngày chi",
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            DataColumn(
              label: Text(
                "Số tiền",
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            DataColumn(
              label: Text(
                "Ghi chú",
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            DataColumn(
              label: Text(
                "Thao tác",
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],

          rows:
          List.generate(
            lichSu.length,
                (index) {
              final item =
              lichSu[index];

              return DataRow(
                cells: [
                  // STT
                  DataCell(
                    Text(
                      "${index + 1}",
                    ),
                  ),

                  // NGÀY
                  DataCell(
                    Text(
                      "${item.ngayChi.day.toString().padLeft(2, '0')}/"
                          "${item.ngayChi.month.toString().padLeft(2, '0')}/"
                          "${item.ngayChi.year}",
                    ),
                  ),

                  // SỐ TIỀN
                  DataCell(
                    Text(
                      formatCurrency(
                        item.soTien,
                      ),

                      style:
                      const TextStyle(
                        color:
                        Colors.green,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ),

                  // GHI CHÚ
                  DataCell(
                    SizedBox(
                      width: 260,

                      child: Text(
                        item.ghiChu
                            ?.isNotEmpty ==
                            true
                            ? item
                            .ghiChu!
                            : "Không có ghi chú",

                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ),
                  ),

                  // XÓA
                  DataCell(
                    IconButton(
                      tooltip:
                      "Xóa khoản chi",

                      onPressed:
                          () {
                        _deleteChiLuong(
                          item,
                        );
                      },

                      icon:
                      const Icon(
                        Icons
                            .delete_outline,
                        color:
                        Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}