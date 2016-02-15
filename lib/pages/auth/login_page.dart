// lib/pages/auth/login_page.dart
// Halaman login aplikasi dengan field email & password lebih clean.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/pages/admin/home_page.dart';
import 'package:flutter_application_1/pages/employee/home_page.dart';
import 'package:flutter_application_1/pages/auth/auth_storage.dart'; // Import auth_storage.dart

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  static const String _baseUrl = 'https://locatrack.zalfyan.my.id/api';
  
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }
  
  Future<void> _checkAutoLogin() async {
    final bool isLoggedIn = await AuthStorage().isLoggedIn();
    if (isLoggedIn && mounted) {
      final data = await AuthStorage().getLoginData();
      final String? role = data['user']?['role'];
      
      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else if (role == 'employee') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EmployeeHomePage()),
        );
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String role =
            responseData['user']['role']; // Keep role for navigation logic

        // Save login data using AuthStorage
        await AuthStorage().saveLoginData(responseData);

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        } else if (role == 'employee') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const EmployeeHomePage()),
          );
        } else {
          setState(() {
            _errorMessage = 'Role pengguna tidak dikenali.';
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'Login gagal. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e. Periksa koneksi internet Anda.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Image.asset(
                  "assets/images/icon-apk.png",
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 20),
              // Judul (Lorem Ipsum)
              const Text(
                "Lorem Ipsum Dolor Sit Amet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subjudul (Lorem Ipsum)
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae ligula id neque.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // TextField Gabung
              Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'email',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal, // <-- anti-bold
                      ),
                      border: _thinBorder(top: true),
                      enabledBorder: _thinBorder(top: true),
                      focusedBorder: _thinBorder(top: true),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Kata sandi',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal, // <-- anti-bold
                      ),
                      border: _thinBorder(bottom: true),
                      enabledBorder: _thinBorder(bottom: true),
                      focusedBorder: _thinBorder(bottom: true),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // Tombol Login
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Masuk Sistem',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16.0),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // TODO: arahkan ke WhatsApp
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: 'Lupa Kata Sandi? '),
                      TextSpan(
                        text: 'Bantuan Masuk',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputBorder _thinBorder({bool top = false, bool bottom = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: top ? const Radius.circular(6) : Radius.zero,
        topRight: top ? const Radius.circular(6) : Radius.zero,
        bottomLeft: bottom ? const Radius.circular(6) : Radius.zero,
        bottomRight: bottom ? const Radius.circular(6) : Radius.zero,
      ),
      borderSide: const BorderSide(width: 0.5, color: Colors.grey),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
