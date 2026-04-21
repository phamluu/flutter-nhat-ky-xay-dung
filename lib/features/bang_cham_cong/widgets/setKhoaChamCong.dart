import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/services/cham_cong_service.dart';

import '../../../data/repositories/ChamCongRepository.dart';

Future<void> setkhoaChamCong({
  required BuildContext context,
  required int selectedMonth,
  required int selectedYear,
  required bool isKhoa,
  required bool daChotLuong
}) async {
  final ok = await showDialog(
    context: context,
    builder: (_) => daChotLuong ? AlertDialog(content: Text('Không thể mở khóa'),) : AlertDialog(
      title: Text("Xác nhận ${daChotLuong}"),
      content: Text(isKhoa ? "Khóa chấm công tháng $selectedMonth/$selectedYear?" :
      "Mở khóa chấm công tháng $selectedMonth/$selectedYear"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Huỷ")),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(isKhoa ? "Khóa" : "Mở khóa")),
      ],
    ),
  );

  if (ok == true) {
    final thang =
        "${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}";
    if(isKhoa){
      await ChamCongService(ChamCongRepository()).setKhoaChamCong(thang, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã khóa chấm công")),
      );
    }else{
      await ChamCongService(ChamCongRepository()).setKhoaChamCong(thang, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã mở khóa chấm công")),
      );
    }
  }
}