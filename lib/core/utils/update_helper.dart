import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateHelper {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Lấy version hiện tại từ app
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      final currentBuild = int.tryParse(info.buildNumber) ?? 0;
      // Gọi API JSON trên server
      final url = Uri.parse("https://app.inanhonglen.com/xaydung/update.json");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final latestVersion = data['latest_version'] ?? "";
        final latestBuild = int.tryParse(data['latest_build'].toString()) ?? 0;
        final downloadUrl = data['download_url'] ?? "";
        final forceUpdate = data['force_update'] ?? false;
        final message = data['message'] ?? "Có bản cập nhật mới";

        if (latestVersion.isNotEmpty &&
            downloadUrl.isNotEmpty &&
            _needUpdate(latestVersion, latestBuild, currentVersion, currentBuild)) {
          debugPrint("Current version: $currentVersion+$currentBuild");
          debugPrint("Latest version: $latestVersion+$latestBuild");

          _showUpdateDialog(context, message, downloadUrl, forceUpdate);
        }

      } else {
        debugPrint("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Bỏ qua update khi test: $e");
      }
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    List<int> latestParts =
    latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final latestNum = i < latestParts.length ? latestParts[i] : 0;
      final currentNum = i < currentParts.length ? currentParts[i] : 0;

      if (latestNum > currentNum) return true;
      if (latestNum < currentNum) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context, String message, String downloadUrl, bool forceUpdate) {
    showDialog(
      barrierDismissible: !forceUpdate,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cập nhật ứng dụng"),
          content: Text(message),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Để sau"),
              ),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi mở link tải: $e")),
                  );
                }
              },
              child: const Text("Cập nhật"),
            ),
          ],
        );
      },
    );
  }
  static bool _needUpdate(String latestVersion, int latestBuild, String currentVersion, int currentBuild) {
    if (_isNewerVersion(latestVersion, currentVersion)) return true;
    if (latestVersion == currentVersion && latestBuild > currentBuild) return true;
    return false;
  }

}
