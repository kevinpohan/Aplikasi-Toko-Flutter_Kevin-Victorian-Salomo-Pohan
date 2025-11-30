import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk.dart';
import '../services/api_service.dart';
import 'produk_form_page.dart';

class ProdukListPage extends StatefulWidget {
  const ProdukListPage({super.key});
  @override
  State<ProdukListPage> createState() => _ProdukListPageState();
}

class _ProdukListPageState extends State<ProdukListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Produk>> _futureProduk;

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  void _loadProduk() {
    setState(() {
      _futureProduk = _apiService.getProduk().catchError((error) {
        // Tangkap error 401 dan paksa logout
        if (error is ExpiredTokenException) {
          if (mounted) {
            // Tampilkan pesan error
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.message)));
            // Paksa Logout dan navigasi ke Login
            _doLogout();
          }
          return <
            Produk
          >[]; // Kembalikan list kosong agar FutureBuilder tidak error
        }
        throw error; // Lempar error lain
      });
    });
  }

  Future<void> _doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token sesi [cite: 577]
    if (!mounted) return;
    // Navigasi kembali ke halaman login dan hapus stack rute
    Navigator.pushReplacementNamed(context, '/login'); // [cite: 578]
  }

  // Fungsi Navigasi (Create & Edit)
  Future<void> _navigateToForm({Produk? produk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdukFormPage(produk: produk)),
    );
    if (result == true) _loadProduk(); // Refresh jika ada perubahan
  }

  // Fungsi Hapus
  Future<void> _delete(Produk produk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus?'),
        content: Text('Yakin hapus ${produk.namaProduk}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.deleteProduk(produk.id.toString());
      _loadProduk();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _doLogout, // Panggil fungsi logout
          ), // [cite: 576]
        ],
      ),
      body: FutureBuilder<List<Produk>>(
        future: _futureProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final produk = snapshot.data![index];
              return ListTile(
                title: Text(produk.namaProduk),
                subtitle: Text('Rp ${produk.harga}'),
                onTap: () => _navigateToForm(produk: produk), // Tap untuk Edit
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _delete(produk), // Klik tong sampah untuk Hapus
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Tanpa parameter = Mode Tambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
