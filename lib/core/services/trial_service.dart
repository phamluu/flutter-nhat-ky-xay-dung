import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../enum/TrialStatusResult.dart';
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

          statusMessage =
          'Dữ liệu thời gian không hợp lệ. Ứng dụng đã bị khóa.';
          isTrialValidNotifier.value = false;

          return false;
        }

        if (now.isBefore(lastUsedTime)) {
          await prefs.setBool('is_locked', true);

          statusMessage =
          'Phát hiện thay đổi thời gian hệ thống.';
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

      statusMessage =
      'Không thể xác thực bản quyền. Ứng dụng đã bị khóa.';

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
  Future<TrialStatusResult> checkTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String? userName = prefs.getString('user_name');
      String? phone = prefs.getString('user_phone');
      // Nếu chưa nhập thông tin
      if (userName == null || userName.isEmpty || phone == null || phone.isEmpty) {
        statusMessage = 'Vui lòng nhập thông tin để kích hoạt bản dùng thử.';
        isTrialValidNotifier.value = false;
        return TrialStatusResult.noUserInfo;
      }
      String deviceId = await DeviceService.getDeviceId();
      // Chỉ gửi device_id lên để kiểm tra, tuyệt đối KHÔNG gửi thông tin cá nhân để insert
      final response = await http.post(
        Uri.parse('https://inanhonglen.com/wp-json/app-trial/v1/check-trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String status = data['status'] ?? '';
        if (data['expire_at'] != null) {
          await prefs.setString('trial_expire_date', data['expire_at']);
        }
        // TRƯỜNG HỢP 1: THIẾT BỊ BỊ KHÓA TỪ API
        if (status == 'locked') {
          await prefs.setBool('is_locked', true); // Lưu lại bộ nhớ local
          isTrialValidNotifier.value = false;
          statusMessage = 'Thiết bị của bạn đã bị khóa từ hệ thống.';
          return TrialStatusResult.locked;
        }else{
          await prefs.setBool('is_locked', false);
        }
        if (status == 'valid') {
          if (isTrialValidNotifier.value == true) {
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            isTrialValidNotifier.notifyListeners();
          } else {
            isTrialValidNotifier.value = true;
          }
          return TrialStatusResult.valid;
        }
        // TRƯỜNG HỢP 3: HẾT HẠN
        if (status == 'expired') {
          isTrialValidNotifier.value = false;
          statusMessage = 'Bản dùng thử của bạn đã hết hạn.';
          return TrialStatusResult.expired;
        }
        if (status == 'not_found') {
          return TrialStatusResult.notFound;
        }
      }
    } catch (e) {
      debugPrint('Không kết nối được API (Offline): $e');
      // --- XỬ LÝ KHI MẤT MẠNG / KHÔNG GỌI ĐƯỢC API ---
      bool isLocked = prefs.getBool('is_locked') ?? false;
      // Nếu trước đó API đã từng trả về "Khóa", khi mất mạng VẪN GIỮ KHÓA
      if (isLocked) {
        isTrialValidNotifier.value = false;
        statusMessage = 'Thiết bị đã bị khóa từ hệ thống (Offline).';
        return TrialStatusResult.locked;
      }
      // Nếu chưa bị khóa, đối chiếu ngày hết hạn local
      return _checkLocalExpire(prefs);
    }
    return isTrialValidNotifier.value ? TrialStatusResult.valid : TrialStatusResult.expired;
    // return await verifyLocalLicense();
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
  Future<bool> registerTrial({ required String name, required String phone, String email = '',}) async {
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
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' || data['status'] == 'valid') {
          await prefs.setString('user_name', name);
          await prefs.setString('user_phone', phone);
          await prefs.setString('user_email', email);
          await prefs.setString('device_id', deviceId);

          if (data['expire_at'] != null) {
            await prefs.setString('trial_expire_date', data['expire_at'].toString());
          }

          isTrialValidNotifier.value = true;
          statusMessage = '';
          return true;
        }
      }
    } catch (e) {
      debugPrint('Lỗi đăng ký dùng thử: $e');
    }
    return false;
  }
  Future<void> clearTrialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('trial_expire_date');
    await prefs.remove('device_id');
  }

}