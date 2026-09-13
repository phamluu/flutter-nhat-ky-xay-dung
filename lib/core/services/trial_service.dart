import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/device_service.dart';

class TrialService {
  static final TrialService instance = TrialService._internal();
  TrialService._internal();

  Timer? _timer;
  final ValueNotifier<bool> isTrialValidNotifier = ValueNotifier<bool>(true);
  String statusMessage = '';

  bool get isValid => isTrialValidNotifier.value;

  /// Khởi tạo khi mở App (Đọc Offline trước, sync Online sau)
  Future<void> init() async {
    await verifyLocalLicense();
    checkTrialStatus();
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

      String? expireDateStr = prefs.getString('trial_expire_date');
      String? storedDeviceId = prefs.getString('device_id');
      String currentDeviceId = await DeviceService.getWindowsDeviceId();

      if (storedDeviceId != null && storedDeviceId != currentDeviceId) {
        statusMessage = 'Mã bản quyền không hợp lệ cho thiết bị này.';
        isTrialValidNotifier.value = false;
        return false;
      }

      if (expireDateStr != null && expireDateStr.isNotEmpty) {
        // Thay khoảng trắng thành T để DateTime.parse không bị lỗi
        DateTime expireDate = DateTime.parse(expireDateStr.replaceAll(' ', 'T'));
        DateTime now = DateTime.now();

        // Anti-Time Rollback (Chống lùi giờ hệ thống)
        String? lastTimeStr = prefs.getString('last_used_time');
        if (lastTimeStr != null) {
          DateTime lastUsedTime = DateTime.parse(lastTimeStr);
          if (now.isBefore(lastUsedTime)) {
            statusMessage = 'Phát hiện thay đổi thời gian hệ thống!';
            isTrialValidNotifier.value = false;
            return false;
          }
        }
        await prefs.setString('last_used_time', now.toIso8601String());

        if (now.isBefore(expireDate)) {
          isTrialValidNotifier.value = true;
          statusMessage = '';
          return true;
        } else {
          statusMessage = 'Bản dùng thử đã hết hạn.';
          isTrialValidNotifier.value = false;
          return false;
        }
      }
    } catch (e) {
      debugPrint('Lỗi xác thực Local License: $e');
    }

    isTrialValidNotifier.value = false;
    statusMessage = 'Vui lòng kết nối mạng lần đầu để kích hoạt dùng thử.';
    return false;
  }

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
      'status_message': statusMessage.isNotEmpty
          ? statusMessage
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

  /// 2. Kiểm tra trạng thái từ Server (Ghi đè hạn dùng xuống máy)
  Future<bool> checkTrialStatus() async {
    try {
      String deviceId = await DeviceService.getWindowsDeviceId();
      final prefs = await SharedPreferences.getInstance();

      String? userName = prefs.getString('user_name');
      String? phone = prefs.getString('user_phone');

      if (userName == null || phone == null) {
        return await verifyLocalLicense();
      }

      final response = await http.post(
        Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/check-trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'user_name': userName,
          'phone': phone,
          'email': prefs.getString('user_email') ?? '',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'valid') {
          statusMessage = '';

          // Lưu ngày hết hạn từ WordPress xuống SharedPreferences
          if (data['expire_at'] != null) {
            await prefs.setString('trial_expire_date', data['expire_at'].toString());
            await prefs.setString('device_id', deviceId);
          }

          // Thông báo cập nhật ValueNotifier cho Banner nhận diện
          isTrialValidNotifier.value = true;
          return true;
        } else {
          statusMessage = data['message'] ?? 'Bản dùng thử đã hết hạn.';
          isTrialValidNotifier.value = false;
          return false;
        }
      }
    } catch (e) {
      debugPrint('Lỗi kết nối kiểm tra Trial: $e');
    }

    // Nếu mất mạng hoặc lỗi kết nối -> Fallback xác thực Offline từ máy
    return await verifyLocalLicense();
  }

  static Future<void> guard(BuildContext context, VoidCallback action) async {
    bool isValid = TrialService.instance.isValid;
    if (isValid) {
      action();
    } else {
      // Gọi Dialog nâng cấp
    }
  }

  Future<void> checkTrialPermission() async {
    if (!isValid) {
      throw Exception(
        statusMessage.isNotEmpty
            ? statusMessage
            : 'Bản dùng thử đã hết hạn. Vui lòng nâng cấp!',
      );
    }
  }
}