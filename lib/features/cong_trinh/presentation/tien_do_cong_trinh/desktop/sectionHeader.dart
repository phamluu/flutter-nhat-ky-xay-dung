import 'package:flutter/material.dart';

Widget sectionHeader({
  required IconData icon,
  required String title,
}) {
  return Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
          const Color(0xff2563eb)
              .withOpacity(0.1),
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 19,
          color: const Color(0xff2563eb),
        ),
      ),

      const SizedBox(width: 10),

      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xff1e293b),
        ),
      ),
    ],
  );
}