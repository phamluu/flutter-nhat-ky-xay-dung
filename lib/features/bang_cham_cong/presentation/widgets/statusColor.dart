import 'package:flutter/material.dart';

import '../../../../core/utils/trang_thai_cham_cong.dart';

Color statusColor(TrangThaiChamCong status ) {
  switch (status) {
    case TrangThaiChamCong.coMat:
      return Colors.green.shade700;

    case TrangThaiChamCong.khongXacDinh:
      return Colors.orange.shade800;

    case TrangThaiChamCong.vang:
      return Colors.red.shade700;

    default:
      return Colors.grey.shade700;
  }
}