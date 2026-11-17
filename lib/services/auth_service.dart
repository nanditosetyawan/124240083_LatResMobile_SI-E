// ============================================================
// FILE: services/auth_service.dart
// FUNGSI: Menangani logika Login dan Register menggunakan
//         SharedPreferences sebagai "database" lokal.
//
//         Mengapa SharedPreferences?
//         → Soal mewajibkan login tersimpan (persist) sehingga
//           saat app dibuka ulang tanpa logout, user langsung masuk.
//         → Data user (username, password) disimpan dengan key
//           "user_{username}" agar bisa multi-akun.
//         → Status login aktif disimpan di key "logged_in_user".
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // KEY untuk menyimpan username yang sedang login
  // Jika key ini ada dan tidak kosong, berarti ada user yang sedang login
  static const String _keyLoggedInUser = 'logged_in_user';

  // Prefix untuk menyimpan password tiap user
  // Format key: "user_{username}" → value: password
  static const String _prefixUser = 'user_';

  /// Mendaftarkan akun baru.
  ///
  /// Mengembalikan null jika berhasil.
  /// Mengembalikan String pesan error jika gagal.
  static Future<String?> register(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cek apakah username sudah terdaftar (key sudah ada di SharedPreferences)
    // Ketentuan soal: "Login menggunakan akun yang telah diregister terlebih dahulu"
    // → berarti tidak boleh register ulang username yang sama
    final String? existingPassword = prefs.getString('$_prefixUser$username');
    if (existingPassword != null) {
      // Username sudah ada → kembalikan pesan error
      return 'Username sudah digunakan, coba yang lain.';
    }

    // Simpan password dengan key "user_{username}"
    // Contoh: key = "user_rahman", value = "12345"
    await prefs.setString('$_prefixUser$username', password);

    // Register berhasil → kembalikan null (tidak ada error)
    return null;
  }

  /// Melakukan login.
  ///
  /// Mengembalikan null jika berhasil (login OK).
  /// Mengembalikan String pesan error jika gagal.
  static Future<String?> login(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil password yang tersimpan untuk username ini
    final String? savedPassword = prefs.getString('$_prefixUser$username');

    if (savedPassword == null) {
      // Username tidak ditemukan di SharedPreferences
      return 'Username tidak ditemukan. Silakan Register dahulu.';
    }

    if (savedPassword != password) {
      // Password tidak cocok
      // Ketentuan: "Login Gagal! Pastikan sudah Register atau cek password"
      return 'Password salah. Pastikan sudah Register atau cek password.';
    }

    // Login berhasil: simpan username yang sedang login
    // Ini yang membuat login "persist" — data tetap ada meski app ditutup
    await prefs.setString(_keyLoggedInUser, username);

    return null; // null = sukses
  }

  /// Logout: hapus informasi user yang sedang login dari SharedPreferences.
  /// Setelah logout, getLoggedInUser() akan mengembalikan null.
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Hanya hapus key status login, bukan data akun user
    // Sehingga user bisa login kembali di lain waktu
    await prefs.remove(_keyLoggedInUser);
  }

  /// Mendapatkan username yang sedang login.
  /// Mengembalikan null jika tidak ada yang login.
  /// Digunakan oleh main.dart untuk menentukan halaman awal (LoginPage vs HomePage).
  static Future<String?> getLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedInUser);
    // Jika key tidak ada → returns null → app arahkan ke LoginPage
    // Jika key ada → returns username → app arahkan ke HomePage langsung
  }
}

