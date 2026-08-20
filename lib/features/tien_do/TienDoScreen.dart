import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/utils/SyncColor.dart';
import 'data/models/TienDoCongTrinhModel.dart';
import 'data/repositories/TienDoRepository.dart';
import 'data/services/TienDoService.dart';
import 'TienDoFormScreen.dart';

class TienDoScreen extends StatefulWidget {
  final int idCongTrinh;
  final String? tenCongTrinh;
  const TienDoScreen({super.key, required this.idCongTrinh, this.tenCongTrinh});

  @override
  State<TienDoScreen> createState() => _TienDoScreenState();
}

class _TienDoScreenState extends State<TienDoScreen> {
  final service = TienDoService(TienDoRepository());
  List<TienDoCongTrinhModel> list = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    list = await service.getList(widget.idCongTrinh);
    setState(() {});
  }

  void deleteItem(int id) async {
    await service.delete(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Tiến độ ${widget.tenCongTrinh}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TienDoFormScreen(idCongTrinh: widget.idCongTrinh),
            ),
          );
          loadData();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Slidable(
              key: ValueKey(item.id),
              endActionPane:ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.4,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TienDoFormScreen(
                            idCongTrinh: widget.idCongTrinh,
                            model: item,
                          ),
                        ),
                      );
                      loadData();
                    },
                    backgroundColor: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Xóa"),
                          content: const Text("Bạn có chắc muốn xóa?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        deleteItem(item.id!);
                      }
                    },
                    backgroundColor: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Tên công việc
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.tenCongViec,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SyncColor.icon(item.isSynced)
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// Deadline
                    Text(
                      "Deadline: ${item.ngayKetThuc ?? "--"}",
                      style: TextStyle(
                        color: _isTreDeadline(item)
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Progress bar
                    LinearProgressIndicator(
                      value: (item.phanTramThucTe ?? 0) / 100,
                      backgroundColor: Colors.grey[300],
                      color: _getColor(item),
                      minHeight: 8,
                    ),

                    const SizedBox(height: 6),

                    /// % + trạng thái
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tiến độ: ${item.phanTramThucTe ?? 0}%"),
                        Text(
                          _getStatusText(item.trangThai),
                          style: TextStyle(
                            color: _getColor(item),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
          );
        },
      ),
    );
  }

  bool _isTreDeadline(TienDoCongTrinhModel item) {
    if (item.ngayKetThuc == null) return false;

    final deadline = DateTime.tryParse(item.ngayKetThuc!);
    if (deadline == null) return false;

    return DateTime.now().isAfter(deadline) &&
        (item.phanTramThucTe ?? 0) < 100;
  }
  Color _getColor(TienDoCongTrinhModel item) {
    if (_isTreDeadline(item)) return Colors.red;

    switch (item.trangThai) {
      case 2:
        return Colors.green;
      case 1:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  String _getStatusText(int? status) {
    switch (status) {
      case 2:
        return "Hoàn thành";
      case 1:
        return "Đang làm";
      default:
        return "Chưa làm";
    }
  }
}