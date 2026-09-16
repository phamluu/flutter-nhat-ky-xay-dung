enum TrialStatusResult {
  valid,
  expired,
  notFound,
  noUserInfo,
  noInternet,
  locked,
  licensed
}

extension TrialStatusResultExt on TrialStatusResult {
  String get description {
    switch (this) {
      case TrialStatusResult.valid:
        return 'Còn hạn dùng thử';
      case TrialStatusResult.expired:
        return 'Đã hết hạn dùng thử';
      case TrialStatusResult.notFound:
        return 'Chưa đăng ký sử dụng phần mềm';
      case TrialStatusResult.noUserInfo:
        return 'Chưa nhập thông tin đăng ký';
      case TrialStatusResult.noInternet:
        return 'Mất kết nối mạng / Không thể truy cập Server';
      case TrialStatusResult.locked:
        return 'Thiết bị của bạn đã bị khóa từ hệ thống';
      case TrialStatusResult.licensed:
        return 'Bạn đang dùng phiên bản pro';
    }
  }
}