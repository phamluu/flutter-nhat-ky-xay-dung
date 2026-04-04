import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_cham_cong.dart';
import '../../../services/cham_cong_service.dart';
import '../../../viewmodel/ChamCongModel.dart';

class ChamCong2Screen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const ChamCong2Screen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<ChamCong2Screen> createState() => _ChamCong2ScreenState();
}

class _ChamCong2ScreenState extends State<ChamCong2Screen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<ChamCongModel> data = [];

  final ChamCongService _service = ChamCongService(); // bạn gán db của bạn vào đây

  int get soNgay =>
      DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
  final ScrollController _verticalController = ScrollController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.idCongTrinh == null) return;

    final result = await _service.loadChamCong(
         widget.idCongTrinh!, _selectedMonth, _selectedYear);

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sổ chấm công"),
            Text(widget.tenCongTrinh ?? "",
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilter(),
          Row(
            children: [
              DataTable(
                columnSpacing: 10,
                border: TableBorder.all(color: Colors.grey),
                headingRowColor: MaterialStateProperty.all(Colors.green.shade300),
                columns: [DataColumn(label: Text("Họ tên"))],
                rows: List.generate(data.length, (index) {
                  final nv = data[index];
                  return DataRow(
                      cells: [
                      DataCell(Text(nv.ten)),],
                  );
                }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 10,
                      border: TableBorder.all(color: Colors.grey),
                      headingRowColor: MaterialStateProperty.all(Colors.green.shade300),
                      columns: _buildColumns(),
                      rows: _buildRows(),
                    ),
                  ),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  Widget _buildFixedColumn() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.grey.shade200,
          child: const Text(
            "Họ tên",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        Column( // 👈 đổi từ ListView → Column
          children: List.generate(data.length, (index) {
            final nv = data[index];

            return Container(
              width: 140,
              height: 36,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(nv.ten),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildScrollableTable() {
    return SingleChildScrollView( // 👈 thêm dòng này
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const SizedBox(width: 100, child: Text("Chức vụ")),

              ...List.generate(soNgay, (i) {
                return SizedBox(
                  width: 35,
                  child: Center(child: Text("${i + 1}")),
                );
              }),

              const SizedBox(width: 60, child: Text("Tổng")),
            ],
          ),

          // DATA
          Column(
            children: List.generate(data.length, (index) {
              final nv = data[index];

              return Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(nv.chucVu),
                  ),

                  ...List.generate(soNgay, (i) {
                    final day = i + 1;

                    final ngay =
                        "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

                    final cc = nv.data[ngay];

                    return SizedBox(
                      width: 35,
                      child: Center(child: Text(cc?.hienThi ?? "")),
                    );
                  }),

                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        (nv.tongSoCong ?? 0).toStringAsFixed(1),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  // ===== FILTER =====
  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(labelText: "Tháng"),
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem(
                  value: m,
                  child: Text("Tháng $m"),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
                _load();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(labelText: "Năm"),
              items: List.generate(5, (i) {
                final y = DateTime.now().year - 2 + i;
                return DropdownMenuItem(
                  value: y,
                  child: Text("$y"),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
                _load();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== COLUMNS =====
  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [
      const DataColumn(label: Text("Chức vụ")),
    ];
    for (int i = 1; i <= soNgay; i++) {
      columns.add(DataColumn(label: Text("$i")));
    }
    columns.add(const DataColumn(label: Text("Tổng công")));
    columns.add(const DataColumn(label: Text("Tiền công")));
    columns.add(const DataColumn(label: Text("Tổng lương")));
    columns.add(const DataColumn(label: Text("Đã ứng")));
    columns.add(const DataColumn(label: Text("Thực nhận")));
    return columns;
  }

  // ===== ROWS =====
  List<DataRow> _buildRows() {
    return List.generate(data.length, (index) {
      final nv = data[index];
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (index % 2 == 0) {
              return Colors.grey.shade200; // dòng chẵn
            }
            return Colors.white; // dòng lẻ
          },
        ),
        cells: [
          DataCell(Text(nv.chucVu)),
          ...List.generate(soNgay, (index) {
            final ngay =
                "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${(index + 1).toString().padLeft(2, '0')}";
            final cc = nv.data[ngay];
            return DataCell(
              SizedBox(
                width: 35,
                height: 30,
                child: Center(
                  child: Text(cc?.hienThi ?? ""),
                ),
              ),
            );
          }),
          DataCell(
            Text(
              (nv.tongSoCong ?? 0).toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(Text(formatCurrency(nv.luongCoBan ?? 0))),
          DataCell(Text(formatCurrency(nv.tongLuong))),
          DataCell(Text(formatCurrency(nv.daUng ))),
          DataCell(Text(formatCurrency(nv.thucNhan ))),
        ],
      );
    }).toList();
  }

  // ===== HIỂN THỊ =====
  String hienThiChamCong(dynamic cc) {
    if (cc == null) return "...";
    double cong = 0;
    final sang = TrangThaiChamCong.fromValue(cc['sang']);
    final chieu = TrangThaiChamCong.fromValue(cc['chieu']);
    // Cả ngày
    if (sang == TrangThaiChamCong.coMat &&
        chieu == TrangThaiChamCong.coMat) {
      return "X";
    }
    if (sang == TrangThaiChamCong.coMat ||
        chieu == TrangThaiChamCong.coMat) {
      return "/";
    }
    if (sang == TrangThaiChamCong.khongXacDinh &&
        chieu == TrangThaiChamCong.khongXacDinh) {
      return "...";
    }
    return "0";
  }
}