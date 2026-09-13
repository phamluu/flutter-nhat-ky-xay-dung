import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/services/trial_service.dart';

import '../enum/feature_enum.dart';
import '../widgets/global_trial_banner.dart';

class PermissionManager {
  PermissionManager._privateConstructor();
  static final PermissionManager instance = PermissionManager._privateConstructor();

  /// Kiểm tra xem tính năng có được phép dùng hay không
  bool canAccess(FeatureEnum feature) {
    bool isTrialValid = TrialService.instance.isValid;

    switch (feature) {
    // Các tính năng yêu cầu bản quyền PRO / Trial còn hạn
      case FeatureEnum.saveKeHoach:
      case FeatureEnum.saveUngLuong:

        // Bảng chấm công
      case FeatureEnum.chamCongNgay:
      case FeatureEnum.chotCong:
      case FeatureEnum.huyChotCong:
      case FeatureEnum.chotLuong:
      case FeatureEnum.huyChotLuong:
      case FeatureEnum.chiLuong:

        // Thu chi
      case FeatureEnum.thuChi:
      case FeatureEnum.luuNhatKyCongTrinh:
        return isTrialValid;
    // Nếu có tính năng Free thì trả về true mặc định
      default:
        return true;
    }
  }

  /// Hàm bọc để thực thi hoặc chặn action
  Future<void> runWithPermission(
      BuildContext context, {
        required FeatureEnum feature,
        required VoidCallback action,
      }) async {
    // Cập nhật trạng thái mới nhất từ Server
    await TrialService.instance.checkTrialStatus();

    if (canAccess(feature)) {
      action();
    } else {
      GlobalTrialBanner.showUpgradeDialog(context);
    }
  }
}