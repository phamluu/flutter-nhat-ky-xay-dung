import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/ung_luong/screens/UngLuongScreen.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_luong.dart';
import '../../../data/repositories/ChamCongRepository.dart';
import '../../../data/repositories/ChotChiLuongRepository.dart';
import '../../../services/BangLuongService.dart';
import '../../../services/ChotChiLuongService.dart';
import '../../../services/cham_cong_service.dart';
import '../../../viewmodel/ChamCongModel.dart';
import '../../chi_luong/ChiLuongScreen.dart';
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
  bool _showChucVu = true;
  bool _show10Dau = true;
  bool _show10Giua = true;
  bool _show10Cuoi = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<ChamCongModel> data = [];
  late final BangLuongService _service;
  late final Chotchiluongservice _chotService;
  int get soNgay => DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
  final ScrollController _verticalController = ScrollController();
  @override
  void initState() {
    super.initState();
    // _service = ChamCongService(ChamCongRepository());
    _service = BangLuongService(
      chamCongService: ChamCongService(ChamCongRepository()),
      chotRepo: ChotChiLuongRepository(),
    );
    _chotService = Chotchiluongservice(ChotChiLuongRepository());
    _load();
  }

  Future<void> _load() async {
    if (widget.idCongTrinh == null) return;

    final result = await _service.loadLuong(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HÀNG 1: HỌ TÊN + CHỨC VỤ
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showTen = !_showTen;
                        });
                      },
                      icon: Icon(
                        _showTen ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue,
                      ),
                      label: Text(_showTen ? "Ẩn họ tên" : "Hiện họ tên"),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showChucVu = !_showChucVu;
                        });
                      },
                      icon: Icon(
                        _showChucVu ? Icons.badge_outlined : Icons.badge,
                        color: Colors.orange,
                      ),
                      label: Text(_showChucVu ? "Ẩn chức vụ" : "Hiện chức vụ"),
                    ),
                  ],
                ),

                const SizedBox(height: 1),

                /// HÀNG 2: FILTER NGÀY
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildToggle("1-10", _show10Dau, (v) {
                        setState(() => _show10Dau = v);
                      }),
                      const SizedBox(width: 10),
                      _buildToggle("11-20", _show10Giua, (v) {
                        setState(() => _show10Giua = v);
                      }),
                      const SizedBox(width: 10),
                      _buildToggle("21+", _show10Cuoi, (v) {
                        setState(() => _show10Cuoi = v);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (_showTen)
                DataTable(
                  columnSpacing: 10,
                  border: TableBorder.all(color: Colors.grey),
                  headingRowColor:
                      MaterialStateProperty.all(Colors.green.shade300),
                  columns: [
                    DataColumn(label: Text("Họ tên")),
                  ],
                  rows: List.generate(data.length, (index) {
                    final nv = data[index];
                    return DataRow(
                      cells: [
                        DataCell(Text(nv.ten ?? "")),
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
                      headingRowColor:
                          MaterialStateProperty.all(Colors.green.shade300),
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

  Widget _buildToggle(String text, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(text),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.shade100,
    );
  }

  bool _isShowNgay(int day) {
    if (day <= 10 && !_show10Dau) return false;
    if (day >= 11 && day <= 20 && !_show10Giua) return false;
    if (day >= 21 && !_show10Cuoi) return false;
    return true;
  }

  Color getColor(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      return Colors.red.shade300;
    }
    return Colors.transparent;
  }

  Future<void> _showConfirmChot(ChamCongModel nv) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Chốt lương cho ${nv.ten}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Chốt"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _chotService.chotLuong(
        nv: nv,
        thang: _selectedMonth,
        nam: _selectedYear,
      );

      setState(() {
        _load();
      });
    }
  }

  Future<void> _showConfirmHuyChot(int idBangLuong) async {
    final ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Hủy chốt lương"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hủy chốt"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _chotService.huyChot(
        idBangLuong: idBangLuong
      );
      setState(() {
        _load();
      });
    }
  }
  Widget _huyChotbtn(ChamCongModel nv) {
    return ElevatedButton(
      onPressed: () async {
        await _showConfirmHuyChot(nv.idBangLuong!);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // 👈 nhỏ lại
        minimumSize: const Size(0, 30), // 👈 chiều cao
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 👈 giảm vùng click
      ),
      child: const Text(
        "Hủy chốt",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  Widget _chiLuongbtn(ChamCongModel nv) {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChiLuongScreen(
              idBangLuong: nv.idBangLuong!,
              tenNhanVien: nv.ten,
              tongPhaiTra: nv.thucNhanHienThi ?? 0,
            ),
          ),
        );

        if (result == true) {
          setState(() {
            _load(); // reload lại data
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // 👈 nhỏ lại
        minimumSize: const Size(0, 30), // 👈 chiều cao
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 👈 giảm vùng click
      ),
      child: const Text(
        "Chi lương",
        style: TextStyle(color: Colors.white),
      ),
    );
  }



  // ===== COLUMNS =====
  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [
      if (_showChucVu)
        DataColumn(
            label: Row(
          children: [const Text("Chức vụ")],
        ))
    ];
    for (int i = 1; i <= soNgay; i++) {
      if (_isShowNgay(i)) {
        columns.add(DataColumn(label: Text("$i")));
      }
      // columns.add(DataColumn(label: Text("$i")));
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
      final trangthai = TrangThaiLuong.fromValue(nv.trangThai);
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
          if (_showChucVu) DataCell(Text(nv.chucVu)),
          ...[
            for (int i = 1; i <= soNgay; i++)
              if (_isShowNgay(i))
                DataCell(
                  Container(
                    width: 35,
                    height: 30,
                    child: Builder(
                      builder: (_) {
                        final ngay =
                            "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
                        final cc = nv.data[ngay];
                        return Tooltip(
                          message: cc?.chamCong.ghiChu ?? "",
                          child: Center(
                            child: Text(cc?.chamCong.hienThi ?? ""),
                          ),
                        );
                      },
                    ),
                  ),

                  /// 👇 ĐÚNG CHỖ
                  onTap: () async {
                    final ngay =
                        "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChamCongNgayScreen(
                          idNhanVienCongTrinh: nv.idNhanVienCongTrinh,
                          ngay: ngay,
                          hoTen: nv.ten,
                          tenCongTrinh: widget.tenCongTrinh,
                        ),
                      ),
                    );

                    _load();
                  },
                )
          ],
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
                child: Text(formatCurrency(nv.tongUng)),
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
                    thang: _selectedMonth,
                    nam: _selectedYear,
                  ),
                ),
              ).then((_) {
                _load();
              });
            },
          ),
          DataCell(Text(formatCurrency(nv.thucNhan))),
          DataCell(
            Text(
              trangthai == TrangThaiLuong.dachot ? "Đã chốt" : "Chưa chốt",
              style: TextStyle(
                color: trangthai == TrangThaiLuong.dachot
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),
          DataCell(
            trangthai == TrangThaiLuong.dachot
                ? (nv.tongDaChi == 0
                    ? Row(
                        children: [_huyChotbtn(nv), _chiLuongbtn(nv)],
                      )
                    : _chiLuongbtn(nv))
                : ElevatedButton(
                    onPressed: () async {
                      await _showConfirmChot(nv);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4), // 👈 nhỏ lại
                      minimumSize: const Size(0, 30), // 👈 chiều cao
                      tapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // 👈 giảm vùng click
                    ),
                    child: const Text(
                      "Chốt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      );
    }).toList();
  }
}
