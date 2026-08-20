import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/services/BangLuongService.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/ChamCongModel.dart';

import '../../core/utils/currencyFormat.dart';
import '../../core/utils/trang_thai_luong.dart';
import '../bang_cham_cong/data/repositories/ChamCongRepository.dart';
import '../bang_cham_cong/data/services/ChotChiLuongService.dart';
import '../bang_cham_cong/data/services/cham_cong_service.dart';
import '../chi_luong/ChiLuongScreen.dart';

class LuongNhanVienScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const LuongNhanVienScreen({super.key, this.idCongTrinh, this.tenCongTrinh});

  @override
  State<LuongNhanVienScreen> createState() => _LuongNhanVienScreenState();
}

class _LuongNhanVienScreenState extends State<LuongNhanVienScreen> {
  late var daKhoaCC = false;
  late final BangLuongService _service;
  late final Chotchiluongservice _chotService;
  late final ChamCongService _chamCongService;
  List<ChamCongModel> data = [];
  late Future<List<ChamCongModel>> _future;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String get thang =>
      "${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}";
  @override
  void initState() {
    super.initState();
    _service = BangLuongService(
      chamCongService: ChamCongService(ChamCongRepository()),
      chotRepo: ChotChiLuongRepository(),
    );
    _chotService = Chotchiluongservice(ChotChiLuongRepository());
    _chamCongService = ChamCongService(ChamCongRepository());
    _future = _load();
  }
  Future<List<ChamCongModel>> _load() async {
    final result = await _service.loadLuong(
      widget.idCongTrinh!,
      _selectedMonth,
      _selectedYear,
    );

    final khoa = await _chamCongService.checkKhoaChamCong(thang);

    setState(() {
      daKhoaCC = khoa;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.blue,
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
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<ChamCongModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data ?? [];
                if (!snapshot.hasData || data.isEmpty){
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

  Widget _buildTable(List<ChamCongModel> data) {
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
          final trangthai = TrangThaiLuong.fromValue(item.trangThai);
          return DataRow(cells: [
            DataCell(Text(item.ten ?? "")),
            DataCell(Text("${item.tongSoCong ?? 0}")),
            DataCell(Text("${item.tongUng ?? 0} đ")),
            DataCell(Text("${item.tongTienCong ?? 0} đ")),
            DataCell(
              Text(
                "${item.thucNhan ?? 0} đ",
                style: const TextStyle(color: Colors.green),
              ),
            ),
            DataCell(
              Text(
                trangthai == TrangThaiLuong.dachot? "Đã chốt" : "Chưa chốt",
                style: TextStyle(
                  color: trangthai == TrangThaiLuong.dachot ? Colors.green : Colors.red,
                ),
              ),
            ),
            DataCell(
              ElevatedButton(
                onPressed: trangthai == TrangThaiLuong.dachot
                    ? null
                    : () async {
                  await _showConfirmChot(item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  trangthai == TrangThaiLuong.dachot ? Colors.grey : Colors.green,
                ),
                child: const Text(
                  "Chốt",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildCardList(List<ChamCongModel> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final trangthai = TrangThaiLuong.fromValue(item.trangThai);
        final daChi = item.tongDaChi ?? 0;
        final phaiTra = item.thucNhanChot ?? 0;
        final daChiDu = daChi >= phaiTra;
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
                  "${index + 1}. ${item.ten ?? ""}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Tổng công: ${item.tongSoCong}"),
                Text("Đã ứng: ${formatCurrency(item.tongUngHienThi ?? 0)}"),
                Text("Tổng lương: ${formatCurrency(item.tongLuongHienThi ?? 0)}"),

                const SizedBox(height: 6),

                Text(
                  "Thực nhận: ${formatCurrency(item.thucNhanHienThi ?? 0)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    /// TEXT TRẠNG THÁI
                    Expanded(
                      child: Text(
                        trangthai == TrangThaiLuong.dachot
                            ? "Đã chốt lương"
                            : "Chưa chốt lương",
                        overflow: TextOverflow.ellipsis, // 👈 QUAN TRỌNG
                        style: TextStyle(
                          color: trangthai == TrangThaiLuong.dachot
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    /// ĐÃ CHI
                    if (trangthai == TrangThaiLuong.dachot && daChiDu)
                      Flexible(
                        child: Text(
                          "Đã chi đủ",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(width: 4),

                    /// BUTTON
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (daKhoaCC)
                            ...(trangthai == TrangThaiLuong.dachot
                                ? (item.tongDaChi == 0
                                ? [
                              _huyChotbtn(item),
                              const SizedBox(width: 4),
                              _chiLuongbtn(item),
                            ]
                                : [_chiLuongbtn(item)])
                                : [_chotbtn(item)])
                          else
                            const Text('Chưa khóa CC', style: TextStyle(color: Colors.red),),
                        ],
                      ),
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
        _future = _load();
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
  Widget _chiLuongbtn(ChamCongModel item){
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChiLuongScreen(
              idBangLuong: item.idBangLuong!,
              tenNhanVien: item.ten,
              tongPhaiTra: item.thucNhanHienThi ?? 0,
            ),
          ),
        );

        if (result == true) {
          setState(() {
            _future = _load(); // reload lại data
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        "Chi lương",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  Widget _chotbtn(ChamCongModel item){
    return ElevatedButton(
      onPressed: () async {
        await _showConfirmChot(item);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        "Chốt",
        style: TextStyle(color: Colors.white),
      ),
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
                  _future = _load();
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
                  _future = _load();
                });
              },
            ),
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
      _future = _load(); // demo lại data
    });
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
        _future = _load();
      });
    }
  }
}
