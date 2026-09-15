// lib/core/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/shell/mobile_shell.dart';
import '../responsive/responsive_builder.dart';
import '../widgets/global_trial_banner.dart';
import 'desktop_shell.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      // Giao diện cho Mobile (chỉ trả về child hoặc bọc trong MobileShell/Scaffold với BottomNav)
      mobile: MobileShell(child: child),
      // Giao diện cho Desktop
      desktop: DesktopShell(child: child),
    );
  }
}