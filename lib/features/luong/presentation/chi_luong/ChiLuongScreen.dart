import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/utils/currencyFormat.dart';
import '../../data/models/ChiLuong.dart';
import '../../data/repositories/ChiLuongRepository.dart';
import '../../data/services/ChiLuongService.dart';

class ChiLuongScreen extends StatefulWidget {
  final int idBangLuong;
  final String? tenNhanVien;
  final double tongPhaiTra;

  const ChiLuongScreen({
    super.key,
    required this.idBangLuong,
    this.tenNhanVien,
    required this.tongPhaiTra,
  });

  @override
  State<ChiLuongScreen> createState() => _ChiLuongScreenState();
}

class _ChiLuongScreenState extends State<ChiLuongScreen> {
  late ChiLuongService _service;

  final _tienCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<ChiLuongModel> lichSu = [];
  double daChi = 0;
  bool loading = false;

  double get conLai => widget.tongPhaiTra - daChi;

  @override
  void initState() {
    super.initState();
    _service = ChiLuongService(ChiLuongRepository());
    _load();
  }

  Future<void> _load() async {
    final ls = await _service.getLichSu(widget.idBangLuong);
    final tong = await _service.getTongDaChi(widget.idBangLuong);

    setState(() {
      lichSu = ls;
      daChi = tong;
    });
  }

  Future<void> _submit() async {
    final tien = double.tryParse(_tienCtrl.text) ?? 0;

    if (tien <= 0) return;
    if (tien > conLai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vượt quá số tiền còn lại")),
      );
      return;
    }

    setState(() => loading = true);

    await _service.chiLuong(
      idBangLuong: widget.idBangLuong,
      soTien: tien,
      ghiChu: _noteCtrl.text,
    );

    _tienCtrl.clear();
    _noteCtrl.clear();

    await _load();

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi lương")),
      body: Column(
        children: [
          /// FORM
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tenNhanVien ?? "",
                    style: const TextStyle(fontSize: 18)),

                Text("Còn lại: ${formatCurrency(conLai ?? 0)}",
                    style: const TextStyle(color: Colors.green)),

                const SizedBox(height: 10),

                TextField(
                  controller: _tienCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Số tiền",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Chi lương"),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lịch sử chi lương",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Đã chi: ${formatCurrency(daChi)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          /// LỊCH SỬ
          Expanded(
            child: lichSu.isEmpty
                ? const Center(child: Text("Chưa có lịch sử chi"))
                : ListView.builder(
              itemCount: lichSu.length,
              itemBuilder: (_, i) {
                final item = lichSu[i];
                return Slidable(
                  key: ValueKey(item.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(), // hiệu ứng trượt
                      extentRatio: 0.4,
                      children: [
                        SlidableAction(
                          onPressed: (_) async {
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
                              await _service.deleteChiLuong(item.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Xóa công trình thành công", style: TextStyle(color: Colors.white),),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              setState(() {
                                _load();
                              });
                            }
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Xóa',
                        ),
                      ],
                    ),
                  child: ListTile(
                    leading: const Icon(Icons.payments, color: Colors.green),
                    title: Text("${formatCurrency(item.soTien)}"),
                    subtitle: Text(
                      "${item.ngayChi.day}/${item.ngayChi.month}/${item.ngayChi.year}",
                    ),
                    trailing: Text(item.ghiChu ?? ""),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}