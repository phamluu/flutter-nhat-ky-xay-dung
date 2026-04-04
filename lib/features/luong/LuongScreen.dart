import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/viewmodel/BangLuong.dart';

import '../../core/utils/currencyFormat.dart';
import '../../data/models/NhanVienCongTrinh.dart';
import '../../services/nhan_vien_cong_trinh_service.dart';

class LuongNhanVienScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const LuongNhanVienScreen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<LuongNhanVienScreen> createState() => _LuongNhanVienScreenState();
}

class _LuongNhanVienScreenState extends State<LuongNhanVienScreen> {
  late final NhanVienCongTrinhService _service;
  late Future<List<BangLuong>> _future;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _service = NhanVienCongTrinhService();
    _reload();
  }
  void _reload() {
    _future = Future.value([
      BangLuong(
        idCongTrinh: 1,
        idNhanVienCongTrinh: 1,
        hoTen: "Nguyễn Văn A",
        tongSoCong: 25,
        tongLuong: 5000000 ,
        ungLuong: 2000000,
        thucNhan: 3000000,
        trangThai: 0,
        thang: 4,
        nam: 2026
      ),
      BangLuong(
        idCongTrinh: 1,
        idNhanVienCongTrinh: 2,
        hoTen: "Trần Văn B",
        tongSoCong: 22,
        tongLuong: 4500000,
        ungLuong: 1000000,
        thucNhan: 3500000,
        trangThai: 0,
        thang: 3,
        nam:2026
      ),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // foregroundColor: Colors.black,
        // elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bảng lương",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.idCongTrinh != null)
              Text(
                widget.tenCongTrinh ?? "",
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(), // 👈 thêm ở đây

          Expanded(
            child: FutureBuilder<List<BangLuong>>(
              future: _future,
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (data.isEmpty) {
                  return const Center(child: Text("Không có dữ liệu"));
                }

                final isTablet =
                    MediaQuery.of(context).size.width > 600;

                return isTablet
                    ? _buildTable(data)
                    : _buildCardList(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<BangLuong> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text("Nhân viên")),
          DataColumn(label: Text("Công")),
          DataColumn(label: Text("Ứng")),
          DataColumn(label: Text("Lương")),
          DataColumn(label: Text("Thực nhận")),
          DataColumn(label: Text("Trạng thái")),
          DataColumn(label: Text("")),
        ],
        rows: data.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.hoTen ?? "")),
            DataCell(Text("${item.tongSoCong ?? 0}")),
            DataCell(Text("${item.ungLuong ?? 0} đ")),
            DataCell(Text("${item.tongLuong ?? 0} đ")),
            DataCell(
              Text(
                "${item.thucNhan ?? 0} đ",
                style: const TextStyle(color: Colors.green),
              ),
            ),
            DataCell(
              Text(
                item.trangThai == 1 ? "Đã chốt" : "Chưa chốt",
                style: TextStyle(
                  color: item.trangThai == 1 ? Colors.green : Colors.red,
                ),
              ),
            ),
            DataCell(
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Chốt"),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildCardList(List<BangLuong> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index + 1}. ${item.hoTen ?? ""}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Tổng công: ${item.tongSoCong}"),
                Text("Đã ứng: ${formatCurrency(item.ungLuong ?? 0)}"),
                Text("Tổng lương: ${formatCurrency(item.tongLuong ?? 0)}"),

                const SizedBox(height: 6),

                Text(
                  "Thực nhận: ${formatCurrency(item.thucNhan ?? 0)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.trangThai == 1 ? "Đã chốt" : "Chưa chốt",
                      style: TextStyle(
                        color: item.trangThai == 1
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Chốt"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // THÁNG
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: "Tháng",
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) {
                final month = index + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text("Tháng $month"),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          // NĂM
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: "Năm",
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - 2 + index;
                return DropdownMenuItem(
                  value: year,
                  child: Text("$year"),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
          ),

          const SizedBox(width: 8),

          // NÚT TÍNH LƯƠNG
          ElevatedButton(
            onPressed: _tinhLuong,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              backgroundColor: Colors.blue,
            ),
            child: const Text("Tính lương"),
          ),
        ],
      ),
    );
  }

  void _tinhLuong() {
    print("Tính lương tháng $_selectedMonth năm $_selectedYear");

    // TODO: gọi API
    // _future = _service.tinhLuong(_selectedMonth, _selectedYear);

    setState(() {
      _reload(); // demo lại data
    });
  }
}
