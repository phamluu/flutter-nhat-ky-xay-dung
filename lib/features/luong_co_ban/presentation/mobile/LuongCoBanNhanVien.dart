import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/mobile/LuongCoBanNhanVienForm.dart';
import '../../data/models/LuongCoBan.dart';
import '../../data/services/luong_co_ban_service.dart';

class LuongCoBanNhanVienScreen extends StatefulWidget {
  final int idNhanVien;
  final String? hoTen;
  const LuongCoBanNhanVienScreen(
      {super.key, required this.idNhanVien, this.hoTen});

  @override
  State<LuongCoBanNhanVienScreen> createState() =>
      _LuongCoBanNhanVienScreenState();
}

class _LuongCoBanNhanVienScreenState extends State<LuongCoBanNhanVienScreen> {
  final LuongCoBanService _service = LuongCoBanService();
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  late Future<List<LuongCoBanNhanVienModel>> _futureNhanVien;

  @override
  void initState() {
    super.initState();
    _futureNhanVien = _service.getLuongCoBanNhanVien(widget.idNhanVien);
  }

  void _load() {
    setState(() {
      _futureNhanVien =
          _service.getLuongCoBanNhanVien(widget.idNhanVien);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lương cơ bản"),
              Text(
                widget.hoTen ?? "",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LuongcobannhanvienformScreen(
                        idNhanVien: widget.idNhanVien,
                        hoTen: widget.hoTen,
                      )),
            );
            if (result == true) {
              setState(_load);
            }
          },
        ),
        body:  FutureBuilder<List<LuongCoBanNhanVienModel>>(
          future: _futureNhanVien,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            final nhanViens = snapshot.data ?? [];
            if (nhanViens.isEmpty) {
              return _emptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: nhanViens.length,
              itemBuilder: (context, index) {
                final luong = nhanViens[index];
                return Slidable(
                  key: ValueKey(luong.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.4,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LuongcobannhanvienformScreen(
                                      idNhanVien: widget.idNhanVien,
                                      hoTen: widget.hoTen,
                                      luong: luong,
                                  ),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _load();
                            });
                          }
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Sửa',
                      ),
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
                            await _service.deleteLuongCoBan(luong.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Xóa lương cơ bản thành công", style: TextStyle(color: Colors.white),),
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
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // 🔹 Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.attach_money,
                              color: Colors.green),
                        ),

                        const SizedBox(width: 12),

                        // 🔹 Nội dung
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 💰 Số tiền
                              Text(
                                "${currencyFormat.format(luong.soTien ?? 0)} đ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // 📅 Ngày
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(luong.ngayApDung),
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // 📝 Ghi chú
                              if (luong.ghiChu != null &&
                                  luong.ghiChu!.isNotEmpty)
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(luong.ghiChu!),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // ⭐ Badge "mới nhất"
                        if (index == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Mới nhất",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa có";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "Chưa có lịch sử lương",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
