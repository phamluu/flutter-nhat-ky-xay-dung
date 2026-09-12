import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static Future<String> getWindowsDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    return windowsInfo.deviceId ?? ''; // Lấy Device ID duy nhất của Windows
  }
}