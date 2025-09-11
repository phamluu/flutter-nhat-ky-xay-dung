import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteScreen extends StatelessWidget {
  const WebsiteScreen({super.key});

  final List<Map<String, String>> websites = const [
    {"name": "Quản lý học phần", "url": "https://sinhvien.dhlc.art/"},
    {"name": "Website xây dựng", "url": "https://dhlc.art/"},
    {"name": "Web api", "url": "#"},
    {"name": "Website phiên bản cập nhật ", "url": "https://app.inanhonglen.com/"},
  ];

  // Future<void> _openWebsite(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw "Không mở được $url";
  //   }
  // }

  void _openWebsite(String url) {
    if (Platform.isAndroid) {
      const platform = MethodChannel('com.example.browser/open');
      platform.invokeMethod('openBrowser', {'url': url});
    } else if (Platform.isIOS) {
      const platform = MethodChannel('com.example.browser/open');
      platform.invokeMethod('openBrowser', {'url': url});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Website")),
      body: ListView.builder(
        itemCount: websites.length,
        itemBuilder: (context, index) {
          final site = websites[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.language_outlined, color: Colors.blueAccent),
              title: Text(site["name"] ?? ""),
              subtitle: Text(site["url"] ?? ""),
              onTap: () => _openWebsite(site["url"] ?? ""),
            ),
          );
        },
      ),
    );
  }
}
