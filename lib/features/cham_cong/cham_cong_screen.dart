import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/ChamCong.dart';
import '../../data/models/NhanVienCongTrinh.dart';
import '../../core/utils/trang_thai_cham_cong.dart';
import 'cham_cong_controller.dart';
import 'screens/ChamCongResultScreen.dart';
import 'widgets/halfDaySelector.dart';

class ChamCongScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;

  const ChamCongScreen({
    super.key,
    this.idCongTrinh,
    this.tenCongTrinh,
  });

  @override
  State<ChamCongScreen> createState() => _ChamCongScreenState();
}

class _ChamCongScreenState extends State<ChamCongScreen> {
  final ChamCongController _controller = ChamCongController();

  final Map<int, ChamCong> _data = {};
  DateTime _selectedDate = DateTime.now();

  int? _selectedCongTrinhId;
  List<NhanVienCongTrinh> _nhanViens = [];
  List<Map<String, dynamic>> _dsCongTrinh = [];

  @override
  void initState() {
    super.initState();
    _selectedCongTrinhId = widget.idCongTrinh;
    _initData();
  }

  Future<void> _initData() async {
    _dsCongTrinh = await _controller.loadDsCongTrinh();
    if (_selectedCongTrinhId != null && _selectedCongTrinhId != 0) {
      _nhanViens = await _controller.loadDsNhanVien(_selectedCongTrinhId!);
      _data.addAll(await _controller.loadChamCong(
          _selectedCongTrinhId!, _selectedDate, _nhanViens));
    }
    if (mounted) setState(() {});
  }

  Future<void> _onChangeCongTrinh(int id) async {
    _selectedCongTrinhId = id;
    _nhanViens = await _controller.loadDsNhanVien(id);
    _data
      ..clear()
      ..addAll(await _controller.loadChamCong(id, _selectedDate, _nhanViens));
    if (mounted) setState(() {});
  }

  Future<void> _save() async {

    await _controller.save(_data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lưu thành công", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngayText = DateFormat("dd/MM/yyyy").format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chấm công",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_selectedCongTrinhId != null)
              Text(
                widget.tenCongTrinh ??
                    _dsCongTrinh.firstWhere(
                          (ct) => ct["id"] == _selectedCongTrinhId,
                      orElse: () => {"ten": ""},
                    )["ten"],
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Dropdown chọn công trình
          if( widget.idCongTrinh == null || widget.idCongTrinh == 0)
            ListTile(
              title: DropdownButton<int>(
                isExpanded: true,
                value: _dsCongTrinh.any((ct) =>
                ct["id"] == _selectedCongTrinhId)
                    ? _selectedCongTrinhId
                    : null,
                hint: const Text("Chọn công trình"),
                items: _dsCongTrinh
                    .map((ct) =>
                    DropdownMenuItem<int>(
                      value: ct["id"],
                      child: Text(ct["ten"]),
                    ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _onChangeCongTrinh(v);
                },
              ),
            ),
          // chọn ngày
          ListTile(
            title: Text("Ngày: $ngayText"),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final dataMoi = await _controller.loadChamCong(
                      _selectedCongTrinhId!, picked, _nhanViens);
                  setState(() {
                    _selectedDate = picked;
                    _data
                      ..clear()
                      ..addAll(dataMoi);
                  });
                }
              },
            ),
          ),
          const Divider(),

          // danh sách NV
          Expanded(
            child: _selectedCongTrinhId == null
                ? const Center(child: Text("Vui lòng chọn công trình"))
                : ListView(
              children: _nhanViens.map((nvct) {
                final cc = _data[nvct.id] ??
                    ChamCong(
                      idNhanVienCongTrinh: nvct.id!,
                      ngay: DateFormat("yyyy-MM-dd").format(_selectedDate),
                    );
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nvct.nhanVien?.hoTen ?? "Chưa đặt tên",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Sáng: ${TrangThaiChamCong.fromValue(cc.trangThaiSang).label}'),
                            HalfDaySelector(
                              initialValue: cc.trangThaiSang,
                              onChanged: (v) =>
                                  setState(() => cc.trangThaiSang = v),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Chiều: ${TrangThaiChamCong.fromValue(cc.trangThaiChieu).label}'),
                            HalfDaySelector(
                              initialValue: cc.trangThaiChieu,
                              onChanged: (v) =>
                                  setState(() => cc.trangThaiChieu = v),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.save, color: Colors.blue),
              label: const Text("Lưu"),
              onPressed: _save,
            ),
            TextButton.icon(
              icon: const Icon(Icons.list_alt, color: Colors.green),
              label: const Text("Kết quả"),
              onPressed: () {
                if (_selectedCongTrinhId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng chọn công trình trước"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChamCongResultScreen(
                      congTrinhId: _selectedCongTrinhId!,
                      tenCongTrinh: widget.tenCongTrinh,
                      ngay: _selectedDate,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
