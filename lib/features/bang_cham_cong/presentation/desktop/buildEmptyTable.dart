import 'package:flutter/material.dart';

Widget buildEmptyTable(String? thang) {
  return Center(
    child: Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            size: 34,
            color: Colors.grey.shade500,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          "Chưa có dữ liệu chấm công",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Không tìm thấy dữ liệu cho tháng "
              "$thang",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}