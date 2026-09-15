import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../enum/TrialStatusResult.dart';
import '../services/trial_service.dart';

class GlobalTrialBanner extends StatefulWidget {
  const GlobalTrialBanner({super.key});

  @override
  State<GlobalTrialBanner> createState() => _GlobalTrialBannerState();

  /// Popup Đăng ký thông tin dùng thử
  /// Popup Đăng ký thông tin dùng thử (Đã tối ưu cho cả Mobile & Desktop)
  static Future<bool?> showRegisterDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => PopScope(
        canPop: false, // Ngăn bấm nút Back của hệ thống để thoát
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            // SỬA: Dùng constraints thay vì width cố định để co giãn tốt trên Mobile
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView( // SỬA: Bọc SingleChildScrollView tránh lỗi tràn bàn phím (bottom overflow)
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
                                'Kích hoạt dùng thử',
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
                          'Vui lòng điền thông tin để đăng ký bản dùng thử miễn phí:',
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
                          // Hiển thị loading indicator nếu cần
                          try{
                            bool success = await TrialService.instance.registerTrial(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                            if(success){
                              showSuccessToast(context, "Đăng ký thành công");
                            }else{
                              showErrorToast(context, "", "Đăng ký thất bại");
                            }
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop(success);
                            }
                          }catch(e){
                            showErrorToast(context, e, "Lỗi: ");
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
      ),
    );
  }

  /// Popup nâng cấp bản quyền PRO
  static void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
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
              final String statusMsg =
                  config['status_message'] ?? 'Bản dùng thử của bạn đã hết hạn.';
              final String hotline = config['hotline'] ?? '0335800619';
              final String zaloUrl = config['zalo_url'] ?? 'https://zalo.me/';
              final List<dynamic> benefits = config['benefits'] ?? [];

              return Stack(
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
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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
                                  const Text('Hotline / Zalo tư vấn:',
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Đóng (Xem dữ liệu cũ)',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'Đóng',
                    ),
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

class _GlobalTrialBannerState extends State<GlobalTrialBanner> {
  String _expireInfoText = '';
  bool _hasUserInfo = true;
  int _countDay = 0;

  @override
  void initState() {
    super.initState();
    _checkUserInfoAndShowDialog();
    _loadExpireInfo();
    TrialService.instance.isTrialValidNotifier.addListener(_loadExpireInfo);
  }

  @override
  void dispose() {
    TrialService.instance.isTrialValidNotifier.removeListener(_loadExpireInfo);
    super.dispose();
  }

  /// Tự động kiểm tra nếu chưa nhập thông tin thì mở Popup Đăng ký ngay khi mở App
  Future<void> _checkUserInfoAndShowDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_name');
    String? userPhone = prefs.getString('user_phone');

    if (userName == null || userName.isEmpty || userPhone == null || userPhone.isEmpty) {
      if (mounted) {
        setState(() => _hasUserInfo = false);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final ok = await GlobalTrialBanner.showRegisterDialog(context);
          if (ok == true && mounted) {
            setState(() => _hasUserInfo = true);
            _loadExpireInfo();
          }
        });
      }
    } else {
      TrialStatusResult result = await TrialService.instance.checkTrialStatus();
      if (result == TrialStatusResult.noUserInfo || result == TrialStatusResult.notFound) {
        if (mounted) {
          setState(() => _hasUserInfo = false);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final ok = await GlobalTrialBanner.showRegisterDialog(context);
            if (ok == true && mounted) {
              setState(() => _hasUserInfo = true);
              _loadExpireInfo();
            }
          });
        }
      } else {
        if (mounted) {
          setState(() => _hasUserInfo = true);
          _loadExpireInfo();
        }
      }
    }
  }

  /// Tính toán chi tiết thời hạn còn lại (Phút / Giờ / Ngày)
  /// Tính toán chi tiết thời hạn còn lại (Phút / Giờ / Ngày)
  Future<void> _loadExpireInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_name');
    String? userPhone = prefs.getString('user_phone');

    if (userName == null || userName.isEmpty || userPhone == null || userPhone.isEmpty) {
      if (mounted) {
        setState(() {
          _hasUserInfo = false;
          _expireInfoText = '';
          _countDay = 0; // Reset về 0
        });
      }
      return;
    }

    String? expireDateStr = prefs.getString('trial_expire_date');

    if (expireDateStr == null || expireDateStr.isEmpty) {
      if (mounted) {
        setState(() {
          _expireInfoText = '';
          _countDay = 0;
        });
      }
      return;
    }

    try {
      String formattedStr = expireDateStr.replaceAll(' ', 'T');
      DateTime? expireDate = DateTime.tryParse(formattedStr);

      if (expireDate == null) {
        if (mounted) {
          setState(() {
            _expireInfoText = '';
            _countDay = 0;
          });
        }
        return;
      }

      DateTime now = DateTime.now();
      Duration difference = expireDate.difference(now);

      String text = '';
      int calculatedDays = 0;

      if (difference.isNegative || difference.inSeconds <= 0) {
        text = 'Đã hết hạn';
        calculatedDays = 0;
        TrialService.instance.isTrialValidNotifier.value = false;
      } else {
        calculatedDays = difference.inDays;
        TrialService.instance.isTrialValidNotifier.value = true;

        if (difference.inDays > 0) {
          text = 'Còn ${difference.inDays} ngày';
        } else if (difference.inHours > 0) {
          text = 'Còn ${difference.inHours} giờ';
        } else {
          int minutes = difference.inMinutes;
          text = minutes > 0 ? 'Còn $minutes phút' : 'Sắp hết hạn';
        }
      }

      // ĐƯA TẤT CẢ VÀO TRONG SETSTATE ĐỂ FLUTTER BẮT BUỘC RE-RENDER
      if (mounted) {
        setState(() {
          _hasUserInfo = true;
          _countDay = calculatedDays; // Cập nhật số ngày mới tại đây
          _expireInfoText = text;
        });
      }
    } catch (e) {
      debugPrint('Lỗi parse ngày dùng thử: $e');
      if (mounted) {
        setState(() {
          _expireInfoText = '';
          _countDay = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TrialService.instance.isTrialValidNotifier,
      builder: (context, isValid, child) {
        // 0. Trường hợp còn hạn dùng thử trên 180 ngày (Bản mua PRO vĩnh viễn hoặc dài hạn) => Ẩn Banner
        if (isValid && _hasUserInfo && _countDay > 179) {
          return const SizedBox.shrink();
        }

        // 1. Trường hợp còn hạn dùng thử (Hiển thị Banner màu cam nhạt)
        if (isValid && _hasUserInfo) {
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
                      'Bản trải nghiệm ${_expireInfoText.isNotEmpty ? "($_expireInfoText)" : ""}',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    onPressed: () => GlobalTrialBanner.showUpgradeDialog(context),
                    child: const Text('Nâng cấp PRO', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Trường hợp Chưa nhập thông tin hoặc ĐÃ HẾT HẠN (Hiển thị Banner màu đỏ)
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
                    !_hasUserInfo
                        ? 'Chưa kích hoạt bản trải nghiệm. Vui lòng điền thông tin để đăng ký.'
                        : (TrialService.instance.statusMessage.isNotEmpty
                        ? TrialService.instance.statusMessage
                        : 'Thời gian trải nghiệm đã hết hạn. Các tính năng Thêm/Sửa/Xóa đã bị khóa.'),
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  onPressed: () async {
                    if (!_hasUserInfo) {
                      final ok = await GlobalTrialBanner.showRegisterDialog(context);
                      if (ok == true && mounted) {
                        setState(() => _hasUserInfo = true);
                        _loadExpireInfo();
                      }
                    } else {
                      GlobalTrialBanner.showUpgradeDialog(context);
                    }
                  },
                  child: Text(
                    !_hasUserInfo ? 'Đăng ký ngay' : 'Nâng cấp ngay',
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