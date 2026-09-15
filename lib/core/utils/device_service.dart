import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static Future<String> getWindowsDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    return windowsInfo.deviceId ?? ''; // Lấy Device ID duy nhất của Windows
  }

  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Lấy Android ID duy nhất của thiết bị
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      print('Lỗi lấy Device ID: $e');
    }
    return 'unknown_device';
  }
}