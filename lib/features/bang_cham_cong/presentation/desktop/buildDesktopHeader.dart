import 'package:flutter/material.dart';

import '../../widgets/chotCongBtn.dart';

Widget buildDesktopHeader({
    required ThemeData theme,
    String? tenCongTrinh,
    String? thang,
    required bool daKhoa,
    required bool daChotLuong,
    required VoidCallback onChotCong
    })
{
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 18,
    ),
    child: Row(
      children: [
        // ICON
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            color: Colors.green.shade700,
            size: 26,
          ),
        ),

        const SizedBox(width: 14),

        // TITLE
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                "Sổ chấm công tháng ${thang}",
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tenCongTrinh
                    ?.trim()
                    .isNotEmpty ==
                    true
                    ? tenCongTrinh!
                    : "Quản lý chấm công và bảng lương",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),


        // MONTH
        ChotCongButton(
          daKhoa: daKhoa,
          daChotLuong: daChotLuong,
          onPressed: onChotCong,
        ),

        const SizedBox(width: 12),

        // REFRESH
        // OutlinedButton.icon(
        //   onPressed: _isLoading ? null : _load,
        //   icon: const Icon(
        //     Icons.refresh,
        //     size: 18,
        //   ),
        //   label: const Text("Làm mới"),
        // ),
      ],
    ),
  );
}