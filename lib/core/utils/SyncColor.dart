import 'package:flutter/material.dart';

import 'trang_thai_dong_bo.dart';

class SyncColor {
  static Color background(int? status) {
    if (status == TrangThaiDongBo.chuadongbo.value || status == null) {
      return Colors.orange.shade50;
    }
    return Colors.white;
  }

  // static Color icon(int? status) {
  //   if (status == TrangThaiDongBo.chuadongbo.value || status == null) {
  //     return Colors.orange;
  //   }
  //   return Colors.green;
  // }
  static icon(int? status){
    if(status == TrangThaiDongBo.dadongbo.value) {
      return Icon(
        Icons.cloud_done,
        color: Colors.green,
        size: 18,
      );
    }else{
      return Icon(
        Icons.cloud_off,
        color: Colors.orange,
        size: 18,
      );
    }
  }
}