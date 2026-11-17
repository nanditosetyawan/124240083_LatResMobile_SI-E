// ============================================================
// FILE: services/favorite_service.dart
// FUNGSI: Menangani penyimpanan dan pembacaan data Favorite
//         menggunakan SharedPreferences.
//
//         Mengapa SharedPreferences?
//         → Favorite harus persist (tetap ada meski app ditutup).
//         → Data disimpan sebagai JSON string List di key "favorites".
//
//         Ketentuan soal:
//         - Penambahan favorite dilakukan dari halaman detail.
//         - List favorite terupdate terlepas dari mana perubahan dilakukan
//           (baik dari halaman list maupun dari halaman detail).
// ============================================================

import 'dart:convert'; // untuk jsonEncode dan jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';

class FavoriteService {
  // Key penyimpanan favorites di SharedPreferences
  // Value-nya berupa JSON string dari List<Map>
  static const String _keyFavorites = 'favorites';

  /// Mengambil semua data favorite dari SharedPreferences.
  /// Mengembalikan List of ArticleModel.
  static Future<List<ArticleModel>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil string JSON yang tersimpan; null jika belum pernah ada favorite
    final String? favJson = prefs.getString(_keyFavorites);

    if (favJson == null) {
      // Belum ada favorite → kembalikan list kosong
      return [];
    }

    // Decode JSON string → List<dynamic>
    final List<dynamic> favList = jsonDecode(favJson) as List<dynamic>;

    // Konversi tiap item (Map) ke ArticleModel
    return favList
        .map((item) => ArticleModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Cek apakah sebuah artikel sudah ada di favorites.
  /// Digunakan untuk menentukan tampilan ikon hati (merah/putih) di detail page.
  static Future<bool> isFavorite(int articleId) async {
    final List<ArticleModel> favorites = await getFavorites();
    // Cari apakah ada item dengan id yang sama
    return favorites.any((item) => item.id == articleId);
  }

  /// Menambah artikel ke favorites.
  /// Jika sudah ada (berdasarkan id), tidak ditambahkan lagi (avoid duplicate).
  static Future<void> addFavorite(ArticleModel article) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ArticleModel> favorites = await getFavorites();

    // Cek apakah sudah ada agar tidak duplikat
    final bool alreadyExists = favorites.any((item) => item.id == article.id);
    if (alreadyExists) return; // sudah ada, abaikan

    // Tambahkan artikel baru
    favorites.add(article);

    // Konversi list ke JSON string untuk disimpan di SharedPreferences
    // SharedPreferences tidak bisa simpan List<Object>, harus diubah ke String dulu
    final String encoded = jsonEncode(
      favorites.map((item) => item.toMap()).toList(),
    );

    await prefs.setString(_keyFavorites, encoded);
  }

  /// Menghapus artikel dari favorites berdasarkan id.
  static Future<void> removeFavorite(int articleId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ArticleModel> favorites = await getFavorites();

    // Hapus item yang id-nya cocok
    favorites.removeWhere((item) => item.id == articleId);

    // Simpan kembali list yang sudah diperbarui
    final String encoded = jsonEncode(
      favorites.map((item) => item.toMap()).toList(),
    );

    await prefs.setString(_keyFavorites, encoded);
  }

  /// Toggle favorite: jika sudah ada → hapus, jika belum → tambah.
  /// Mengembalikan bool: true = sekarang jadi favorite, false = sudah dihapus.
  static Future<bool> toggleFavorite(ArticleModel article) async {
    final bool alreadyFav = await isFavorite(article.id);

    if (alreadyFav) {
      await removeFavorite(article.id);
      return false; // sekarang bukan favorite
    } else {
      await addFavorite(article);
      return true; // sekarang jadi favorite
    }
  }
}
