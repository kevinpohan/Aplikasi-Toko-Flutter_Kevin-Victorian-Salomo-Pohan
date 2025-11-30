import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});
  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController =
      TextEditingController(); // Controller baru

  final _apiService = ApiService();

  // Helper Function: Menampilkan dialog loading (Overlay)
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Penting: Mencegah user menutup dialog dengan tap di luar
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  // Helper Function: Menutup dialog loading
  void _hideLoadingDialog() {
    // Pastikan widget masih mounted sebelum melakukan navigasi
    if (mounted) Navigator.pop(context);
  }

  void _doRegistrasi() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Tampilkan Loading Overlay
    _showLoadingDialog();

    try {
      final response = await _apiService.registrasi(
        _namaController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      _hideLoadingDialog(); // Tutup loading setelah respons diterima

      // Tampilkan respons
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)), //
      );
      if (response.status) {
        Navigator.pop(context); // Kembali ke Login jika sukses
      }
    } catch (e) {
      if (!mounted) return;
      _hideLoadingDialog(); // Tutup loading jika terjadi error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Hapus pengecekan _isLoading dan langsung tampilkan Form
        child: Form(
          // Gunakan widget Form
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama harus diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email harus diisi' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Password harus diisi'
                    : null,
              ),
              TextFormField(
                // Field Konfirmasi Password
                controller: _konfirmasiPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password harus diisi';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak sama'; // Logika Validasi
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _doRegistrasi,
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
