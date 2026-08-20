import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/settings/screens/SettingsScreen.dart';

import '../../../../core/responsive/responsive_builder.dart';
import '../desktop/setting_desktop.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: const SettingsScreen(),
      desktop: const SettingDesktop(),
    );
  }
}