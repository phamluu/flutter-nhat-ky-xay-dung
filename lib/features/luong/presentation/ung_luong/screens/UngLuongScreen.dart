// Danh sách đã ứng trong 1 tháng của từng nhân viên công trình
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/repositories/ChotChiLuongRepository.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/services/ChotChiLuongService.dart';
import '../../../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/ung_luong_repository.dart';
import '🚀 📱 UngLuongFormScreen.dart';

class UngLuongScreen extends StatefulWidget {
  final int? idNhanVienCongTrinh;
  final String? hoTen;
  final String? congTrinh;
  final int? thang;
  final int? nam;
  final int? idBangChamCong;
  const UngLuongScreen({
    Key? key,
    this.idNhanVienCongTrinh,
    this.hoTen,
    this.congTrinh,
    this.thang,
    this.nam,
    required this.idBangChamCong
  }) : super(key: key);
  @override
  State<UngLuongScreen> createState() => _UngLuongScreenState();
}

class _UngLuongScreenState extends State<UngLuongScreen> {
  final _service = UngLuongRepository();
  late final Chotchiluongservice _chotLuong;
  late final ChotChiLuongRepository _chotLuongRepo;
  late bool daChotLuong = false;
  late Future<List<Ungluong>> _future;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _chotLuong = Chotchiluongservice(ChotChiLuongRepository());
    _chotLuongRepo = ChotChiLuongRepository();
    _future = _service.getUngLuongNhanVien(widget.idNhanVienCongTrinh!);
    _loadChotLuong();
  }
  void _reload() async {
    final chot = await _chotLuongRepo.checkDaChotLuong(idBangChamCong: widget.idBangChamCong,
        idNhanVienCongTrinh:  widget.idNhanVienCongTrinh!
    );
    setState(() {
      _future = _service.getUngLuongNhanVien(widget.idNhanVienCongTrinh!);
      daChotLuong = chot;
    });
  }
  void _loadChotLuong() async {
    final chot = await _chotLuongRepo.checkDaChotLuong(idBangChamCong: widget.idBangChamCong,
        idNhanVienCongTrinh:  widget.idNhanVienCongTrinh!
    );

    setState(() {
      daChotLuong = chot;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quản lý ứng lương tháng ${widget.thang}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: daChotLuong
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UngLuongFormScreen(
                  idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
                  hoTen: widget.hoTen,
                  tenCongTrinh: widget.congTrinh,
                ),
              ),
            ).then((_) => _reload());
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<Ungluong>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            final data = snapshot.data ?? [];
            return Column(
              children: [
                _cardThongTin(),
                if (data.isEmpty) _noData(context),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ul = data[index];
                      return daChotLuong
                          ? _buildItem(ul) // chỉ hiển thị card
                          : Slidable(
                        key: ValueKey(ul.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UngLuongFormScreen(
                                    ul: ul,
                                    idNhanVienCongTrinh:
                                    widget.idNhanVienCongTrinh,
                                  ),
                                ),
                              ).then((_) => _reload()),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Sửa',
                            ),
                            SlidableAction(
                              onPressed: (context) => _deleteUngLuong(ul),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Xóa',
                            ),
                          ],
                        ),
                        child: _buildItem(ul),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ));
  }

  Widget _cardThongTin() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 👉 Avatar/icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            // 👉 Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hoTen ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.congTrinh ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    daChotLuong ? "🔒 Đã chốt lương" : "🟢 Chưa chốt lương",
                    style: TextStyle(
                      color: daChotLuong ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.money_off,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Tháng này ${widget.hoTen} chưa ứng lương',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUngLuong(Ungluong ul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn xóa ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteUngLuong(ul.id!);
      _reload();
    }
  }

  Widget _buildItem(Ungluong ul) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.attach_money, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(ul.soTien ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        ul.ngayUng != null
                            ? DateFormat('dd/MM/yyyy')
                            .format(ul.ngayUng!)
                            : "Chưa có",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (ul.lyDo != null && ul.lyDo!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.note,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(ul.lyDo!)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
