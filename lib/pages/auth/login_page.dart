// lib/pages/auth/login_page.dart
// Halaman ini berfungsi sebagai halaman login aplikasi.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/admin/home_page.dart';
import 'package:flutter_application_1/pages/employee/home_page.dart';

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

  // Base URL untuk API. Ubah ini jika ada perubahan endpoint API.
  static const String _baseUrl = 'https://locatrack.zalfyan.my.id/api';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Validasi input sederhana
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Melakukan panggilan API untuk login
      // Komentar: Ubah endpoint '/login' jika ada perubahan di API.
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
        // Login berhasil
        final responseData = jsonDecode(response.body);
        final String token = responseData['token'];
        final String role = responseData['user']
            ['role']; // Asumsi 'user' object memiliki field 'role'

        // Menyimpan token menggunakan shared_preferences
        // Komentar: Jika ingin mengubah cara penyimpanan token (misal: ke secure storage), ubah bagian ini.
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_role', role); // Menyimpan role pengguna

        // Navigasi berdasarkan role
        // Komentar: Tambahkan kondisi untuk role baru di sini jika diperlukan.
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
        // Login gagal
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'Login gagal. Silakan coba lagi.';
        });
      }
    } catch (e) {
      // Error handling untuk masalah koneksi atau parsing
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
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Login'),
                  ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16.0),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
