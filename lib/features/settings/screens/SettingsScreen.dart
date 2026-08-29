import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';
import 'package:nhat_ky_xay_dung/features/auth/presentation/mobile/login_mobile.dart';
import '../../../core/services/ApiClient.dart';
import '../../../core/utils/AuthHelper.dart';
import '../../../services/SyncService.dart';
import '../../../viewmodel/UserModel.dart';
import '../../auth/presentation/desktop/login_desktop.dart';
import 'package:package_info_plus/package_info_plus.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserInfo? userInfo;
  bool isLoggedIn = false;
  bool isAdmin = false;
  bool isLoading = false;
  final syncService = SyncService();
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
  Future<void> loadSyncStatus() async {
    final counUnsyn = await syncService.getUnsyncedCount();
    final countSyn = await syncService.getSyncedCount();
    setState(() {
      unsyncedCount = counUnsyn;
      syncedCount = countSyn;
    });
  }
  Future<void> checkLogin() async {
    final auth = await AuthHelper.getAuthState();
    setState(() {
      isLoggedIn = auth.isLoggedIn;
      isAdmin = auth.isAdmin;
    });
    if (isLoggedIn) {
      await fetchUserInfo();
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiClient.get("user/me");
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
  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
      buildNumber = info.buildNumber;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cài đặt"),
        ),
        body:
            isLoggedIn ? _buildLoggedInUI(context) : _buildNotLoginUI(context));
  }

  Widget _buildNotLoginUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Bạn chưa đăng nhập"),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginMobile()),
              ).then((_) => checkLogin());
            },
            child: const Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUI(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                child: Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoggedIn
                    ? (userInfo == null
                        ? const CircularProgressIndicator()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userInfo!.username,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(userInfo!.email,
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ))
                    : const Text(
                        "Chưa đăng nhập",
                        style: TextStyle(color: Colors.grey),
                      ),
              )
            ],
          ),
        ),

        const Divider(),

        /// 🔐 LOGIN / LOGOUT
        ListTile(
          leading: const Icon(Icons.login),
          title: Text(isLoggedIn ? "Đăng xuất" : "Đăng nhập"),
          onTap: () async {
            if (isLoggedIn) {
              await AuthHelper.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginMobile()),
                (route) => false,
              );
              showSuccessToast(context, "Đã đăng xuất");

            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginMobile()),
              );
            }
          },
        ),

        if (isAdmin) ...[
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text("Đồng bộ dữ liệu"),
            subtitle: const Text("Gửi dữ liệu lên server"),
            onTap: () async {
              showWarmToast(context, message: "Đang đồng bộ...");

              await SyncService().syncAll();
              showSuccessToast(context, "Đồng bộ thành công");

            },
          ),
          /// 📊 SYNC STATUS
          ListTile(
            leading: Icon(
              syncedCount == 0 ? Icons.cloud_upload : Icons.cloud_done ,
              color: syncedCount == 0 ? Colors.orange : Colors.green ,
            ),
            title: const Text("Trạng thái đồng bộ"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${syncedCount} dữ liệu đã được đồng bộ"),
                Text("Còn ${unsyncedCount} dữ liệu chưa đồng bộ")
              ],),
          ),
        ],

        const Divider(),

        /// ⚙️ SETTINGS
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Cài đặt chung"),
          subtitle: const Text("Ngôn ngữ, giao diện"),
          onTap: () {},
        ),

        /// ℹ️ ABOUT
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("Thông tin ứng dụng"),
          subtitle: Text("Phiên bản $appVersion ($buildNumber)"),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
