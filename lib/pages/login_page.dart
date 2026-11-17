// ============================================================
// FILE: pages/login_page.dart
// FUNGSI: Halaman login aplikasi.
//
//         Ketentuan soal:
//         ✅ Jika error → tampilkan SnackBar berwarna MERAH
//         ✅ Login menggunakan akun yang sudah di-register
//         ✅ Login tersimpan di SharedPreferences (persist)
//         ✅ Ada link ke halaman Register
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk TextField username & password
  // Harus TextEditingController agar bisa membaca input user
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // _isLoading: mengontrol tampilan loading indicator saat proses login berlangsung
  // Mencegah user menekan tombol berkali-kali
  bool _isLoading = false;

  /// Fungsi yang dipanggil saat tombol "Login" ditekan.
  Future<void> _doLogin() async {
    // Ambil input user dan hilangkan spasi di awal/akhir
    final String username = _usernameCtrl.text.trim();
    final String password = _passwordCtrl.text.trim();

    // Validasi sederhana: jangan proses jika field kosong
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Username dan Password tidak boleh kosong.');
      return;
    }

    // Aktifkan loading state → tombol Login menjadi disabled
    setState(() => _isLoading = true);

    // Panggil service untuk proses login
    final String? error = await AuthService.login(username, password);

    // Matikan loading state
    setState(() => _isLoading = false);

    if (error != null) {
      // Login gagal → tampilkan SnackBar merah sesuai ketentuan soal
      _showErrorSnackBar(error);
    } else {
      // Login berhasil → navigasi ke HomePage
      // pushReplacement agar user tidak bisa kembali ke LoginPage dengan back button
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Kirim username ke HomePage untuk ditampilkan di AppBar ("Hai, {username}!")
          builder: (_) => HomePage(username: username),
        ),
      );
    }
  }

  /// Menampilkan SnackBar dengan warna merah (error).
  /// Sesuai ketentuan soal: "Jika error memunculkan snackbar error berwarna merah".
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // WAJIB merah sesuai soal
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controller untuk mencegah memory leak
    // Wajib dilakukan untuk semua TextEditingController
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar berwarna biru/ungu seperti pada gambar contoh soal
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF5C6BC0), // indigo/ungu sesuai gambar
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul halaman
            const Text(
              'Silakan Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Field Username
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next, // pindah ke field password
            ),
            const SizedBox(height: 16),

            // Field Password — obscureText: true agar karakter tersembunyi
            TextField(
              controller: _passwordCtrl,
              obscureText: true, // tanda bintang/titik untuk password
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doLogin(), // enter = login langsung
            ),
            const SizedBox(height: 24),

            // Tombol Login — menampilkan loading jika proses sedang berjalan
            ElevatedButton(
              onPressed: _isLoading ? null : _doLogin,
              // null = disabled (tidak bisa ditekan saat loading)
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 16),

            // Link ke halaman Register
            // Sesuai gambar soal: "Belum punya akun? Daftar di sini"
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Belum punya akun? Daftar di sini'),
            ),
          ],
        ),
      ),
    );
  }
}

