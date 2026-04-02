import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/CongTrinh.dart';
import '../../../controllers/thong_ke_controller.dart';
import '../../nhan_vien_cong_trinh/pages/nhan_vien_cong_trinh_list_screen.dart';
import '../../nhat_ky/screens/DanhSachNhatKyScreen.dart';
import '../../cham_cong/cham_cong_screen.dart';
import '../../thu_chi/screens/thu_chi_cong_trinh_screen.dart';
import '../../ung_luong/screens/UngLuongScreen.dart';
import '../widgets/cong_trinh_thong_ke.dart';

class ChiTietCongTrinhScreen extends StatelessWidget {
  final CongTrinh congTrinh;

  const ChiTietCongTrinhScreen({super.key, required this.congTrinh});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = ThongKeController(idCongTrinh: congTrinh.id);
        controller.loadCounts();
        return controller;
      },
      child: Consumer<ThongKeController>(
        builder: (context, controller, _) => Scaffold(
          appBar: AppBar(
            title: Text(congTrinh.ten),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 HÌNH ẢNH CÔNG TRÌNH
                _buildHeaderImage(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 16),

                      // 🔹 TIẾN ĐỘ
                      _buildProgressSection(),
                      const SizedBox(height: 16),

                      // 🔹 THỐNG KÊ
                      ThongKeGrid(
                        controller: controller,
                        onDiaryTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DanhSachNhatKyScreen(
                                idCongTrinh: congTrinh.id,
                                tenCongTrinh: congTrinh.ten,
                              ),
                            ),
                          ).then((_) => controller.loadCounts());
                        },
                        onEmployeesTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NhanVienCongTrinhListScreen(
                                idCongTrinh: congTrinh.id,
                                tenCongTrinh: congTrinh.ten,
                              ),
                            ),
                          ).then((_) => controller.loadCounts());
                        },
                        onChamCongTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChamCongScreen(
                                idCongTrinh: congTrinh.id,
                                tenCongTrinh: congTrinh.ten,
                              ),
                            ),
                          ).then((_) => controller.loadCounts());
                        },
                        onThucChiTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ThuChiCongTrinhScreen(
                                idCongTrinh: congTrinh.id,
                                tenCongTrinh: congTrinh.ten,
                              ),
                            ),
                          ).then((_) => controller.loadCounts());
                        },
                        onUngLuongTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UngLuongScreen(
                                idCongTrinh: congTrinh.id,
                                tenCongTrinh: congTrinh.ten,
                              ),
                            ),
                          ).then((_) => controller.loadCounts());
                        },
                      ),

                      const SizedBox(height: 16),

                      // 🔹 MÔ TẢ
                      Text(
                        congTrinh.moTa ?? "Chưa có mô tả",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildHeaderImage() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: congTrinh.hinhAnh != null? Image.file(File(congTrinh.hinhAnh!),
        fit: BoxFit.cover,
      ): Image.asset('assets/noimage.png',fit: BoxFit.cover,),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.location_on, congTrinh.diaChi ?? "Không có địa chỉ"),
            const SizedBox(height: 8),
            _infoRow(Icons.calendar_today,
                congTrinh.ngayBatDau ?? "Chưa có ngày bắt đầu"),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    double progress = (congTrinh.tienDo ?? 20) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tiến độ công trình",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text("${congTrinh.tienDo ?? 20}% hoàn thành"),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
