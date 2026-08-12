import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhat_ky_xay_dung/features/home/pages/HomeRouter.dart';
import 'package:nhat_ky_xay_dung/features/home/presentation/mobile/home_mobile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/ApiClient.dart';
import '../../../../core/utils/AuthHelper.dart';


class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isHidePassword = true;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    try {
      final response = await ApiClient.post(
        "Auth/login",
        {
          "Username": emailController.text.trim(),
          "Password": passwordController.text.trim(),
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        // TODO: lưu token
        final token = data["token"];
        await AuthHelper.saveToken(token);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Đăng nhập thành công", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeRouter()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("EXCEPTION: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Title
                  const Text(
                    "Đăng nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập email";
                      }
                      if (!value.contains("@")) {
                        return "Email không hợp lệ";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: isHidePassword,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isHidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isHidePassword = !isHidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu";
                      }
                      if (value.length < 6) {
                        return "Mật khẩu tối thiểu 6 ký tự";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// Button login
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Đăng nhập",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Forgot password
                  TextButton(
                    onPressed: () {},
                    child: const Text("Quên mật khẩu?"),
                  ),

                  /// Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Đăng ký"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeMobile()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text("Về trang chủ"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
}