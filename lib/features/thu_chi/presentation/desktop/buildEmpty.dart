import 'package:flutter/material.dart';

Widget buildEmpty() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xfff1f5f9),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            size: 30,
            color: Color(0xff94a3b8),
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          'Chưa có dữ liệu thu chi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xff334155),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Dữ liệu thu chi của công trình sẽ hiển thị tại đây.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    ),
  );
}