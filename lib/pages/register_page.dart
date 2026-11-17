// ============================================================
// FILE: pages/register_page.dart
// FUNGSI: Halaman pendaftaran akun baru.
//
//         Ketentuan soal:
//         ✅ Jika error → tampilkan SnackBar berwarna MERAH
//         ✅ Tidak boleh register username yang sudah ada
//         ✅ Setelah register berhasil, kembali ke LoginPage
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk input username dan password
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  // _isLoading: digunakan untuk menampilkan loading dan disable tombol
  bool _isLoading = false;

  /// Fungsi yang dipanggil saat tombol "Daftar" ditekan.
  Future<void> _doRegister() async {
    final String username = _usernameCtrl.text.trim();
    final String password = _passwordCtrl.text.trim();

    // Validasi: field tidak boleh kosong
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Username dan Password tidak boleh kosong.');
      return;
    }

    // Validasi: password minimal 6 karakter (keamanan dasar)
    if (password.length < 6) {
      _showErrorSnackBar('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    // Panggil AuthService untuk mendaftarkan akun
    final String? error = await AuthService.register(username, password);

    setState(() => _isLoading = false);

    if (error != null) {
      // Register gagal (misalnya username sudah ada) → SnackBar merah
      _showErrorSnackBar(error);
    } else {
      // Register berhasil → tampilkan SnackBar hijau lalu kembali ke LoginPage
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      // pop() agar kembali ke LoginPage
      // Tidak pakai pushReplacement agar stack navigasi tetap bersih
      Navigator.pop(context);
    }
  }

  /// Menampilkan SnackBar error berwarna merah.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // WAJIB merah sesuai ketentuan soal
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controller untuk mencegah memory leak
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan back button otomatis karena ini di-push di atas LoginPage
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF5C6BC0), // sama dengan LoginPage
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul halaman sesuai gambar soal
            const Text(
              'Daftar Akun Baru',
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Field Password — obscureText agar tersembunyi
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doRegister(),
            ),
            const SizedBox(height: 24),

            // Tombol Daftar
            ElevatedButton(
              onPressed: _isLoading ? null : _doRegister,
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
                  : const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}

