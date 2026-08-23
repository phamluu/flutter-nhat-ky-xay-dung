import 'package:flutter/material.dart';

import 'DesktopModuleCard.dart';

Widget moduleCard(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String value,
      required Color color,
      required Widget page,
    }) {
  return DesktopModuleCard(
    icon: icon,
    title: title,
    value: value,
    color: color,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );
    },
  );
}