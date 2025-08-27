import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateHelper {
  static Future<void> checkForUpdate(BuildContext context) async {
    // Lấy version hiện tại từ app
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    // Gọi API JSON trên server
    final url = Uri.parse("https://app.inanhonglen.com/xaydung/update.json");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final latestVersion = data['latest_version'];
      final downloadUrl = data['download_url'];
      final forceUpdate = data['force_update'] ?? false;
      final message = data['message'] ?? "Có bản cập nhật mới";

      if (currentVersion != latestVersion) {
        _showUpdateDialog(context, message, downloadUrl, forceUpdate);
      }
    }
  }

  static void _showUpdateDialog(
      BuildContext context, String message, String downloadUrl, bool forceUpdate) {
    showDialog(
      barrierDismissible: !forceUpdate,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cập nhật ứng dụng"),
          content: Text(message),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Để sau"),
              ),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text("Cập nhật"),
            ),
          ],
        );
      },
    );
  }
}
