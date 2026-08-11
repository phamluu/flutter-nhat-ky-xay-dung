import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppBreakpoints.desktop) {
      return desktop;
    }

    if (width >= AppBreakpoints.tablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}