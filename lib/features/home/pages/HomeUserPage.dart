import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/services/ApiClient.dart';
import '../../../viewmodel/UserModel.dart';
import '../../cong_trinh/presentation/cong_trinh/pages/cong_trinh_list_page.dart';
import '../../settings/screens/SettingsScreen.dart';
import '../widgets/ProjectList.dart';
import '../widgets/bottomNavigation.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState  extends  State<HomeUserPage> {
  UserInfo? userInfo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
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
  @override
  Widget build(BuildContext context) {
    final List<NavItem> items = [
      NavItem(
        icon: Icons.apartment,
        label: 'Công trình',
        page: const CongTrinhListPage(),
        color: Colors.blue,
      ),
      NavItem(
        icon: Icons.person,
        label: 'Tôi',
        page: const SettingsScreen(),
        color: Colors.grey,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhật ký xây dựng"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDashboard(),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 16),
          ProjectList(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: items,
        onTap: (item) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.page),
          );
        },
      ),
    );
  }
  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xin chào 👋",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Nhân viên",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userInfo?.email ?? "",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        )
      ],
    );
  }
  Widget _buildDashboard() {
    return Row(
      children: [
        _buildStatCard("Công trình", "3", Icons.apartment, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard("Ngày công", "12", Icons.calendar_today, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton("Chấm công", Icons.access_time, Colors.green),
        _buildActionButton("Nhật ký", Icons.edit_note, Colors.blue),
        _buildActionButton("Lương", Icons.attach_money, Colors.orange),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // TODO: navigate
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

}