import 'package:flutter/material.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';
import 'statusColor.dart';

Widget attendanceStatus({
  required String title,
  required String value,
  required IconData icon,
  required TrangThaiChamCong status,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: statusColor(status)
          .withOpacity(.07),
      borderRadius:
      BorderRadius.circular(10),
      border: Border.all(
        color: statusColor(status)
            .withOpacity(.18),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: statusColor(status)
                .withOpacity(.12),
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: statusColor(status),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 14,
                  color:
                  statusColor(status),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}