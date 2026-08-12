import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/tien_do/TienDoScreen.dart';
import 'package:provider/provider.dart';

import '../../../nhan_vien_cong_trinh/presentation/mobile/nhan_vien_cong_trinh_list_screen.dart';
import '../../data/models/CongTrinh.dart';
import '../../../../controllers/thong_ke_controller.dart';
import '../../../bang_cham_cong/screens/BangChamCongScreen.dart';
import '../../../luong/LuongScreen.dart';
import '../../../nhat_ky/presentation/mobile/DanhSachNhatKyScreen.dart';
import '../../../thu_chi/screens/thu_chi_cong_trinh_screen.dart';
import '../../../ung_luong/screens/UngLuongListScreen.dart';
import 'cong_trinh_thong_ke.dart';

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
        builder: (context, controller, _) {
          final List<Item> items = [
            Item(
                icon: Icons.people,
                label: 'Nhân viên',
                page: NhanVienCongTrinhListScreen(
                  idCongTrinh: congTrinh.id,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongNhanVienCongTrinh.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            Item(
                icon: Icons.people,
                label: 'Tiến độ',
                page: TienDoScreen(
                  idCongTrinh: congTrinh.id!,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongKeHoach.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            Item(
                icon: Icons.list,
                label: 'Nhật ký',
                page: DanhSachNhatKyScreen(
                  idCongTrinh: congTrinh.id,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongNhatKy.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            // Item(
            //     icon: Icons.people,
            //     label: 'Chấm công',
            //     page: ChamCongScreen(
            //       idCongTrinh: congTrinh.id,
            //       tenCongTrinh: congTrinh.ten,
            //     ),
            //     value: controller.soLuongCoMat.toString(),
            //     color: const Color(0xFF27AE60),
            //     reloadAfterPop: true
            // ),
            Item(
                icon: Icons.people,
                label: 'Bảng chấm công',
                page: ChamCong2Screen(
                  idCongTrinh: congTrinh.id,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongCoMat.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            Item(
                icon: Icons.attach_money,
                label: 'Thu chi',
                page: ThuChiCongTrinhScreen(
                  idCongTrinh: congTrinh.id,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLanThuChi.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            Item(
                icon: Icons.money,
                label: 'Ứng lương',
                page: UngLuongListScreen(
                  idCongTrinh: congTrinh.id!,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongUngLuong.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
            Item(
                icon: Icons.money,
                label: 'Bảng lương',
                page: LuongNhanVienScreen(
                  idCongTrinh: congTrinh.id,
                  tenCongTrinh: congTrinh.ten,
                ),
                value: controller.soLuongUngLuong.toString(),
                color: const Color(0xFF27AE60),
                reloadAfterPop: true
            ),
          ];
          return Scaffold(
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
                          items: items,
                          onTap: (item) => _navigate(context, item),
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
          );
        },
      ),
    );
  }

  void _navigate(BuildContext context, Item item) {
    final controller = ThongKeController(idCongTrinh: congTrinh.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => item.page),
    ).then((_) {
      if (item.reloadAfterPop) {
        controller.loadCounts();
      }
    });
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
    double progress = (congTrinh.tienDo ?? 0) / 100;

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
            color: Colors.orange,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 6),
        Text("${(congTrinh.tienDo ?? 0).toStringAsFixed(1)}% hoàn thành"),
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
