import 'package:flutter/material.dart';

import '../widgets/global_trial_banner.dart';
import 'desktop_sidebar.dart';

class DesktopShell extends StatelessWidget {
  final Widget child;

  const DesktopShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GlobalTrialBanner(),
          Expanded(
            child: Row(
              children: [
                const DesktopSidebar(),
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}