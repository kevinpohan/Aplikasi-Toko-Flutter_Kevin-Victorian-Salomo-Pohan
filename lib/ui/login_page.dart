import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  void _showLoadingDialog() {
    // Menampilkan dialog loading (overlay)
    showDialog(
      context: context,
      barrierDismissible:
          false, // Memastikan pengguna tidak bisa menutup dialog dengan tap di luar
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog() {
    // Menutup dialog loading
    if (mounted) Navigator.pop(context);
  }

  Future<void> _doLogin() async {
    _showLoadingDialog(); // Menggantikan showDialog

    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.status) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token);
        if (!mounted) return;
        _hideLoadingDialog(); // Tutup dialog jika sukses
        Navigator.pushReplacementNamed(context, '/produk');
      } else {
        if (!mounted) return;
        _hideLoadingDialog(); // Tutup dialog jika gagal
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.token)));
      }
    } catch (e) {
      if (!mounted) return;
      _hideLoadingDialog(); // Tutup dialog jika error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    // Hapus blok finally, karena kita sudah mengaturnya di dalam try/else/catch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Toko')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Hapus ternary operator (_isLoading ? ... : Column)
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _doLogin, child: const Text('Masuk')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/registrasi'),
              child: const Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
