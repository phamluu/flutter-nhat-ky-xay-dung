import 'package:flutter/material.dart';

Widget statusBadge(Color progressColor, IconData statusIcon, String statusText) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: progressColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          statusIcon,
          size: 17,
          color: progressColor,
        ),

        const SizedBox(width: 7),

        Text(
          statusText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: progressColor,
          ),
        ),
      ],
    ),
  );
}