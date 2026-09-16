import '../enum/TrialStatusResult.dart';

class TrialInfo {
  final TrialStatusResult status;
  final String message;
  final String expireText; // "Còn 5 ngày", "Còn 3 giờ", "Đã hết hạn", "Vĩnh viễn"
  final int daysLeft;      // Số ngày còn lại (dùng để ẩn/hiện Banner)
  final bool isPro;        // Trạng thái PRO

  TrialInfo({
    required this.status,
    required this.message,
    required this.expireText,
    required this.daysLeft,
    required this.isPro,
  });

  factory TrialInfo.empty() => TrialInfo(
    status: TrialStatusResult.noUserInfo,
    message: TrialStatusResult.noUserInfo.description,
    expireText: '',
    daysLeft: 0,
    isPro: false,
  );
}