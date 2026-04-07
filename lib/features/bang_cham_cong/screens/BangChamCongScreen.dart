import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/screens/UngLuongScreen.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_cham_cong.dart';
import '../../../services/cham_cong_service.dart';
import '../../../viewmodel/ChamCongModel.dart';
import 'ChamCongNgayScreen.dart';

class ChamCong2Screen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const ChamCong2Screen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<ChamCong2Screen> createState() => _ChamCong2ScreenState();
}

class _ChamCong2ScreenState extends State<ChamCong2Screen> {
  bool _showTen = true;
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

              if (_showTen)
                DataTable(
                  columnSpacing: 10,
                  border: TableBorder.all(color: Colors.grey),
                  headingRowColor:
                  MaterialStateProperty.all(Colors.green.shade300),
                  columns: const [
                    DataColumn(label: Text("Họ tên")),
                  ],
                  rows: List.generate(data.length, (index) {
                    final nv = data[index];
                    return DataRow(
                      cells: [
                        DataCell(Text(nv.ten)),
                      ],
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
      DataColumn(
          label: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTen = !_showTen;
                  });
                },
                child: Container(
                  width: 20,
                  height: 50,
                  alignment: Alignment.center,
                  // color: Colors.grey.shade200,
                  child: Icon(
                    _showTen ? Icons.chevron_left : Icons.chevron_right,
                    size: 25,
                  ),
                ),
              ),
              const Text("Chức vụ")
            ],
          )

      ),
    ];
    for (int i = 1; i <= soNgay; i++) {
      columns.add(DataColumn(label: Text("$i")));
    }
    columns.add(const DataColumn(label: Text("Tổng công")));
    columns.add(const DataColumn(label: Text("Tổng lương")));
    columns.add(const DataColumn(label: Text("Đã ứng")));
    columns.add(const DataColumn(label: Text("Thực nhận")));
    columns.add(const DataColumn(label: Text("Trạng thái")));
    columns.add(const DataColumn(label: Text("Hành động")));
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
              SizedBox(width: 35, height: 30,
                child: Center(
                  child: Text(cc?.chamCong.hienThi ?? ""),
                ),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChamCongNgayScreen(
                      idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
                      ngay: ngay,
                      hoTen: nv.ten,
                      tenCongTrinh: widget.tenCongTrinh,
                    ),
                  ),
                ).then((_) {
                  _load();
                });
              },
            );
          }),
          DataCell(
            Text(
              (nv.tongSoCong ?? 0).toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataCell(Text(formatCurrency(nv.tongTienCong))),
          DataCell(
              SizedBox(
                child: Center(
                  child: Text(formatCurrency(nv.tongUng )),
                ),
              ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UngLuongScreen(
                    idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
                    hoTen: nv.ten,
                    congTrinh: widget.tenCongTrinh,
                    thang: _selectedMonth
                  ),
                ),
              ).then((_) {
                _load();
              });
            },
          ),
          DataCell(Text(formatCurrency(nv.thucNhan ))),
          DataCell(Text('Đã chốt')),
          DataCell(
            GestureDetector(
              onTap: () {
                // xử lý chi lương
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.payments, size: 12, color: Colors.green),
                    SizedBox(width: 3),
                    Text(
                      "Chi",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

}