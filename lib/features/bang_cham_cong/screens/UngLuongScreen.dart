import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/services/ung_luong_service.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/UngLuong.dart';
import 'package:intl/intl.dart';

import '🚀 📱 UngLuongFormScreen.dart';

class UngLuongScreen extends StatefulWidget {
  final int? idNhanVienCongTrinh;
  final String? hoTen;
  final String? congTrinh;
  final int thang;
  const UngLuongScreen(
      {Key? key,
      this.idNhanVienCongTrinh,
      this.hoTen,
      this.congTrinh,
      required this.thang})
      : super(key: key);
  @override
  State<UngLuongScreen> createState() => _UngLuongScreenState();
}

class _UngLuongScreenState extends State<UngLuongScreen> {
  final _service = UngLuongService();
  late Future<List<Ungluong>> _future;
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getUngLuongNhanVien(widget.idNhanVienCongTrinh!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UngLuongFormScreen(
                idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
                hoTen: widget.hoTen,
                tenCongTrinh: widget.congTrinh,
              ),
            ),
          ).then((_) {
            _reload();
          }),
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
                Text(data.isEmpty ? 'Tháng này bạn chưa ứng lương' : ''),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ul = data[index];
                      return Slidable(
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
                                    idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
                                  ),
                                ),
                              ).then((_) {
                                _reload();
                              }),
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
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // 👉 ICON
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.attach_money,
                                      color: Colors.blue),
                                ),

                                const SizedBox(width: 12),

                                // 👉 NỘI DUNG
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // SỐ TIỀN
                                      Text(
                                        formatCurrency(ul.soTien ?? 0),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // NGÀY
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
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // LÝ DO
                                      if (ul.lyDo != null && ul.lyDo!.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(Icons.note,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                ul.lyDo!,
                                                style: const TextStyle(
                                                    color: Colors.black87),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ));
  }

  Widget _cardThongTin(){
    return Card(
      elevation: 3,
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
                          style:
                          const TextStyle(color: Colors.grey),
                        ),
                      ),
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
  void _openForm([Ungluong? ul]) async {
    final soTienCtrl = TextEditingController(
      text: ul?.soTien?.toString() ?? "",
    );
    final ngayCtrl = TextEditingController(
      text: ul?.ngayUng?.toString() ?? "",
    );
    final lyDoCtrl = TextEditingController(
      text: ul?.lyDo,
    );
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ul == null ? "Thêm ứng lương" : "Sửa ứng lương"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: soTienCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số tiền"),
            ),
            TextField(
              controller: ngayCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Chọn ngày",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: ul?.ngayUng ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  selectedDate = pickedDate;

                  ngayCtrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                }
              },
            ),
            TextFormField(
              controller: lyDoCtrl,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: "Lý do"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final model = Ungluong(
                id: ul?.id,
                idNhanVienCongTrinh: widget.idNhanVienCongTrinh,
                soTien: double.tryParse(soTienCtrl.text) ?? 0,
                ngayUng: selectedDate,
                lyDo: lyDoCtrl.text,
              );

              if (ul == null) {
                await _service.addUngLuong(model);
              } else {
                await _service.updateUngLuong(model);
              }
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Ứng lương thành công", style: TextStyle(color: Colors.white),),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
    if (result == true) {
      _reload();
    }
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
      setState(() => _reload());
    }
  }
}
