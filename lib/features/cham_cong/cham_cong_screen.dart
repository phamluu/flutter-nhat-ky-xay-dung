import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/data/models/CongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_cong_trinh_service.dart';
import '../../core/utils/trang_thai_cham_cong.dart';
import '../../data/repositories/cham_cong_repository.dart';

import '../../data/models/ChamCong.dart';
import '../../data/models/NhanVienCongTrinh.dart';
import 'widgets/halfDaySelector.dart';

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
  final CongTrinhService _congTrinhService = CongTrinhService();
  final NhanVienCongTrinhService _nhanVienCongTrinhService = NhanVienCongTrinhService();

  final Map<int, ChamCong> _data = {};
  DateTime _selectedDate = DateTime.now();

  int? _selectedCongTrinhId;
  List<NhanVienCongTrinh> _nhanViens = [];
  List<Map<String, dynamic>> _dsCongTrinh = [];

  @override
  void initState() {
    super.initState();
    _selectedCongTrinhId = widget.idCongTrinh;
    _loadDsCongTrinh();
    _loadDsNhanVien();
    if (_selectedCongTrinhId != null) {
      _loadChamCong();
    }
  }
  Future<void> _loadDsCongTrinh() async {
    final ds = await _congTrinhService.getDanhSachCongTrinh();
    setState(() {
      _dsCongTrinh = ds.map<Map<String, dynamic>>((ct) => {
        "id": ct.id,
        "ten": ct.ten,
      }).toList();
    });
  }
  Future<void> _loadDsNhanVien() async {
    if (_selectedCongTrinhId == null) return;
    final ds = await _nhanVienCongTrinhService.getByCongTrinh(_selectedCongTrinhId!);
    setState(() {
      _nhanViens = ds;
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lưu thành công",
            style: TextStyle(color: Colors.white),
          ),
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
        title: const Text("Chấm công"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          // chọn công trình bằng dropdown
          ListTile(
            title: DropdownButton<int>(
              isExpanded: true,
              value: _dsCongTrinh.any((ct) => ct["id"] == _selectedCongTrinhId)
                  ? _selectedCongTrinhId
                  : null,
              hint: const Text("Chọn công trình"),
              items: _dsCongTrinh
                  .map(
                    (ct) => DropdownMenuItem<int>(
                  value: ct["id"],
                  child: Text(ct["ten"]),
                ),
              )
                  .toList(),
              onChanged: (v) async {
                setState(() {
                  _selectedCongTrinhId = v;
                });
                await _loadDsNhanVien();
                await _loadChamCong();
              },
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
                final cc = _data[nvct.id] ?? ChamCong(
                  idNhanVienCongTrinh: nvct.id!,
                  ngay: DateFormat("yyyy-MM-dd").format(_selectedDate),
                );
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nvct.nhanVien?.hoTen ?? "Chưa đặt tên",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text('Sáng: ${TrangThaiChamCong.fromValue(cc.trangThaiSang).label}'),
                              HalfDaySelector(
                                initialValue: cc.trangThaiSang,
                                onChanged: (v) => setState(() => cc.trangThaiSang = v),
                              )
                            ]
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text('Chiều: ${TrangThaiChamCong.fromValue(cc.trangThaiChieu).label}'),
                              HalfDaySelector(
                                initialValue: cc.trangThaiChieu,
                                onChanged: (v) => setState(() => cc.trangThaiChieu = v),
                              )
                            ]
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
