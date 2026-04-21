import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/ApiClient.dart';
import '../../../core/utils/AuthHelper.dart';
import '../../home/pages/home_page.dart';

class Dangkyscreen extends StatefulWidget {
  final String? nhanVienId;
  final String? tenNhanVien;
  const Dangkyscreen({super.key, this.nhanVienId, this.tenNhanVien });

  @override
  State<Dangkyscreen> createState() => _DangkyscreenState();
}

class _DangkyscreenState extends State<Dangkyscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isHidePassword = true;

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    try {
      final response = await ApiClient.post(
        "Auth/register-member",
        {
          "Username": userNameController.text.trim(),
          "Email":emailController.text.trim(),
          "Password": passwordController.text.trim(),
          "NhanVienId": widget.nhanVienId
        },
      );
      print("NhanVienId: ${widget.nhanVienId}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(data['message'], style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,),
        );
        Navigator.pop(context, true);
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
        title: const Text("Đăng ký tài khoản"),
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
                  Column(
                    children: [
                      const Text(
                        "Đăng ký tài khoản",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text("Nhân viên: ${widget.tenNhanVien}",
                        style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),)
                    ],
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.verified_user),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập username";
                      }
                      return null;
                    },
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

                  const SizedBox(height: 30),

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
                        "Đăng ký",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}