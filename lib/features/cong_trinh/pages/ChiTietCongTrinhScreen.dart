import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/cham_cong/cham_cong_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../controllers/thong_ke_controller.dart';
import '../../nhan_vien_cong_trinh/pages/nhan_vien_cong_trinh_list_screen.dart';
import '../../nhat_ky/screens/DanhSachNhatKyScreen.dart';
import '../widgets/cong_trinh_thong_ke.dart';

class ChiTietCongTrinhScreen extends StatelessWidget {
  final CongTrinh congTrinh;

  const ChiTietCongTrinhScreen({super.key, required this.congTrinh});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ThongKeController(idCongTrinh: congTrinh.id);
        controller.loadCounts(); // load số liệu ngay khi tạo
        return controller;
      },
      child: Consumer<ThongKeController>(
        builder: (context, controller, _) => Scaffold(
          appBar: AppBar(
            title: Text('${congTrinh.ten}'),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Địa chỉ: ${congTrinh.diaChi ?? "Không có địa chỉ"}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ngày bắt đầu: ${congTrinh.ngayBatDau ?? "Chưa có"}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                ThongKeGrid(
                  controller: controller,
                  onDiaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DanhSachNhatKyScreen(idCongTrinh: congTrinh.id, tenCongTrinh: congTrinh.ten,)),
                    ).then((_) => controller.loadCounts());
                  },
                  onEmployeesTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  NhanVienCongTrinhListScreen(idCongTrinh: congTrinh.id, tenCongTrinh: congTrinh.ten)),
                    ).then((_) => controller.loadCounts());
                  },
                  onChamCongTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  ChamCongScreen(idCongTrinh: congTrinh.id, tenCongTrinh: congTrinh.ten,)),
                    ).then((_) => controller.loadCounts());
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${congTrinh.moTa ?? "Chưa có mô tả"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
