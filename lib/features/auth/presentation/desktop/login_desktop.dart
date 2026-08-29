import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';

import '../../../../core/services/ApiClient.dart';
import '../../../../core/utils/AuthHelper.dart';
import 'package:nhat_ky_xay_dung/features/home/pages/HomeRouter.dart';

class LoginDesktop extends StatefulWidget {
  const LoginDesktop({super.key});

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;
  bool isHidePassword = true;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiClient.post(
        "Auth/login",
        {
          "Username": emailController.text.trim(),
          "Password": passwordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["token"] != null) {
        await AuthHelper.saveToken(data["token"]);

        if (!mounted) return;
        showSuccessToast(context, "Đăng nhập thành công");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeRouter(),
          ),
              (route) => false,
        );
      } else {
        if (!mounted) return;
        showWarmToast(context, message: data["message"] ??
            "Email hoặc mật khẩu không chính xác");
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, e, "Lỗi đăng nhập: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6f8),

      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),

            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(36),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            _buildHeader(),

            const SizedBox(height: 30),

            _buildEmailField(),

            const SizedBox(height: 18),

            _buildPasswordField(),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,

              child: TextButton(
                onPressed: () {
                  // TODO: Quên mật khẩu
                },

                child: const Text(
                  "Quên mật khẩu?",
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildLoginButton(),

            const SizedBox(height: 22),

            _buildRegister(),

            const SizedBox(height: 22),

            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(11),
              ),

              child: Icon(
                Icons.lock_open_outlined,
                color: Colors.blue.shade700,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Text(
                "Đăng nhập",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          "Đăng nhập để tiếp tục sử dụng hệ thống Nhật ký xây dựng.",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMAIL
  // ============================================================

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,

      keyboardType: TextInputType.emailAddress,

      decoration: _inputDecoration(
        label: "Email",
        hint: "Nhập email",
        icon: Icons.email_outlined,
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return "Vui lòng nhập email";
        }

        if (!value.contains("@")) {
          return "Email không hợp lệ";
        }

        return null;
      },
    );
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,

      obscureText: isHidePassword,

      decoration: _inputDecoration(
        label: "Mật khẩu",
        hint: "Nhập mật khẩu",
        icon: Icons.lock_outline,
      ).copyWith(
        suffixIcon: IconButton(
          tooltip: isHidePassword
              ? "Hiện mật khẩu"
              : "Ẩn mật khẩu",

          icon: Icon(
            isHidePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),

          onPressed: () {
            setState(() {
              isHidePassword = !isHidePassword;
            });
          },
        ),
      ),

      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return "Vui lòng nhập mật khẩu";
        }

        if (value.length < 6) {
          return "Mật khẩu tối thiểu 6 ký tự";
        }

        return null;
      },
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        size: 20,
      ),

      filled: true,
      fillColor: const Color(0xfffafafa),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: Colors.blue.shade600,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,

      child: FilledButton(
        onPressed: isLoading
            ? null
            : handleLogin,

        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue.shade700,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),

        child: isLoading
            ? const SizedBox(
          width: 21,
          height: 21,

          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons.login_outlined,
              size: 19,
            ),

            SizedBox(width: 8),

            Text(
              "Đăng nhập",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Widget _buildRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Text(
          "Chưa có tài khoản?",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),

        TextButton(
          onPressed: () {
            // TODO: chuyển sang màn hình đăng ký
          },

          child: const Text(
            "Đăng ký",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECURITY
  // ============================================================

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(8),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          Icon(
            Icons.security_outlined,
            size: 17,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              "Thông tin đăng nhập được bảo mật.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}