import 'package:flutter/material.dart';

import '../../../core/utils/trang_thai_cham_cong.dart';

Widget radioCompact({
  required TrangThaiChamCong value,
  required TrangThaiChamCong? groupValue,
  required Function(TrangThaiChamCong?) onChanged,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Radio<TrangThaiChamCong>(
        value: value,
        groupValue: groupValue,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: onChanged,
      ),
      Text(value.label),
      const SizedBox(width: 8),
    ],
  );
}