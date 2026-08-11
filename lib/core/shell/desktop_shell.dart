import 'package:flutter/material.dart';

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
      body: Row(
        children: [
          const DesktopSidebar(),

          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}