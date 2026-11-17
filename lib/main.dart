// ============================================================
// FILE: main.dart
// FUNGSI: Entry point aplikasi Flutter.
//
//         Alur:
//         1. main() memanggil runApp() dengan MyApp
//         2. MyApp melakukan cek SharedPreferences:
//            → Jika ada user yang login → langsung ke HomePage
//            → Jika tidak ada → ke LoginPage
//         Ini memenuhi ketentuan: "Login tersimpan di SharedPreferences
//         sehingga jika dikeluarkan tanpa logout, user masih dapat masuk
//         ke aplikasi kembali"
// ============================================================

import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  // Pastikan Flutter widget binding sudah diinisialisasi sebelum
  // memanggil operasi async (SharedPreferences) di main()
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceflight News',
      // Sembunyikan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,
      // Tema global aplikasi — warna utama indigo/ungu sesuai desain soal
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0), // indigo/ungu
        ),
        useMaterial3: true, // gunakan Material 3 (modern)
      ),
      // home menggunakan FutureBuilder untuk menentukan halaman awal
      // berdasarkan status login yang tersimpan di SharedPreferences
      home: FutureBuilder<String?>(
        // getLoggedInUser() membaca SharedPreferences:
        // → null  = belum login → tampilkan LoginPage
        // → String = username yang login → tampilkan HomePage
        future: AuthService.getLoggedInUser(),
        builder: (context, snapshot) {
          // snapshot.connectionState: status Future (waiting/done/error)
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Saat membaca SharedPreferences, tampilkan splash/loading screen
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Future selesai — cek hasilnya
          final String? loggedInUser = snapshot.data;

          if (loggedInUser != null && loggedInUser.isNotEmpty) {
            // Ada user yang sedang login (data persist dari sesi sebelumnya)
            // → Langsung masuk ke HomePage tanpa perlu login ulang
            return HomePage(username: loggedInUser);
          } else {
            // Tidak ada user login (pertama kali buka atau sudah logout)
            // → Tampilkan LoginPage
            return const LoginPage();
          }
        },
      ),
    );
  }
}
