import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import 'package:nhat_ky_xay_dung/features/auth/presentation/mobile/login_mobile.dart';
import 'package:nhat_ky_xay_dung/features/auth/presentation/desktop/login_desktop.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/services/ApiClient.dart';
import '../../../../core/utils/AuthHelper.dart';
import '../../../../services/SyncService.dart';
import '../../../../viewmodel/UserModel.dart';

class SettingDesktop extends StatefulWidget {
  const SettingDesktop({super.key});

  @override
  State<SettingDesktop> createState() => _SettingDesktopState();
}

class _SettingDesktopState extends State<SettingDesktop> {
  UserInfo? userInfo;

  bool isLoggedIn = false;
  bool isAdmin = false;
  bool isLoading = false;

  final SyncService syncService = SyncService();

  int unsyncedCount = 0;
  int syncedCount = 0;

  String appVersion = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();

    checkLogin();
    loadSyncStatus();
    loadAppInfo();
  }

// ============================================================
// LOAD DATA
// ============================================================

  Future<void> loadSyncStatus() async {
    try {
      final countUnsynced = await syncService.getUnsyncedCount();
      final countSynced = await syncService.getSyncedCount();

      if (!mounted) return;

      setState(() {
        unsyncedCount = countUnsynced;
        syncedCount = countSynced;
      });
    } catch (e) {
      debugPrint("Lỗi lấy trạng thái đồng bộ: $e");
    }
  }

  Future<void> checkLogin() async {
    try {
      final auth = await AuthHelper.getAuthState();

      if (!mounted) return;

      setState(() {
        isLoggedIn = auth.isLoggedIn;
        isAdmin = auth.isAdmin;
      });

      if (isLoggedIn) {
        await fetchUserInfo();
      }
    } catch (e) {
      debugPrint("Lỗi kiểm tra đăng nhập: $e");
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final response = await ApiClient.get("user/me");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          userInfo = UserInfo.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy user: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (!mounted) return;

      setState(() {
        appVersion = info.version;
        buildNumber = info.buildNumber;
      });
    } catch (e) {
      debugPrint("Lỗi lấy thông tin app: $e");
    }
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildDesktopUI(context);
        }

        return _buildMobileUI(context);
      },
    );
  }

// ============================================================
// MOBILE UI
// ============================================================

  Widget _buildMobileUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
      ),
      body: isLoggedIn
          ? _buildLoggedInMobileUI(context)
          : _buildNotLoginMobileUI(context),
    );
  }

  Widget _buildNotLoginMobileUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 70,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            "Bạn chưa đăng nhập",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text("Đăng nhập"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginMobile(),
                ),
              ).then((_) => checkLogin());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInMobileUI(BuildContext context) {
    return ListView(
      children: [
// ========================================================
// USER PROFILE
// ========================================================

        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.person,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: CircularProgressIndicator(),
                      )
                    : userInfo == null
                        ? const Text(
                            "Không lấy được thông tin tài khoản",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userInfo!.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userInfo!.email,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),

        const Divider(),

// ========================================================
// LOGIN / LOGOUT
// ========================================================

        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Đăng xuất"),
          onTap: () => _logout(context),
        ),

// ========================================================
// ADMIN
// ========================================================

        if (isAdmin) ...[
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text("Đồng bộ dữ liệu"),
            subtitle: const Text(
              "Gửi dữ liệu lên server",
            ),
            onTap: () => _syncData(context),
          ),
          ListTile(
            leading: Icon(
              unsyncedCount == 0 ? Icons.cloud_done : Icons.cloud_upload,
              color: unsyncedCount == 0 ? Colors.green : Colors.orange,
            ),
            title: const Text("Trạng thái đồng bộ"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$syncedCount dữ liệu đã được đồng bộ",
                ),
                Text(
                  "Còn $unsyncedCount dữ liệu chưa đồng bộ",
                ),
              ],
            ),
          ),
        ],

        const Divider(),

// ========================================================
// GENERAL SETTINGS
// ========================================================

        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Cài đặt chung"),
          subtitle: const Text(
            "Ngôn ngữ, giao diện",
          ),
          onTap: () {},
        ),

// ========================================================
// ABOUT
// ========================================================

        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Thông tin ứng dụng"),
          subtitle: Text(
            "Phiên bản $appVersion ($buildNumber)",
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

// ============================================================
// DESKTOP UI
// ============================================================

  Widget _buildDesktopUI(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(),
                Expanded(
                  child: isLoggedIn
                      ? _buildDesktopContent(context)
                      : _buildDesktopNotLogin(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// DESKTOP SIDEBAR
// ============================================================



  Widget _desktopMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected ? Colors.blue.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? Colors.blue : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.grey[800],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
      ),
    );
  }

// ============================================================
// DESKTOP TOP BAR
// ============================================================

  Widget _buildDesktopTopBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xffeeeeee),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            "Cài đặt",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (isLoggedIn && userInfo != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    userInfo!.username.isNotEmpty
                        ? userInfo!.username[0].toUpperCase()
                        : "U",
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userInfo!.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

// ============================================================
// DESKTOP CONTENT
// ============================================================

  Widget _buildDesktopContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAccountCard(context),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSyncCard(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

// ============================================================
// DESKTOP PROFILE CARD
// ============================================================

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 38,
            child: Icon(
              Icons.person,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          if (isLoading)
            const CircularProgressIndicator()
          else if (userInfo != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo!.username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userInfo!.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? "Administrator" : "Người dùng",
                    style: TextStyle(
                      color: isAdmin ? Colors.orange[800] : Colors.blue[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          else
            const Text(
              "Không có thông tin tài khoản",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

// ============================================================
// DESKTOP ACCOUNT CARD
// ============================================================

  Widget _buildAccountCard(BuildContext context) {
    return _desktopCard(
      title: "Tài khoản",
      icon: Icons.person_outline,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.logout,
          ),
          title: const Text(
            "Đăng xuất",
          ),
          subtitle: const Text(
            "Đăng xuất khỏi tài khoản hiện tại",
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

// ============================================================
// DESKTOP SYNC CARD
// ============================================================

  Widget _buildSyncCard(BuildContext context) {
    if (!isAdmin) {
      return _desktopCard(
        title: "Đồng bộ dữ liệu",
        icon: Icons.sync,
        children: const [
          Text(
            "Bạn không có quyền thực hiện đồng bộ.",
          ),
        ],
      );
    }

    return _desktopCard(
      title: "Đồng bộ dữ liệu",
      icon: Icons.sync,
      children: [
        Row(
          children: [
            Expanded(
              child: _syncStat(
                icon: Icons.cloud_done,
                value: syncedCount,
                label: "Đã đồng bộ",
              ),
            ),
            Expanded(
              child: _syncStat(
                icon: Icons.cloud_upload,
                value: unsyncedCount,
                label: "Chưa đồng bộ",
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.sync,
            ),
            label: const Text(
              "Đồng bộ ngay",
            ),
            onPressed: () => _syncData(context),
          ),
        ),
      ],
    );
  }

  Widget _syncStat({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

// ============================================================
// DESKTOP APP INFO
// ============================================================

  Widget _buildAppInfoCard() {
    return _desktopCard(
      title: "Thông tin ứng dụng",
      icon: Icons.info_outline,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.apps,
          ),
          title: const Text(
            "Nhật ký xây dựng",
          ),
          subtitle: Text(
            "Phiên bản $appVersion ($buildNumber)",
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.settings_outlined,
          ),
          title: const Text(
            "Cài đặt chung",
          ),
          subtitle: const Text(
            "Ngôn ngữ, giao diện và các tùy chọn khác",
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () {},
        ),
      ],
    );
  }

// ============================================================
// DESKTOP NOT LOGIN
// ============================================================

  Widget _buildDesktopNotLogin(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              "Bạn chưa đăng nhập",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Đăng nhập để sử dụng đầy đủ các chức năng.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.login,
                ),
                label: const Text(
                  "Đăng nhập",
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginDesktop(),
                    ),
                  ).then((_) => checkLogin());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// COMMON CARD
// ============================================================

  Widget _desktopCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

// ============================================================
// LOGOUT
// ============================================================

  Future<void> _logout(BuildContext context) async {
    await AuthHelper.logout();

    if (!mounted) return;

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => isDesktop ? const LoginDesktop() : const LoginMobile(),
      ),
      (route) => false,
    );
  }

// ============================================================
// SYNC
// ============================================================

  Future<void> _syncData(BuildContext context) async {
    showWarmToast(context, message: "Đang đồng bộ...");

    try {
      await syncService.syncAll();

      await loadSyncStatus();

      if (!mounted) return;
      showSuccessToast(context, "Đồng bộ thành công");

    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, e, "Đồng bộ thất bại: ");

    }
  }
}
