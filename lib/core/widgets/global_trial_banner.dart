import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/trial_service.dart';

class GlobalTrialBanner extends StatelessWidget {
  const GlobalTrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TrialService.instance.isTrialValidNotifier,
      builder: (context, isValid, child) {
        if (isValid) return const SizedBox.shrink();

        return Material(
          color: Colors.amber.shade100,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.amber.shade400)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TrialService.instance.statusMessage.isNotEmpty
                        ? TrialService.instance.statusMessage
                        : 'Bản dùng thử đã hết hạn. Các tính năng Thêm/Sửa/Xóa đã bị khóa.',
                    style: const TextStyle(
                      color: Color(0xFF7A4D00),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => showUpgradeDialog(context),
                  child: const Text('Nâng cấp PRO'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 480,
          child: FutureBuilder<Map<String, dynamic>>(
            future: TrialService.instance.fetchConfig(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final config = snapshot.data ?? {};
              final String statusMsg = config['status_message'] ?? 'Bản dùng thử của bạn đã hết hạn.';
              final String hotline = config['hotline'] ?? '';
              final String zaloUrl = config['zalo_url'] ?? '';
              final List<dynamic> benefits = config['benefits'] ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Icon & Tiêu đề
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nâng cấp bản quyền PRO',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 2. Quyền lợi khi nâng cấp
                  if (benefits.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: benefits
                            .map((benefit) => _buildBenefitRow(benefit.toString()))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 3. Thông tin liên hệ nhanh
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_in_talk, color: Color(0xFF2C3E50), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hotline / Zalo tư vấn:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                hotline,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            if (zaloUrl.isNotEmpty) {
                              final uri = Uri.parse(zaloUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          child: const Text('Chat Zalo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Thao tác điều hướng
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Đóng (Xem dữ liệu cũ)', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            if (zaloUrl.isNotEmpty) {
                              final uri = Uri.parse(zaloUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          child: const Text(
                            'Nâng cấp ngay',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}