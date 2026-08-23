import 'package:flutter/material.dart';

import '../../data/models/ChamCongModel.dart';

Widget buildChuaKhoaAction(
    ChamCongNhanVienModel nv,
    ) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 9,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Chưa khóa CC",
          style: TextStyle(
            color: Colors.orange.shade800,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        if (nv.tongDaChi > 0)
          const SizedBox(height: 2),

        if (nv.tongDaChi > 0)
          Text(
            "Đã chi lương",
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
  );
}