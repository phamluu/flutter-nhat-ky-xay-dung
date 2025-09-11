import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/trang_thai_cham_cong.dart';
import '../../../data/models/ChamCong.dart';
import '../cham_cong_controller.dart';
import '../widgets/exportPdf.dart';

class ChamCongResultScreen extends StatelessWidget {
  final int congTrinhId;
  final String? tenCongTrinh;
  final DateTime? ngay;

  const ChamCongResultScreen({
    super.key,
    required this.congTrinhId,
    this.tenCongTrinh,
    this.ngay,
  });

  Color _getTrangThaiColor(int? value) {
    switch (value) {
      case 1: // Có mặt
        return Colors.green;
      case 2: // Có phép
        return Colors.orange;
      case 0: // Vắng
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChamCongController controller = ChamCongController();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Kết quả chấm công"),
            if (tenCongTrinh != null)
              Text(
                tenCongTrinh!,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
          ],
        ),
      ),
      body: FutureBuilder<List<ChamCong>>(
        future: controller.loadChamCongKetQua(congTrinhId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final dsChamCong = snapshot.data ?? [];
          if (dsChamCong.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu chấm công"));
          }

          // Nhóm theo ngày
          final Map<String, List<ChamCong>> chamCongByDate = {};
          for (var cc in dsChamCong) {
            chamCongByDate.putIfAbsent(cc.ngay, () => []).add(cc);
          }

          final sortedDates = chamCongByDate.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // sắp xếp ngày giảm dần

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final ngay = sortedDates[index];
              final list = chamCongByDate[ngay] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    "Ngày ${DateFormat('dd/MM/yyyy').format(DateTime.parse(ngay))}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: list.map((cc) {
                    final sangLabel = TrangThaiChamCong.fromValue(cc.trangThaiSang).label;
                    final chieuLabel = TrangThaiChamCong.fromValue(cc.trangThaiChieu).label;

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(cc.nhanVienCongTrinh?.nhanVien?.hoTen ?? "Không tên"),
                      subtitle: Row(
                        children: [
                          Text(
                            "Sáng: $sangLabel",
                            style: TextStyle(color: _getTrangThaiColor(cc.trangThaiSang)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Chiều: $chieuLabel",
                            style: TextStyle(color: _getTrangThaiColor(cc.trangThaiChieu)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),

        floatingActionButton:SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.blue,
          overlayOpacity: 0.4,
          spacing: 12,
          spaceBetweenChildren: 8,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                backgroundColor: Colors.red,
                label: 'Xuất PDF',
                onTap: () async {
                  final data = await controller.loadChamCongKetQua(congTrinhId);
                  await export(data, tenCongTrinh);
                },
              ),
            ]
        )
    );
  }
}
