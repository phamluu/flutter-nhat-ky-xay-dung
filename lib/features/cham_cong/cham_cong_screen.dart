import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../data/repositories/cham_cong_repository.dart';

import '../../data/models/ChamCong.dart';
import '../../data/models/NhanVienCongTrinh.dart';

class ChamCongScreen extends StatefulWidget {
  final int? idCongTrinh; // để null được
  final List<NhanVienCongTrinh>? nhanViens;

  const ChamCongScreen({
    super.key,
    this.idCongTrinh,
    this.nhanViens,
  });

  @override
  State<ChamCongScreen> createState() => _ChamCongScreenState();
}

class _ChamCongScreenState extends State<ChamCongScreen> {
  final ChamCongRepository _repo = ChamCongRepository();
  final Map<int, ChamCong> _data = {};
  DateTime _selectedDate = DateTime.now();

  int? _selectedCongTrinhId;
  List<NhanVienCongTrinh> _nhanViens = [];

  @override
  void initState() {
    super.initState();
    _selectedCongTrinhId = widget.idCongTrinh;
    _nhanViens = widget.nhanViens ?? [];
    if (_selectedCongTrinhId != null) {
      _loadChamCong();
    }
  }

  Future<void> _chonCongTrinh() async {
    // TODO: mở màn hình chọn công trình, trả về id & danh sách nhân viên
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => ChonCongTrinhScreen(), // màn chọn công trình
    //   ),
    // );
    // if (result != null) {
    //   setState(() {
    //     _selectedCongTrinhId = result['idCongTrinh'];
    //     _nhanViens = result['nhanViens'];
    //   });
    //   _loadChamCong();
    // }
  }

  Future<void> _loadChamCong() async {
    if (_selectedCongTrinhId == null) return;

    final ngay = DateFormat("yyyy-MM-dd").format(_selectedDate);

    // khởi tạo dữ liệu rỗng
    final Map<int, ChamCong> map = {
      for (var nvct in _nhanViens)
        nvct.id!: ChamCong(
          idNhanVienCongTrinh: nvct.id!,
          ngay: ngay,
        )
    };

    // load dữ liệu đã có
    final existing =
    await _repo.getChamCongByDate(_selectedCongTrinhId!, ngay);

    for (var cc in existing) {
      map[cc.idNhanVienCongTrinh] = cc;
    }

    setState(() {
      _data
        ..clear()
        ..addAll(map);
    });
  }

  Future<void> _save() async {
    for (var cc in _data.values) {
      if (cc.id == null) {
        await _repo.insert(cc);
      } else {
        await _repo.update(cc);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lưu thành công")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngayText = DateFormat("dd/MM/yyyy").format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chấm công"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              _selectedCongTrinhId != null
                  ? "Công trình: $_selectedCongTrinhId"
                  : "Chưa chọn công trình",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.work),
              onPressed: _chonCongTrinh,
            ),
          ),
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
                  setState(() => _selectedDate = picked);
                  _loadChamCong();
                }
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedCongTrinhId == null
                ? const Center(
              child: Text("Vui lòng chọn công trình để chấm công"),
            )
                : ListView(
              children: _nhanViens.map((nvct) {
                final cc = _data[nvct.id]!;
                return Card(
                  child: ListTile(
                    title: Text(nvct.nhanVien?.hoTen ?? "Chưa đặt tên"),
                    subtitle: Row(
                      children: [
                        DropdownButton<int?>(
                          hint: const Text("Sáng"),
                          value: cc.trangThaiSang,
                          items: const [
                            DropdownMenuItem(
                                value: 1, child: Text("Có mặt")),
                            DropdownMenuItem(
                                value: 0, child: Text("Vắng")),
                          ],
                          onChanged: (v) =>
                              setState(() => cc.trangThaiSang = v),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<int?>(
                          hint: const Text("Chiều"),
                          value: cc.trangThaiChieu,
                          items: const [
                            DropdownMenuItem(
                                value: 1, child: Text("Có mặt")),
                            DropdownMenuItem(
                                value: 0, child: Text("Vắng")),
                          ],
                          onChanged: (v) =>
                              setState(() => cc.trangThaiChieu = v),
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
    );
  }
}
