import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../enum/TrialStatusResult.dart';
import '../models/TrialInfo.dart';
import '../services/trial_service.dart';
import 'RegisterResult.dart';

class GlobalTrialBanner extends StatefulWidget {
  const GlobalTrialBanner({super.key});

  @override
  State<GlobalTrialBanner> createState() => _GlobalTrialBannerState();

  /// Popup Đăng ký thông tin dùng thử
  /// Popup Đăng ký thông tin dùng thử (Đã tối ưu cho cả Mobile & Desktop)
  static Future<RegisterResult?> showRegisterDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController(); // Thêm controller license
    final formKey = GlobalKey<FormState>();

    return showDialog<RegisterResult?>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (ctx) => PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.assignment_ind_rounded, color: Color(0xFF2C3E50)),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Kích hoạt ứng dụng',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(false),
                          tooltip: 'Đóng',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nhập thông tin đăng ký dùng thử hoặc nhập Mã License nếu bạn đã mua bản quyền:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
                              if (v.trim().length < 9) return 'Số điện thoại không hợp lệ';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Ô NHẬP LICENSE KEY (TÙY CHỌN)
                          TextFormField(
                            controller: licenseController,
                            decoration: const InputDecoration(
                              labelText: 'Mã License Key (Không bắt buộc)',
                              hintText: 'VD: PRO-ABCD-1234',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.key),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              RegisterResult rs = await TrialService.instance.registerTrial(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                licenseKey: licenseController.text.trim(), // Truyền thêm licenseKey
                              );
                              if (rs.isSuccess) {
                                showSuccessToast(context, rs.message ?? 'Đăng ký thành công');
                              } else {
                                showErrorToast(context, "", rs.message ?? 'Đăng ký thất bại');
                              }
                              if (Navigator.canPop(ctx)) {
                                Navigator.of(ctx).pop(rs);
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                showErrorToast(context, e, "Lỗi: ");
                              }
                            }
                          }
                        },
                        child: const Text('Kích hoạt ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      );
    }

  static void showUpgradeDialog(BuildContext context) {
    final licenseController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // Dùng StatefulBuilder để quản lý trạng thái loading nút bấm
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  TrialService.instance.fetchConfig(),
                  TrialService.instance.checkTrialStatus(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final config = (snapshot.data?[0] as Map<String, dynamic>?) ?? {};
                  final check = (snapshot.data?[1] as TrialInfo);

                  final String statusMsg = check != null ? "${check.message}-${check.daysLeft} ngày"
                      : (config['status_message'] ?? '');
                  final String hotline = config['hotline'] ?? '0335800619';
                  final String zaloUrl = config['zalo_url'] ?? 'https://zalo.me/';
                  final List<dynamic> benefits = config['benefits'] ?? [];

                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
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
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),

                            // --- KHU VỰC NHẬP LICENSE KEY ---
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: licenseController,
                                    decoration: InputDecoration(
                                      labelText: 'Nhập mã License Key',
                                      hintText: 'VD: PRO-ABCD-1234',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.key),
                                      suffixIcon: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2C3E50),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                        onPressed: isSubmitting
                                            ? null
                                            : () async {
                                          if (formKey.currentState!.validate()) {
                                            setState(() => isSubmitting = true);
                                            try {
                                              // Gọi hàm kích hoạt license
                                              RegisterResult rs = await TrialService.instance.activateLicense(
                                                licenseKey: licenseController.text.trim(),
                                              );

                                              if (!ctx.mounted) return;

                                              if (rs.isSuccess) {
                                                showSuccessToast(context, rs.message ?? 'Kích hoạt bản quyền thành công!');
                                                if (Navigator.canPop(ctx)) {
                                                  Navigator.pop(ctx, true);
                                                }
                                              } else {
                                                showErrorToast(context, "", rs.message ?? 'Mã License không hợp lệ');
                                              }
                                            } catch (e) {
                                              if (ctx.mounted) showErrorToast(context, e, "Lỗi: ");
                                            } finally {
                                              setState(() => isSubmitting = false);
                                            }
                                          }
                                        },
                                        child: isSubmitting
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                            : const Text('Kích hoạt'),
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã License' : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
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
                                        const Text('Hotline / Zalo mua License:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text(
                                          hotline,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                                    },
                                    child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                            },
                            tooltip: 'Đóng',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
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

class _GlobalTrialBannerState extends State<GlobalTrialBanner> {
  @override
  void initState() {
    super.initState();
    // Gọi kiểm tra khi khởi tạo banner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCheck();
    });
  }

  Future<void> _initCheck() async {
    TrialInfo info = await TrialService.instance.checkTrialStatus();
    if ((info.status == TrialStatusResult.noUserInfo || info.status == TrialStatusResult.notFound) && mounted) {
      await TrialService.instance.clearTrialData();
      final rs = await GlobalTrialBanner.showRegisterDialog(context);
      if (rs != null && rs.isSuccess) {
        await TrialService.instance.checkTrialStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrialInfo>(
      valueListenable: TrialService.instance.trialInfoNotifier,
      builder: (context, info, child) {
        // 1. Ẩn Banner nếu là bản PRO hoặc còn trên 180 ngày
        if (info.isPro || info.daysLeft > 179) {
          return const SizedBox.shrink();
        }

        // 2. Trường hợp Còn hạn (Banner Vàng)
        if (info.status == TrialStatusResult.valid) {
          return Material(
            color: Colors.amber.shade50,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.amber.shade200)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bản trải nghiệm ${info.expireText.isNotEmpty ? "(${info.expireText})" : ""}',
                      style: const TextStyle(color: Color(0xFF7A4D00), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => GlobalTrialBanner.showUpgradeDialog(context),
                    child: const Text('Nâng cấp PRO', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Các trường hợp Hết hạn / Khóa / Mất mạng / Chưa nhập thông tin (Banner Đỏ)
        return Material(
          color: Colors.red.shade50,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.red.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.message,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    if (info.status == TrialStatusResult.noUserInfo || info.status == TrialStatusResult.notFound) {
                      final rs = await GlobalTrialBanner.showRegisterDialog(context);
                      if (rs != null && rs.isSuccess) {
                        await TrialService.instance.checkTrialStatus();
                      }
                    } else {
                      GlobalTrialBanner.showUpgradeDialog(context);
                    }
                  },
                  child: Text(
                    (info.status == TrialStatusResult.noUserInfo || info.status == TrialStatusResult.notFound)
                        ? 'Đăng ký ngay'
                        : 'Nâng cấp ngay',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}