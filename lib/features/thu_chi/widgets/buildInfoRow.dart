import 'package:flutter/material.dart';

Widget buildInfoRow(
    String title,
    String value, {
      Color? valueColor,
    }) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff64748b),
          ),
        ),
      ),

      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                const Color(0xff334155),
          ),
        ),
      ),
    ],
  );
}