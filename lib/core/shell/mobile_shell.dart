// lib/core/shell/mobile_shell.dart
import 'package:flutter/material.dart';
import '../widgets/global_trial_banner.dart';

class MobileShell extends StatelessWidget {
  final Widget child;

  const MobileShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        // SafeArea tự căn chỉnh đúng lề trên (Status Bar) và lề dưới (Home Bar/Navigation Bar)
        child: Column(
          children: [
            const GlobalTrialBanner(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}