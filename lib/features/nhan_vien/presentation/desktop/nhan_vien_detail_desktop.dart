import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_dong_bo.dart';
import 'package:nhat_ky_xay_dung/features/auth/screens/DangKyScreen.dart';

import '../../../../core/services/ApiClient.dart';
import '../../../../core/utils/AuthHelper.dart';
import '../../../../services/SyncService.dart';
import '../../data/services/nhan_vien_service.dart';
import '../../../../viewmodel/UserModel.dart';
import '../../../auth/presentation/desktop/login_desktop.dart';
import '../../data/models/NhanVien.dart';
class NhanVienDetailDesktop extends StatefulWidget {
  final NhanVien nhanVien;

  const NhanVienDetailDesktop({
    super.key,
    required this.nhanVien,
  });

  @override
  State<NhanVienDetailDesktop> createState() =>
      _NhanVienDetailDesktopState();
}

class _NhanVienDetailDesktopState extends State<NhanVienDetailDesktop> {
  UserInfo? userInfo;

  bool isLoading = false;
  bool isSyncing = false;

  final SyncService syn = SyncService();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> fetchUserInfo() async {
    try {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final response = await ApiClient.get(
        "user/by-nhanvien/${widget.nhanVien.server_id}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            userInfo = UserInfo.fromJson(data);
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy user: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.nhanVien.hoTen ?? "Chi tiết nhân viên",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                _buildMainContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(radius: 42),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nhanVien.hoTen ?? "Không tên",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Mã nhân viên: ${widget.nhanVien.id ?? "-"}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.nhanVien.email?.isNotEmpty == true
                          ? widget.nhanVien.email!
                          : "Chưa có email",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildSyncBadge(),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildNhanVienInfo(),
              ),

              const SizedBox(width: 20),

              Expanded(
                flex: 4,
                child: _buildTaiKhoanSection(),
              ),
            ],
          );
        }

        // Tablet / màn hình nhỏ
        return Column(
          children: [
            _buildNhanVienInfo(),
            const SizedBox(height: 20),
            _buildTaiKhoanSection(),
          ],
        );
      },
    );
  }

  // ============================================================
  // THÔNG TIN NHÂN VIÊN
  // ============================================================

  Widget _buildNhanVienInfo() {
    return _DesktopCard(
      title: "Thông tin nhân viên",
      icon: Icons.person_outline,
      child: Column(
        children: [
          const SizedBox(height: 4),

          _buildAvatar(radius: 52),

          const SizedBox(height: 16),

          Text(
            widget.nhanVien.hoTen ?? "Không tên",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          _buildInfoItem(
            icon: Icons.badge_outlined,
            label: "Mã nhân viên",
            value: widget.nhanVien.id?.toString(),
          ),

          _buildInfoItem(
            icon: Icons.cake_outlined,
            label: "Ngày sinh",
            value: widget.nhanVien.ngaySinh?.toString(),
          ),

          _buildInfoItem(
            icon: Icons.email_outlined,
            label: "Email",
            value: widget.nhanVien.email,
          ),

          _buildInfoItem(
            icon: Icons.phone_outlined,
            label: "Số điện thoại",
            value: widget.nhanVien.soDienThoai,
          ),

          _buildInfoItem(
            icon: Icons.location_on_outlined,
            label: "Địa chỉ",
            value: widget.nhanVien.diaChi,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÀI KHOẢN
  // ============================================================

  Widget _buildTaiKhoanSection() {
    return FutureBuilder<bool>(
      future: AuthHelper.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _DesktopCard(
            title: "Tài khoản hệ thống",
            icon: Icons.account_circle_outlined,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final isLoggedIn = snapshot.data!;

        return _DesktopCard(
          title: "Tài khoản hệ thống",
          icon: Icons.account_circle_outlined,
          child: _buildAccountContent(isLoggedIn),
        );
      },
    );
  }

  Widget _buildAccountContent(bool isLoggedIn) {
    final isSynced =
        widget.nhanVien.isSynced == TrangThaiDongBo.dadongbo.value;

    final hasServerId = widget.nhanVien.server_id != null;

    if (!isLoggedIn) {
      return _buildLoginContent();
    }

    if (!isSynced || !hasServerId) {
      return _buildSyncContent();
    }

    if (userInfo == null) {
      return _buildRegisterContent();
    }

    return _buildUserInfo();
  }

  // ============================================================
  // CHƯA ĐĂNG NHẬP
  // ============================================================

  Widget _buildLoginContent() {
    return _AccountEmptyState(
      icon: Icons.lock_outline,
      title: "Chưa đăng nhập",
      description:
      "Bạn cần đăng nhập tài khoản quản trị để xem thông tin tài khoản.",
      buttonText: "Đăng nhập",
      buttonIcon: Icons.login,
      color: Colors.blue,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginDesktop(),
          ),
        );
      },
    );
  }

  // ============================================================
  // CHƯA ĐỒNG BỘ
  // ============================================================

  Widget _buildSyncContent() {
    return _AccountEmptyState(
      icon: Icons.sync_problem_outlined,
      title: "Nhân viên chưa được đồng bộ",
      description:
      "Hãy đồng bộ nhân viên lên hệ thống trước khi tạo tài khoản.",
      buttonText: isSyncing ? "Đang đồng bộ..." : "Đồng bộ nhân viên",
      buttonIcon: Icons.sync,
      color: Colors.green,
      loading: isSyncing,
      onPressed: isSyncing
          ? null
          : () {
        _syncNhanVien(widget.nhanVien);
      },
    );
  }

  // ============================================================
  // CHƯA CÓ TÀI KHOẢN
  // ============================================================

  Widget _buildRegisterContent() {
    return _AccountEmptyState(
      icon: Icons.person_add_alt_1_outlined,
      title: "Chưa có tài khoản",
      description:
      "Nhân viên đã được đồng bộ nhưng chưa có tài khoản đăng nhập.",
      buttonText: "Đăng ký tài khoản",
      buttonIcon: Icons.person_add,
      color: Colors.green,
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

        if (result == true) {
          fetchUserInfo();
        }
      },
    );
  }

  // ============================================================
  // THÔNG TIN TÀI KHOẢN
  // ============================================================

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.green.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tài khoản đang hoạt động",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userInfo!.email ?? "-",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "Quản lý tài khoản",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        _buildAccountAction(
          icon: Icons.email_outlined,
          title: "Thay đổi email",
          description: "Cập nhật địa chỉ email đăng nhập",
          color: Colors.blue,
          onPressed: _showEditEmailDialog,
        ),

        const SizedBox(height: 8),

        _buildAccountAction(
          icon: Icons.lock_reset_outlined,
          title: "Reset mật khẩu",
          description: "Tạo mật khẩu mới cho tài khoản",
          color: Colors.orange,
          onPressed: _resetPassword,
        ),

        const SizedBox(height: 8),

        _buildAccountAction(
          icon: Icons.delete_outline,
          title: "Xóa tài khoản",
          description: "Xóa tài khoản khỏi hệ thống",
          color: Colors.red,
          onPressed: _deleteAccount,
        ),
      ],
    );
  }

  // ============================================================
  // ACCOUNT ACTION
  // ============================================================

  Widget _buildAccountAction({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SYNC
  // ============================================================

  Future<void> _syncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác nhận đồng bộ"),
          content: Text(
            "Đồng bộ nhân viên '${nv.hoTen}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Không"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Đồng bộ"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      if (mounted) {
        setState(() => isSyncing = true);
      }

      await syn.syncOneNhanVien(nv);

      final updated = await NhanVienService().getNhanVienById(
        nv.id!,
      );

      if (updated != null && mounted) {
        setState(() {
          widget.nhanVien.isSynced = updated.isSynced;
          widget.nhanVien.server_id = updated.server_id;
        });
      }

      await fetchUserInfo();

      if (!mounted) return;

      setState(() => isSyncing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã đồng bộ nhân viên"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSyncing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đồng bộ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // EDIT EMAIL
  // ============================================================

  Future<String?> _showEditEmailDialog() async {
    final controller = TextEditingController(
      text: userInfo?.email,
    );

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thay đổi email"),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email mới",
                hintText: "Nhập email mới",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            FilledButton(
              onPressed: () {
                final email = controller.text.trim();

                if (email.isEmpty) return;

                Navigator.pop(context, email);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEmail() async {
    final newEmail = await _showEditEmailDialog();

    if (newEmail == null) return;

    try {
      final response = await ApiClient.put(
        "user/update-email/${userInfo!.id}",
        {
          "email": newEmail,
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data["success"] == true) {
        await fetchUserInfo();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật email thành công"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Cập nhật email thất bại",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _resetPassword() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset mật khẩu"),
          content: const Text(
            "Bạn có chắc muốn tạo lại mật khẩu cho tài khoản này?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await ApiClient.post(
        "user/reset-password/${userInfo!.id}",
        {},
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data["success"] == true) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text("Mật khẩu mới"),
              content: SelectableText(
                data["password"] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đã hiểu"),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Reset mật khẩu thất bại",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa tài khoản"),
          content: const Text(
            "Bạn có chắc muốn xóa tài khoản này?\n\n"
                "Thao tác này không thể hoàn tác.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa tài khoản"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await ApiClient.delete(
        "user/delete/${userInfo?.id}",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          setState(() {
            userInfo = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data["message"] ?? "Xóa tài khoản thành công",
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data["message"] ?? "Xóa tài khoản thất bại",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _buildAvatar({
    required double radius,
  }) {
    if (widget.nhanVien.hinhAnh != null &&
        widget.nhanVien.hinhAnh!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(
          widget.nhanVien.hinhAnh!,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade50,
      child: Icon(
        Icons.person,
        size: radius * 0.9,
        color: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildSyncBadge() {
    final isSynced =
        widget.nhanVien.isSynced == TrangThaiDongBo.dadongbo.value;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: isSynced
            ? Colors.green.withOpacity(0.08)
            : Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSynced
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            size: 18,
            color: isSynced
                ? Colors.green.shade700
                : Colors.orange.shade700,
          ),
          const SizedBox(width: 7),
          Text(
            isSynced ? "Đã đồng bộ" : "Chưa đồng bộ",
            style: TextStyle(
              color: isSynced
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String? value,
    bool showDivider = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 19,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DESKTOP CARD
// ================================================================

class _DesktopCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DesktopCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY ACCOUNT STATE
// ================================================================

class _AccountEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final IconData buttonIcon;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;

  const _AccountEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonIcon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: onPressed,
            icon: loading
                ? const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(buttonIcon),
            label: Text(buttonText),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}