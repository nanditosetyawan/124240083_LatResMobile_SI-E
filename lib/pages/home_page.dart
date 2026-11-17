// ============================================================
// FILE: pages/home_page.dart
// FUNGSI: Halaman Utama (menu) aplikasi.
//
//         Ketentuan soal:
//         ✅ Terdiri dari 3 menu: News, Blog, Reports
//         ✅ Setiap menu mengarah ke ListPage dengan tipe berbeda
//         ✅ AppBar menampilkan username yang sedang login ("Hai, {username}!")
//         ✅ Terdapat tombol Logout di bawah
//         ✅ Logout membersihkan sesi dan kembali ke LoginPage
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'list_page.dart';
import 'favorite_page.dart';

class HomePage extends StatelessWidget {
  // username diterima dari LoginPage setelah login berhasil
  // Digunakan untuk ditampilkan di AppBar: "Hai, {username}!"
  final String username;

  const HomePage({super.key, required this.username});

  /// Fungsi logout: hapus sesi login lalu kembali ke LoginPage.
  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();

    // Gunakan pushAndRemoveUntil agar seluruh stack navigasi dihapus
    // Ini memastikan user tidak bisa kembali ke HomePage dengan tombol back
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // hapus semua route di stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tampilkan "Hai, {username}!" sesuai ketentuan soal gambar 2
        title: Text('Hai, $username!'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        centerTitle: true,
        // Tombol Favorite di AppBar kanan
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              // Navigasi ke halaman Favorite
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Daftar menu: News, Blog, Reports
            // Setiap menu adalah Card yang bisa diklik
            Expanded(
              child: ListView(
                children: [
                  // ---- Menu News ----
                  _buildMenuCard(
                    context,
                    icon: Icons.newspaper,          // ikon berita
                    title: 'News',
                    subtitle:
                        'Get an overview of the latest SpaceFlight news, from various sources! '
                        'Easily link your users to the right websites.',
                    type: 'news', // "news" → endpoint /articles/
                  ),
                  const SizedBox(height: 12),

                  // ---- Menu Blog ----
                  _buildMenuCard(
                    context,
                    icon: Icons.article,            // ikon artikel/blog
                    title: 'Blog',
                    subtitle:
                        'Blogs often provide a more detailed overview of launches and missions. '
                        'A must-have for the serious spaceflight enthusiast.',
                    type: 'blogs', // "blogs" → endpoint /blogs/
                  ),
                  const SizedBox(height: 12),

                  // ---- Menu Reports ----
                  _buildMenuCard(
                    context,
                    icon: Icons.bar_chart,          // ikon laporan/chart
                    title: 'Reports',
                    subtitle:
                        'Space stations and other missions often publish their data. '
                        'With SNAPI, you can include it in your app.',
                    type: 'reports', // "reports" → endpoint /reports/
                  ),
                ],
              ),
            ),

            // Tombol Logout di bawah sesuai ketentuan soal gambar 2
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, // tombol selebar layar
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,     // merah untuk logout
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk membangun setiap kartu menu.
  /// [type] dikirim ke ListPage agar tahu endpoint mana yang dipanggil.
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String type, // "news", "blogs", atau "reports"
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // Leading: ikon yang dibungkus dalam kotak berwarna
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF5C6BC0), size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        // Saat diklik → navigasi ke ListPage dengan tipe yang sesuai
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListPage(type: type),
            ),
          );
        },
      ),
    );
  }
}

