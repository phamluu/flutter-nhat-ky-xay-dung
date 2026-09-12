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
  // cờ đánh dấu trạng thái bản quyền/dùng thử
  final ValueNotifier<bool> isTrialValidNotifier = ValueNotifier<bool>(true);
  String statusMessage = '';

  bool get isValid => isTrialValidNotifier.value;

  /// Khởi chạy kiểm tra định kỳ ngầm
  void startPeriodicCheck({Duration interval = const Duration(minutes: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await checkTrialStatus();
    });
  }

  void stopCheck() {
    _timer?.cancel();
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

    // Giá trị fallback mặc định nếu lỗi mạng
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
  /// Kiểm tra trạng thái từ máy chủ
  Future<bool> checkTrialStatus() async {
    try {
      String deviceId = await DeviceService.getWindowsDeviceId();
      final prefs = await SharedPreferences.getInstance();

      String? userName = prefs.getString('user_name');
      String? phone = prefs.getString('user_phone');

      // Chưa đăng ký thông tin -> Coi như chưa kích hoạt
      if (userName == null || phone == null) {
        statusMessage = 'Vui lòng đăng ký dùng thử để kích hoạt đầy đủ tính năng.';
        isTrialValidNotifier.value = false;
        return false;
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
          isTrialValidNotifier.value = true;
          statusMessage = '';
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
    // Giữ trạng thái cũ nếu lỗi mạng
    return isTrialValidNotifier.value;
  }

  /// Bọc các chức năng cần khóa bản quyền
  static Future<void> guard(BuildContext context, VoidCallback action) async {
    bool isValid = await TrialService.instance.checkTrialStatus();

    if (isValid) {
      action(); // Còn hạn -> Thực thi chức năng
    } else {
      if (context.mounted) {
        // Hết hạn -> Hiện Dialog yêu cầu nâng cấp thay vì chuyển màn hình
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Text('Tính năng nâng cao'),
              ],
            ),
            content: Text(
              TrialService.instance.statusMessage.isNotEmpty
                  ? TrialService.instance.statusMessage
                  : 'Chức năng này yêu cầu bản quyền để tiếp tục sử dụng.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50)),
                onPressed: () {
                  Navigator.pop(ctx);
                  // Mở trang đăng ký hoặc mua bản quyền
                },
                child: const Text('Nâng cấp ngay', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> checkTrialPermission() async {
    bool isValid = await TrialService.instance.checkTrialStatus();
    if (!isValid) {
      throw Exception(
        TrialService.instance.statusMessage.isNotEmpty
            ? TrialService.instance.statusMessage
            : 'Bản dùng thử đã hết hạn. Vui lòng nâng cấp!',
      );
    }
  }
}