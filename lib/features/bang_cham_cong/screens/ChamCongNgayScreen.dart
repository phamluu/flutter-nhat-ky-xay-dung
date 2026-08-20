import 'package:flutter/material.dart';

import '../data/repositories/ChamCongRepository.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../core/utils/trang_thai_cham_cong.dart';
import '../data/services/cham_cong_service.dart';
import '../data/models/ChamCongModel.dart';
import '../widgets/radioCompact.dart';
import '../widgets/row.dart';

class ChamCongNgayScreen extends StatefulWidget {
  final int? idNhanVienCongTrinh;
  final String? ngay;
  final String? hoTen;
  final String? tenCongTrinh;
  final bool daKhoa;
  const ChamCongNgayScreen({
    super.key,
    this.idNhanVienCongTrinh,
    this.ngay,
    this.hoTen,
    this.tenCongTrinh,
    required this.daKhoa
  });

  @override
  State<ChamCongNgayScreen> createState() => _ChamCongNgayScreenState();
}

class _ChamCongNgayScreenState extends State<ChamCongNgayScreen> {
  late final ChamCongService _service;
  final ghiChuCtrl = TextEditingController();
  ChamCongNgayLuong? data;
  bool isLoading = true;
  TrangThaiChamCong? _sang;
  TrangThaiChamCong? _chieu;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _service = ChamCongService(ChamCongRepository());
    _load();
  }

  Future<void> _load() async {
    if (widget.idNhanVienCongTrinh == null || widget.ngay == null) {
      setState(() => isLoading = false);
      return;
    }

    final result = await _service.getChamCongNgayLuong(
      widget.idNhanVienCongTrinh!,
      widget.ngay!,
    );

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chấm công ngày"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardThongTin(),
            const SizedBox(height: 16),
            if (data != null) ...[
              _cardTrangThai(),
              const SizedBox(height: 16),
              _cardLuong(),
            ] else ...[
              widget.daKhoa ? Text('Đã khóa chấm công', style: TextStyle(color: Colors.red),) : _cardChuaChamCong()
            ]
          ],
        ),
      ),
    );
  }

  // ===== CARD TRẠNG THÁI =====
  Widget _cardThongTin() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Thông tin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            row("Công trình", widget.tenCongTrinh ?? "---"),
            row("Họ tên", widget.hoTen ?? "---"),
            row("Ngày", widget.ngay ?? "---"),
          ],
        ),
      ),
    );
  }
  Widget _cardTrangThai() {
    final cc = data!.chamCong;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Chấm công",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                widget.daKhoa ? Text('Đã khóa chấm công', style: TextStyle(color: Colors.red),) :
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                      if (_isEdit) {
                        _sang = cc.sang;
                        _chieu = cc.chieu;
                      }
                    });
                  },
                  child: Text(_isEdit ? "Huỷ" : "Cập nhật"),
                )
              ],
            ),
            const Divider(),
            // ===== VIEW MODE =====
            if (!_isEdit) ...[
              row("Buổi sáng", cc.sang.label),
              const SizedBox(height: 10),
              row("Buổi chiều", cc.chieu.label),
              const SizedBox(height: 10),
              row("Ghi chú", ghiChuCtrl.text),
            ]

            // ===== EDIT MODE =====
            else ...[
              const Text("Buổi sáng",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: TrangThaiChamCong.values.map((e) {
                  return radioCompact(
                    value: e,
                    groupValue: _sang,
                    onChanged: (v) => setState(() => _sang = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Buổi chiều", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: TrangThaiChamCong.values.map((e) {
                  return radioCompact(
                    value: e,
                    groupValue: _chieu,
                    onChanged: (v) => setState(() => _chieu = v),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Ghi chú",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: ghiChuCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_sang == null || _chieu == null) return;
                  await _service.updateChamCong(
                    idNhanVienCongTrinh: widget.idNhanVienCongTrinh!,
                    ngay: widget.ngay!,
                    sang: _sang!,
                    chieu: _chieu!,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lưu chấm công thành công", style: TextStyle(color: Colors.white),),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  setState(() {
                    _isEdit = false;
                  });
                  _load();
                },
                child: const Text("Lưu"),
              )
            ],

            const Divider(height: 25),

            row("Ký hiệu", cc.hienThi),
            row("Công", cc.soCong.toString()),
          ],
        ),
      ),
    );
  }
  Widget _cardChuaChamCong() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chấm công",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // ===== BUỔI SÁNG =====
            const Text("Buổi sáng",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: TrangThaiChamCong.values.map((e) {
                return SizedBox(
                  width: 90,
                  child: RadioListTile<TrangThaiChamCong>(
                    title: Text(
                      e.label,
                      style: TextStyle(fontSize: 12),
                    ),
                    value: e,
                    groupValue: _sang,
                    onChanged: (v) => setState(() => _sang = v),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    horizontalTitleGap: 4, // giảm khoảng cách radio - label
                    minLeadingWidth: 0, // bỏ khoảng trống dư bên trái
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ===== BUỔI CHIỀU =====
            const Text("Buổi chiều",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              children: TrangThaiChamCong.values.map((e) {
                return SizedBox(
                  width: 90,
                  child: RadioListTile<TrangThaiChamCong>(
                    title: Text(
                      e.label,
                      style: TextStyle(fontSize: 12),
                    ),
                    value: e,
                    groupValue: _chieu,
                    onChanged: (v) => setState(() => _chieu = v),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    horizontalTitleGap: 4,
                    minLeadingWidth: 0,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text("Ghi chú",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: ghiChuCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Ghi chú",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 20),

            // ===== BUTTON LƯU =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_sang == null && _chieu == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bạn chưa chấm công', style: const TextStyle(color: Colors.white),),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  await _service.updateChamCong(
                    idNhanVienCongTrinh: widget.idNhanVienCongTrinh!,
                    ngay: widget.ngay!,
                    sang: _sang,
                    chieu: _chieu,
                    ghiChu: ghiChuCtrl.text
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lưu chấm công thành công", style: TextStyle(color: Colors.white),),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  _load();
                },
                child: const Text("Lưu chấm công"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CARD LƯƠNG =====
  Widget _cardLuong() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row("Lương ngày", formatCurrency(data!.luongNgay)),
            const SizedBox(height: 10),
            row("Tiền công",
                formatCurrency(data!.tienCongNgay)),
          ],
        ),
      ),
    );
  }

}