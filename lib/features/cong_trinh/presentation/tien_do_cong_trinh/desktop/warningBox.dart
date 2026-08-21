import 'package:flutter/material.dart';

Widget warningBox() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xfffff1f2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: const Color(0xfffecdd3),
      ),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Color(0xffdc2626),
          size: 20,
        ),

        SizedBox(width: 10),

        Expanded(
          child: Text(
            'Công việc đã quá hạn nhưng chưa hoàn thành.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xffb91c1c),
            ),
          ),
        ),
      ],
    ),
  );
}