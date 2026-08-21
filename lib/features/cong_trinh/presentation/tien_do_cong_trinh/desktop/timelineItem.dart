import 'package:flutter/material.dart';

Widget timelineItem({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 21,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff64748b),
        ),
      ),

      const SizedBox(height: 3),

      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ],
  );
}