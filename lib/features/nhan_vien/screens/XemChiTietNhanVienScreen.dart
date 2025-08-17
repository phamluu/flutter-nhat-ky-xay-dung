import 'package:flutter/material.dart';
import '../../../data/models/NhanVien.dart';

class XemChiTietNhanVienScreen extends StatelessWidget {
  final NhanVien nhanVien;

  const XemChiTietNhanVienScreen({super.key, required this.nhanVien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nhanVien.hoTen ?? "Chi tiết nhân viên"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: nhanVien.hinhAnh != null
                    ? AssetImage(nhanVien.hinhAnh!)
                    : null,
                child: nhanVien.hinhAnh == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text("Họ tên: ${nhanVien.hoTen ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Ngày sinh: ${nhanVien.ngaySinh ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Email: ${nhanVien.email ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Số điện thoại: ${nhanVien.soDienThoai ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Địa chỉ: ${nhanVien.diaChi ?? '-'}",
                style: const TextStyle(fontSize: 16)),
            // Text("Chức vụ: ${nhanVien.chucVu ?? '-'}",
            //     style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
