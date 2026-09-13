// Danh sách ứng lương trong 1 tháng
// của tất cả nhân viên công trình - Desktop

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/repositories/ung_luong_repository.dart';

import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';
import 'ung_luong_nhan_vien_desktop.dart';

class UngLuongListDesktop extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  final int? idBangChamCong;
  const UngLuongListDesktop({
    super.key,
    required this.idCongTrinh,
    this.idBangChamCong,
    this.tenCongTrinh,
  });
  @override
  State<UngLuongListDesktop> createState() => _UngLuongListDesktopState();
}

class _UngLuongListDesktopState extends State<UngLuongListDesktop> {
  final UngLuongRepository service = UngLuongRepository();
  // int thang = DateTime.now().month;
  // int nam = DateTime.now().year;
  List<UngLuongViewModel> data = [];
  String? kyLuong;
  List<Map<String, dynamic>> kyLuongs = [];
  bool _isLoading = false;
  final ScrollController _verticalScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    loadData();
  }
  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }
  Future<void> loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await service.getDanhSach(widget.idCongTrinh, kyLuong: kyLuong);
      final search = await service.getKyLuongs(widget.idCongTrinh);
      if (!mounted) return;
      setState(() {
        data = result;
        kyLuongs = search;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showErrorToast(context, e,  "Không thể tải danh sách ứng lương: ");

    }
  }
  num get tongTienUng {
    return data.fold<num>(
      0,
          (sum, item) => sum + (item?.tongUng ?? 0),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
          title: _buildHeader(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    final tenCongTrinh =
    widget.tenCongTrinh?.trim();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
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
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.10),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: Colors.orange.shade700,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  "Danh sách ứng lương công trình",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenCongTrinh?.isNotEmpty == true
                      ? tenCongTrinh!
                      : "Quản lý tiền ứng của nhân viên",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // THÁNG
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Tháng $kyLuong",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // REFRESH
          OutlinedButton.icon(
            onPressed:
            _isLoading ? null : loadData,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const Text("Làm mới"),
          ),
        ],
      ),
    );
  }
  Widget _buildBody() {
    return Column(
      children: [
        // FILTER
        Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            0,
          ),
          child: _buildFilterCard(),
        ),

        const SizedBox(height: 14),

        // SUMMARY
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: _buildSummary(),
        ),

        const SizedBox(height: 14),

        // TABLE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24,
            ),
            child: _buildTableCard(),
          ),
        ),
      ],
    );
  }
  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // ICON
          Container(width: 40,height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon( Icons.filter_alt_outlined,color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          const Text("Bộ lọc", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15 ),
          ),
          const SizedBox(width: 24),
          _buildDropdown<String?>(
            width: 260,
            icon: Icons.calendar_month_outlined,
            label: "Kỳ lương",
            value: kyLuong,
            items: [
              null,
              ...kyLuongs
                  .map((e) => e['value']?.toString())
                  .whereType<String>(),
            ],
            itemLabel: (value) {
              if (value == null) {
                return "Tất cả kỳ lương";
              }
              for (final item in kyLuongs) {
                if (item['value']?.toString() == value) {
                  return item['label']?.toString() ?? value;
                }
              }
              return value;
            },
            onChanged: (value) {
              setState(() {
                kyLuong = value;
              });
              loadData();
            },
          ),
          const Spacer(),
          // THÔNG TIN THỜI GIAN
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.08),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 17,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 7),
                Text(
                  "Kỳ ứng: ${kyLuong ?? 'Cả công trình'}",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown<T>({
    required double width,
    required IconData icon,
    required String label,
    required T value,
    required List<T> items,
    required String Function(T value) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
          BorderRadius.circular(9),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
            ),
            items: items.map(
                  (item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 17,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        itemLabel(item),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.people_alt_outlined,
            title: "Nhân viên",
            value: "${data.length}",
            subtitle:
            "Nhân viên có dữ liệu ứng lương",
            iconColor: Colors.blue,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.payments_outlined,
            title: "Tổng tiền ứng",
            value: formatCurrency(tongTienUng),
            subtitle:
            "Tổng tiền đã ứng trong tháng",
            iconColor: Colors.orange,
            valueColor:
            Colors.orange.shade800,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.calendar_month_outlined,
            title: "Kỳ lương",
            value: '${kyLuong ?? 'Cả công trình'}',
            subtitle:
            "Tháng đang xem dữ liệu",
            iconColor: Colors.green,
            valueColor:
            Colors.green.shade700,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _summaryCard(
            icon: Icons.account_balance_wallet_outlined,
            title: "Trạng thái",
            value: _isLoading
                ? "Đang tải"
                : "Đã tải",
            subtitle:
            "Trạng thái dữ liệu",
            iconColor: Colors.purple,
            valueColor:
            Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.08),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                    color: valueColor,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE CARD
  // ============================================================

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // TABLE HEADER
          _buildTableHeader(),

          const Divider(height: 1),

          // TABLE
          Expanded(
            child: _isLoading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : data.isEmpty
                ? _buildEmptyTable()
                : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Bảng ứng lương",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Theo dõi số tiền ứng của nhân viên trong tháng",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // TOTAL
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.08),
              borderRadius:
              BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 17,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 7),
                Text(
                  formatCurrency(tongTienUng),
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // REFRESH
          IconButton(
            tooltip: "Làm mới",
            onPressed:
            _isLoading ? null : loadData,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATA TABLE
  // ============================================================

  Widget _buildDataTable() {
    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 18,
            headingRowHeight: 48,
            dataRowMinHeight: 58,
            dataRowMaxHeight: 64,

            headingRowColor:
            MaterialStateProperty.resolveWith(
                  (_) => const Color(0xFFFFF3E0),
            ),

            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            columns: const [
              DataColumn(
                label: Text(
                  "STT",
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),

              DataColumn(
                label: SizedBox(
                  width: 320,
                  child: Text(
                    "HỌ TÊN NHÂN VIÊN",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              DataColumn(
                numeric: true,
                label: Text(
                  "TỔNG ỨNG",
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              DataColumn(
                numeric: true,
                label: Text(
                  "ĐÃ ĐỐI TRỪ",
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "THAO TÁC",
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            rows: _buildRows(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ROWS
  // ============================================================

  List<DataRow> _buildRows() {
    return List.generate(
      data.length,
          (index) {
        final item = data[index];
        return DataRow(
          color:
          MaterialStateProperty.resolveWith(
                (_) {
              return index.isEven
                  ? Colors.grey.shade50
                  : Colors.white;
            },
          ),
          cells: [
            // STT
            DataCell(
              SizedBox(
                width: 45,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ),

            // HỌ TÊN
            DataCell(
              SizedBox(
                width: 320,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                        Colors.blue.withOpacity(.08),
                        shape: BoxShape.circle,
                      ),
                      alignment:
                      Alignment.center,
                      child: Text(
                        _getInitial(
                          item.hoTen,
                        ),
                        style: TextStyle(
                          color:
                          Colors.blue.shade700,
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        item.hoTen ?? "---",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TỔNG ỨNG
            DataCell(
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                  Colors.orange.withOpacity(.08),
                  borderRadius:
                  BorderRadius.circular(7),
                ),
                child: Text(
                  formatCurrency(item.tongUng),
                  style: TextStyle(
                    color:
                    Colors.orange.shade800,
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            // ĐÃ ĐỐI TRỪ
            DataCell(
              item.tongDoiTru != null && item.tongDoiTru != 0
                  ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  formatCurrency(item.tongDoiTru!),
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            // ACTION
            DataCell(
              OutlinedButton.icon(
                onPressed: () =>
                    _openUngLuong(item),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                ),
                label: const Text(
                  "Chi tiết",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // OPEN DETAIL
  // ============================================================

  Future<void> _openUngLuong(
      UngLuongViewModel item,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UngLuongNhanVienDesktop(
          idNhanVienCongTrinh:
          item.idNhanVienCongTrinh,
          hoTen: item.hoTen,
          congTrinh: widget.tenCongTrinh,
          idBangChamCong: widget.idBangChamCong,
          kyLuong: kyLuong,
        ),
      ),
    );

    await loadData();
  }

  // ============================================================
  // INITIAL
  // ============================================================

  String _getInitial(String? name) {
    if (name == null ||
        name.trim().isEmpty) {
      return "?";
    }

    final parts =
    name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) {
      return "?";
    }

    return parts.last
        .substring(
      0,
      1,
    )
        .toUpperCase();
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyTable() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .account_balance_wallet_outlined,
              size: 34,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            "Chưa có dữ liệu ứng lương",
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Không tìm thấy dữ liệu ứng lương ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed:
            _isLoading ? null : loadData,
            icon: const Icon(
              Icons.refresh,
              size: 17,
            ),
            label:
            const Text("Làm mới"),
          ),
        ],
      ),
    );
  }
}