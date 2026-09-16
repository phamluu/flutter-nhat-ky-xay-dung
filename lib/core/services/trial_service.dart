import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../enum/TrialStatusResult.dart';
import '../models/TrialInfo.dart';
import '../utils/device_service.dart';
import '../widgets/RegisterResult.dart';

class TrialService {
  static final TrialService instance = TrialService._internal();
  TrialService._internal();

  Timer? _timer;
  final ValueNotifier<bool> isTrialValidNotifier = ValueNotifier<bool>(true);
  String statusMessage = '';

  bool get isValid => isTrialValidNotifier.value;

  /// Khởi tạo khi mở App (Đọc Offline trước, sync Online sau)
  Future<void> init() async {
    bool hasLocal = await verifyLocalLicense();
    if (hasLocal) {
      await checkTrialStatus();
    }
  }

  void startPeriodicCheck({Duration interval = const Duration(minutes: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await checkTrialStatus();
    });
  }

  void stopCheck() {
    _timer?.cancel();
  }

  /// 1. Kiểm tra Offline từ SharedPreferences
  Future<bool> verifyLocalLicense() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? expireDateStr =
      prefs.getString('trial_expire_date');

      final String? storedDeviceId =
      prefs.getString('device_id');

      // Không có license local
      if (expireDateStr == null || expireDateStr.isEmpty) {
        statusMessage =
        'Vui lòng kết nối mạng lần đầu để kích hoạt dùng thử.';
        isTrialValidNotifier.value = false;
        return false;
      }

      // Lấy Device ID
      final String currentDeviceId = await DeviceService.getDeviceId();

      // Không lấy được Device ID => KHÓA
      if (currentDeviceId.isEmpty) {
        await prefs.setBool('is_locked', true);

        statusMessage =
        'Không thể xác thực thiết bị. Ứng dụng đã bị khóa.';
        isTrialValidNotifier.value = false;

        debugPrint(
          'Local License ERROR: Không lấy được Device ID',
        );

        return false;
      }

      // Có device ID đã lưu nhưng không trùng
      if (storedDeviceId != null &&
          storedDeviceId.isNotEmpty &&
          storedDeviceId != currentDeviceId) {
        await prefs.setBool('is_locked', true);

        statusMessage =
        'Mã bản quyền không hợp lệ cho thiết bị này.';
        isTrialValidNotifier.value = false;

        debugPrint(
          'Local License ERROR: Device ID không khớp',
        );

        return false;
      }

      // Parse ngày hết hạn
      final DateTime? expireDate = DateTime.tryParse(
        expireDateStr.replaceAll(' ', 'T'),
      );

      if (expireDate == null) {
        await prefs.setBool('is_locked', true);

        statusMessage =
        'Dữ liệu bản quyền không hợp lệ. Ứng dụng đã bị khóa.';
        isTrialValidNotifier.value = false;

        debugPrint(
          'Local License ERROR: expireDate không hợp lệ',
        );

        return false;
      }

      final DateTime now = DateTime.now();

      // Anti rollback
      final String? lastTimeStr =
      prefs.getString('last_used_time');

      if (lastTimeStr != null && lastTimeStr.isNotEmpty) {
        final DateTime? lastUsedTime =
        DateTime.tryParse(lastTimeStr);

        if (lastUsedTime == null) {
          await prefs.setBool('is_locked', true);

          statusMessage = 'Dữ liệu thời gian không hợp lệ. Ứng dụng đã bị khóa.';
          isTrialValidNotifier.value = false;

          return false;
        }

        if (now.isBefore(lastUsedTime)) {
          await prefs.setBool('is_locked', true);

          statusMessage ='Phát hiện thay đổi thời gian hệ thống.';
          isTrialValidNotifier.value = false;

          return false;
        }
      }

      await prefs.setString(
        'last_used_time',
        now.toIso8601String(),
      );

      // Hết hạn
      if (!now.isBefore(expireDate)) {
        isTrialValidNotifier.value = false;

        statusMessage =
        'Bản dùng thử đã hết hạn.';

        return false;
      }

      // Tất cả hợp lệ
      await prefs.setBool('is_locked', false);

      isTrialValidNotifier.value = true;
      statusMessage = '';

      return true;
    } catch (e, stackTrace) {
      // =====================================================
      // QUAN TRỌNG:
      // BẤT KỲ LỖI NÀO TRONG QUÁ TRÌNH XÁC THỰC
      // => FAIL CLOSED => KHÓA APP
      // =====================================================

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_locked', true);
      } catch (_) {}

      isTrialValidNotifier.value = false;

      statusMessage = 'Không thể xác thực bản quyền. Ứng dụng đã bị khóa.';

      debugPrint(
        'Lỗi xác thực Local License: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      return false;
    }
  }

  // Lấy cấu hình văn bản nâng cấp
  Future<Map<String, dynamic>> fetchConfig() async {
    try {
      final response = await http
          .get(Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/get-config'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Lỗi tải cấu hình Trial: $e');
    }

    return {
      'status_message': statusMessage.isNotEmpty ? statusMessage
          : 'Bản dùng thử của bạn đã hết hạn. Hãy nâng cấp để sử dụng trọn bộ tính năng.',
      'hotline': '0335800619',
      'zalo_url': 'https://zalo.me/',
      'benefits': [
        'Không giới hạn thêm, sửa, xóa công trình',
        'Xuất báo cáo PDF & Excel không dính watermark',
        'Đồng bộ dữ liệu an toàn trên Cloud',
        'Hỗ trợ kỹ thuật 24/7 & Cập nhật miễn phí',
      ]
    };
  }

  final ValueNotifier<TrialInfo> trialInfoNotifier = ValueNotifier<TrialInfo>(TrialInfo.empty());
  /// 2. Kiểm tra trạng thái từ Server (Ghi đè hạn dùng xuống máy)
  Future<TrialInfo> checkTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    TrialInfo result;

    try {
      String deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/check-trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String status = data['status'] ?? '';
        String? expireAtStr = data['expire_at'];

        if (expireAtStr != null) {
          await prefs.setString('trial_expire_date', expireAtStr);
        }

        if (status == 'licensed') {
          await prefs.setBool('is_locked', false);
          result = _buildInfo(TrialStatusResult.licensed, 'Bản quyền PRO vĩnh viễn', expireAtStr, isPro: true);
        } else if (status == 'locked' || status == 'license_locked') {
          await prefs.setBool('is_locked', true);
          result = _buildInfo(
              TrialStatusResult.locked,
              status == 'license_locked' ? 'Mã License của bạn đã bị khóa.' : TrialStatusResult.locked.description,
              expireAtStr
          );
        } else if (status == 'valid') {
          await prefs.setBool('is_locked', false);
          result = _buildInfo(TrialStatusResult.valid, TrialStatusResult.valid.description, expireAtStr);
        } else if (status == 'expired' || status == 'license_expired') {
          result = _buildInfo(
              TrialStatusResult.expired,
              status == 'license_expired' ? 'Mã License của bạn đã hết hạn.' : TrialStatusResult.expired.description,
              expireAtStr
          );
        } else { // not_found
          String? userName = prefs.getString('user_name');
          if (userName == null || userName.isEmpty) {
            result = _buildInfo(TrialStatusResult.noUserInfo, TrialStatusResult.noUserInfo.description, null);
          } else {
            result = _buildInfo(TrialStatusResult.notFound, TrialStatusResult.notFound.description, null);
          }
        }
      } else {
        result = _checkLocalFallback(prefs);
      }
    } catch (e) {
      result = _checkLocalFallback(prefs);
    }

    // Cập nhật trạng thái mở/khóa app
    isTrialValidNotifier.value = (result.status == TrialStatusResult.valid || result.status == TrialStatusResult.licensed);
    statusMessage = result.message;

    // Phát tín hiệu cho UI Banner
    trialInfoNotifier.value = result;
    return result;
  }

  TrialInfo _buildInfo(TrialStatusResult status, String message, String? expireStr, {bool isPro = false}) {
    if (isPro || expireStr == null || expireStr.isEmpty) {
      return TrialInfo(
        status: status,
        message: message,
        expireText: isPro ? 'Bản PRO' : '',
        daysLeft: isPro ? 9999 : 0,
        isPro: isPro,
      );
    }

    DateTime? expireDate = DateTime.tryParse(expireStr.replaceAll(' ', 'T'));
    if (expireDate == null) {
      return TrialInfo(status: status, message: message, expireText: '', daysLeft: 0, isPro: false);
    }

    Duration diff = expireDate.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) {
      return TrialInfo(
        status: TrialStatusResult.expired,
        message: 'Bản dùng thử đã hết hạn',
        expireText: 'Đã hết hạn',
        daysLeft: 0,
        isPro: false,
      );
    }

    String text = '';
    if (diff.inDays > 0) {
      text = 'Còn ${diff.inDays} ngày';
    } else if (diff.inHours > 0) {
      text = 'Còn ${diff.inHours} giờ';
    } else {
      text = 'Còn ${diff.inMinutes} phút';
    }

    return TrialInfo(
      status: status,
      message: message,
      expireText: text,
      daysLeft: diff.inDays,
      isPro: false,
    );
  }
  /// Tải dữ liệu Offline khi không kết nối được Server
  TrialInfo _checkLocalFallback(SharedPreferences prefs) {
    bool isLocked = prefs.getBool('is_locked') ?? false;
    if (isLocked) {
      return _buildInfo(TrialStatusResult.locked, 'Thiết bị đã bị khóa từ hệ thống (Offline).', null);
    }

    String? expireStr = prefs.getString('trial_expire_date');
    if (expireStr == null) {
      return _buildInfo(TrialStatusResult.noInternet, TrialStatusResult.noInternet.description, null);
    }

    TrialInfo info = _buildInfo(TrialStatusResult.valid, TrialStatusResult.valid.description, expireStr);
    if (info.daysLeft <= 0 && info.expireText == 'Đã hết hạn') {
      return _buildInfo(TrialStatusResult.noInternet, TrialStatusResult.noInternet.description, null);
    }
    return info;
  }

  TrialStatusResult _checkLocalExpire(SharedPreferences prefs) {
    String? expireDateStr = prefs.getString('trial_expire_date');
    if (expireDateStr == null) return TrialStatusResult.expired;

    DateTime? expireDate = DateTime.tryParse(expireDateStr.replaceAll(' ', 'T'));
    if (expireDate == null || DateTime.now().isAfter(expireDate)) {
      isTrialValidNotifier.value = false;
      statusMessage = 'Bản dùng thử đã hết hạn (Offline).';
      return TrialStatusResult.expired;
    }

    isTrialValidNotifier.value = true;
    return TrialStatusResult.valid;
  }

  /// 3. HÀM ĐĂNG KÝ MỚI (CHỈ GỌI KHI NGƯỜI DÙNG BẤM "KÍCH HOẠT NGAY")
  Future<RegisterResult> registerTrial({
    required String name,
    required String phone,
    String email = '',
    String? licenseKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/register-trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'user_name': name,
          'phone': phone,
          'email': email,
          'license_key': licenseKey?.trim(),
        }),
      ).timeout(const Duration(seconds: 7));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Chuẩn hóa status về dạng chuỗi viết thường để so sánh chính xác
        String status = (data['status'] ?? '').toString().toLowerCase().trim();

        bool isOk = status == 'success' || status == 'valid' || status == 'licensed';

        if (isOk) {
          // Lưu thông tin người dùng vào Local Storage
          await prefs.setString('user_name', name);
          await prefs.setString('user_phone', phone);
          await prefs.setString('user_email', email);
          await prefs.setString('device_id', deviceId);

          if (data['license_key'] != null && data['license_key'].toString().isNotEmpty) {
            await prefs.setString('license_key', data['license_key'].toString());
          }
          if (data['expire_at'] != null) {
            await prefs.setString('trial_expire_date', data['expire_at'].toString());
          }

          // Đồng bộ trạng thái mới cho Banner
          await checkTrialStatus();

          return RegisterResult(
            isSuccess: true,
            message: data['message'] ?? 'Kích hoạt thành công!',
          );
        } else {
          return RegisterResult(
            isSuccess: false,
            message: data['message'] ?? 'Kích hoạt thất bại.',
          );
        }
      } else {
        return RegisterResult(
          isSuccess: false,
          message: data['message'] ?? 'Mã License không hợp lệ hoặc đã được sử dụng.',
        );
      }
    } catch (e) {
      debugPrint('Lỗi kích hoạt/đăng ký: $e');
      return RegisterResult(
        isSuccess: false,
        message: 'Lỗi kết nối máy chủ: $e',
      );
    }
  }
  Future<void> clearTrialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('trial_expire_date');
    await prefs.remove('device_id');
  }
  /// Kích hoạt License Key trực tiếp
  /// Kích hoạt License Key bằng device_id và license_key
  Future<RegisterResult> activateLicense({required String licenseKey}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/activate-license'), // Thay đúng endpoint API kích hoạt
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'license_key': licenseKey,
        }),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        // Cập nhật ngày hết hạn mới nếu Server trả về
        if (data['expires_at'] != null) {
          await prefs.setString('trial_expire_date', data['expires_at']);
        }
        // Mở khóa ứng dụng
        await prefs.setBool('is_locked', false);
        isTrialValidNotifier.value = true;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        isTrialValidNotifier.notifyListeners();
        return RegisterResult(
          isSuccess: true,
          message: data['message'] ?? 'Kích hoạt bản quyền thành công!',
        );
      } else {
        return RegisterResult(
          isSuccess: false,
          message: data['message'] ?? 'Kích hoạt thất bại',
        );
      }
    } catch (e) {
      debugPrint('Lỗi kích hoạt License: $e');
      return RegisterResult(
        isSuccess: false,
        message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!',
      );
    }
  }
}