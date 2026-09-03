import 'package:flutter/material.dart';

import '../../../core/widgets/showErrorToast.dart';
import '../../../core/widgets/showSuccessToast.dart';
import '../data/repositories/cham_cong_luong_repo.dart';

Future<void> setKhoaChamCongTheoNhanVien({
  required BuildContext context,
  int? idBangChamCong,
  required DateTime dateSelected,
  Set<int>? selectedNhanVienIds,
}) async{
  try{
    final _repo = ChamCongLuongRepo();
    _repo.setKhoaChamCong(idBangChamCong, dateSelected, selectedNhanVienIds);
    showSuccessToast(context, "Đã chốt công");
  }catch(e){
    if (!context.mounted) return;
    showErrorToast(context, e, 'Không thể chốt chấm công: $e');
  }
}