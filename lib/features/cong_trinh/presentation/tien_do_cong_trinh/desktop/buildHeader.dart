import 'package:flutter/material.dart';

import '../../../data/models/TienDoCongTrinhModel.dart';
import 'iconButton.dart';

Widget buildHeader(BuildContext context, TienDoCongTrinhModel model,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onBack) {
  return Container(
    height: 76,
    padding: const EdgeInsets.symmetric(
      horizontal: 28,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    ),
    child: Row(
      children: [
        iconButton(
          icon: Icons.arrow_back,
          tooltip: 'Quay lại',
          onPressed: onBack ??
                  () {
                Navigator.pop(context);
              },
        ),

        const SizedBox(width: 16),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xff2563eb)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: Color(0xff2563eb),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Chi tiết tiến độ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1e293b),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                model.tenCongViec,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (onEdit != null) ...[
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
            ),
            label: const Text('Sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
              const Color(0xff2563eb),
              side: const BorderSide(
                color: Color(0xff2563eb),
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],

        if (onDelete != null) ...[
          const SizedBox(width: 10),

          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
            ),
            label: const Text('Xóa'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
              const Color(0xffdc2626),
              side: const BorderSide(
                color: Color(0xffdc2626),
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}