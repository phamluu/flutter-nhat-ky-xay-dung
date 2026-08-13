import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/desktop/luong_co_ban_nhan_vien_desktop.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/mobile/LuongCoBanNhanVien.dart';

import '../../../../services/luong_co_ban_service.dart';
import '../../../../viewmodel/LuongCoBan.dart';


class LuongCoBanDesktop extends StatefulWidget {
  const LuongCoBanDesktop({super.key});

  @override
  State<LuongCoBanDesktop> createState() => _LuongCoBanDesktopState();
}

class _LuongCoBanDesktopState extends State<LuongCoBanDesktop> {
  final LuongCoBanService _service = LuongCoBanService();

  final NumberFormat currencyFormat =
  NumberFormat("#,##0", "vi_VN");

  late Future<List<LuongCoBanModel>> _futureLuong;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureLuong = _service.getLuongCoBan();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    await _futureLuong;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<LuongCoBanModel>>(
                future: _futureLuong,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error);
                  }

                  final data = snapshot.data ?? [];

                  final filteredData = data.where((item) {
                    final name =
                    (item.hoTen ?? '').toLowerCase();

                    return name.contains(
                      _searchText.toLowerCase(),
                    );
                  }).toList();

                  return Column(
                    children: [
                      _buildSummary(data),

                      const SizedBox(height: 16),

                      Expanded(
                        child: _buildEmployeeTable(
                          filteredData,
                        ),
                      ),
                    ],
                  );
                },
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.payments_outlined,
            color: Colors.blue.shade700,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Lương cơ bản',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quản lý mức lương cơ bản của nhân viên',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 280,
          height: 42,
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm nhân viên...',
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        OutlinedButton.icon(
          onPressed: _refresh,
          icon: const Icon(
            Icons.refresh,
            size: 19,
          ),
          label: const Text('Làm mới'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue.shade700,
            backgroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            side: BorderSide(
              color: Colors.grey.shade300,
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
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      List<LuongCoBanModel> data,
      ) {
    double totalSalary = 0;

    for (final item in data) {
      totalSalary += item.luongHienTai ?? 0;
    }

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.people_outline,
            title: 'Nhân viên',
            value: '${data.length}',
            color: Colors.blue,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _summaryCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Tổng lương cơ bản',
            value:
            '${currencyFormat.format(totalSalary)} đ',
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _summaryCard(
            icon: Icons.payments_outlined,
            title: 'Lương trung bình',
            value: data.isEmpty
                ? '0 đ'
                : '${currencyFormat.format(
              totalSalary / data.length,
            )} đ',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              color: color.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

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

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff263238),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildEmployeeTable(
      List<LuongCoBanModel> data,
      ) {
    if (data.isEmpty) {
      return _buildEmpty();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(),

          const Divider(
            height: 1,
            thickness: 1,
          ),

          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) =>
                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
              itemBuilder: (context, index) {
                return _buildEmployeeRow(
                  data[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      color: const Color(0xfffafafa),
      child: const Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              'STT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              'NHÂN VIÊN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              'NGÀY SINH',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              'LƯƠNG HIỆN TẠI',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(
      LuongCoBanModel luong,
      int index,
      ) {
    return InkWell(
      onTap: () {
        _openEmployee(luong);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 55,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                      Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      luong.hoTen ??
                          'Không tên',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                luong.ngaySinh ??
                    'Chưa có ngày sinh',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                '${currencyFormat.format(
                  luong.luongHienTai ?? 0,
                )} đ',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 20),

            SizedBox(
              width: 60,
              child: IconButton(
                tooltip: 'Xem chi tiết',
                onPressed: () {
                  _openEmployee(luong);
                },
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // OPEN EMPLOYEE
  // ============================================================

  void _openEmployee(
      LuongCoBanModel luong,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LuongCoBanNhanVienDesktop(
              idNhanVien: luong.idNhanVien,
              hoTen: luong.hoTen,
            ),
      ),
    ).then((_) {
      _loadData();
      setState(() {});
    });
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),

            const SizedBox(height: 14),

            Text(
              _searchText.isNotEmpty
                  ? 'Không tìm thấy nhân viên'
                  : 'Chưa có nhân viên nào',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(Object? error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 12),

            const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '$error',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loadData();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}