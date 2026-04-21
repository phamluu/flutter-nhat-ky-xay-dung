import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_dong_bo.dart';
import 'package:nhat_ky_xay_dung/features/auth/screens/DangKyScreen.dart';
import '../../../core/services/ApiClient.dart';
import '../../../core/utils/AuthHelper.dart';
import '../../../data/models/NhanVien.dart';
import '../../../services/SyncService.dart';
import '../../../services/nhan_vien_service.dart';
import '../../../viewmodel/UserInfo.dart';
import '../../auth/screens/LoginScreen.dart';

class XemChiTietNhanVienScreen extends StatefulWidget {
  final NhanVien nhanVien;
  const XemChiTietNhanVienScreen({super.key, required this.nhanVien});

  @override
  State<XemChiTietNhanVienScreen> createState() => _XemChiTietNhanVienState();
}

class _XemChiTietNhanVienState extends State<XemChiTietNhanVienScreen> {
  UserInfo? userInfo;
  bool isLoading = false;
  bool isSyncing = false;
  SyncService syn = SyncService();
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      setState(() => isLoading = true);
      final response =
          await ApiClient.get("user/by-nhanvien/${widget.nhanVien.server_id}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userInfo = UserInfo.fromJson(data);
        });
      }
    } catch (e) {
      print("Lỗi lấy user: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nhanVien.hoTen ?? "Chi tiết nhân viên"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNhanVienInfo(),
            const SizedBox(height: 16),
            _buildTaiKhoanSection(),
          ],
        ),
      ),
    );
  }
  Widget _buildNhanVienInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: widget.nhanVien.hinhAnh != null
                  ? AssetImage(widget.nhanVien.hinhAnh!)
                  : null,
              child: widget.nhanVien.hinhAnh == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            _infoRow("Họ tên", widget.nhanVien.hoTen),
            _infoRow("Ngày sinh", (widget.nhanVien.ngaySinh ?? '').toString()),
            _infoRow("Email", widget.nhanVien.email),
            _infoRow("SĐT", widget.nhanVien.soDienThoai),
            _infoRow("Địa chỉ", widget.nhanVien.diaChi),
          ],
        ),
      ),
    );
  }
  Widget _buildTaiKhoanSection() {
    return FutureBuilder<bool>(
      future: AuthHelper.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: double.infinity,
            child: const Card(child: Padding(
              padding: EdgeInsets.all(16),
              child: Text("Đang kiểm tra..."),
            )),
          );
        }
        final isLoggedIn = snapshot.data!;
        return SizedBox(
          width: double.infinity,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tài khoản",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (!isLoggedIn) ...[
                    _buildLoginButton(),
                  ] else ...[
                    if(widget.nhanVien.isSynced == TrangThaiDongBo.chuadongbo.value
                    || widget.nhanVien.server_id == null)
                      _buildSynButton(),
                    if (widget.nhanVien.isSynced == TrangThaiDongBo.dadongbo.value
                        && widget.nhanVien.server_id != null
                        && userInfo == null)
                      _buildRegisterButton(),
                    if (userInfo != null)
                      _buildUserInfo(),
                  ]
                ],
              ),
            ),
          ),
        );

      },
    );
  }
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: const Text("Hãy đăng nhập để xem",
          style: TextStyle(color: Colors.red)),
    );
  }
  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Dangkyscreen(
              nhanVienId: widget.nhanVien.server_id,
              tenNhanVien: widget.nhanVien.hoTen,
            ),
          ),
        );

        if (result == true) fetchUserInfo();
      },
      child: const Text("Đăng ký", style: TextStyle(color: Colors.green)),
    );
  }
  Widget _buildSynButton(){
    return TextButton(
      onPressed: () async {
        _syncNhanVien(widget.nhanVien);
      },
      child: const Text("Đồng bộ", style: TextStyle(color: Colors.green)),
    );
  }
  Future<void> _syncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Đồng bộ nhân viên '${nv.hoTen}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Đồng bộ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      setState(() => isSyncing = true);
      await syn.syncOneNhanVien(nv);
      final updated = await NhanVienService().getNhanVienById(nv.id!);
      if (updated != null) {
        setState(() {
          widget.nhanVien.isSynced = updated.isSynced;
          widget.nhanVien.server_id = updated.server_id;
        });
      }
      await fetchUserInfo();
      setState(() => isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã đồng bộ nhân viên"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đồng bộ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(userInfo!.email ?? '',
            style: const TextStyle(color: Colors.green)),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () {},
              child: const Text("Sửa"),
            ),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Xác nhận"),
                    content: const Text("Bạn có chắc muốn xóa tài khoản này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Xóa",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                try{
                  final response = await ApiClient.delete(
                      "user/delete/${userInfo?.id}"
                  );
                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data["success"] == true) {
                      setState(() {
                        userInfo = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(data["message"] ?? "Xóa thành cônng"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(data["message"] ?? "Xóa thất bại"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Xóa",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        )
      ],
    );
  }
}
