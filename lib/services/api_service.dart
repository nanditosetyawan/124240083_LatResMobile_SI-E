// ============================================================
// FILE: services/api_service.dart
// FUNGSI: Menangani semua pemanggilan ke Spaceflight News API v4.
//         Endpoint:
//           - https://api.spaceflightnewsapi.net/v4/articles/   (News)
//           - https://api.spaceflightnewsapi.net/v4/blogs/       (Blog)
//           - https://api.spaceflightnewsapi.net/v4/reports/     (Report)
//           - https://api.spaceflightnewsapi.net/v4/{type}/{id}/ (Detail)
// ============================================================

import 'dart:convert';          // untuk jsonDecode
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  // baseUrl adalah root URL API — semua endpoint berawal dari sini
  static const String _baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // _typeToEndpoint: memetakan nama menu yang kita gunakan secara internal
  // ke nama endpoint API yang sesungguhnya.
  // "news" → "articles" karena API v4 memakai endpoint /articles/ untuk news
  static const Map<String, String> _typeToEndpoint = {
    'news': 'articles',   // /v4/articles/
    'blogs': 'blogs',     // /v4/blogs/
    'reports': 'reports', // /v4/reports/
  };

  /// Mengambil list data dari API berdasarkan tipe (news/blogs/reports).
  /// Mengembalikan List of ArticleModel.
  /// Melempar Exception jika request gagal.
  static Future<List<ArticleModel>> fetchList(String type) async {
    // Ambil nama endpoint yang sesuai, default ke type itu sendiri jika tidak ada di map
    final String endpoint = _typeToEndpoint[type] ?? type;

    // Buat URI dengan parameter limit=20 agar tidak terlalu banyak data
    final Uri uri = Uri.parse('$_baseUrl/$endpoint/?limit=20');

    // Lakukan GET request ke API
    final http.Response response = await http.get(uri);

    // Cek status code HTTP:
    // 200 = OK, selain itu lempar exception agar bisa ditampilkan di UI
    if (response.statusCode == 200) {
      // Decode JSON: response body berupa String JSON
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      // API v4 membungkus list di dalam key "results"
      final List<dynamic> results = jsonData['results'] as List<dynamic>;

      // Konversi setiap item JSON menjadi ArticleModel
      // Kirim 'type' asli (news/blogs/reports) agar model tahu jenisnya
      return results
          .map((item) => ArticleModel.fromJson(
                item as Map<String, dynamic>,
                type: type,
              ))
          .toList();
    } else {
      // Jika status bukan 200, lempar Exception dengan kode status
      throw Exception('Gagal memuat data: HTTP ${response.statusCode}');
    }
  }

  /// Mengambil detail satu artikel berdasarkan id dan tipe.
  /// Contoh URL: https://api.spaceflightnewsapi.net/v4/articles/12345/
  static Future<ArticleModel> fetchDetail(String type, int id) async {
    final String endpoint = _typeToEndpoint[type] ?? type;

    // URL detail: baseUrl/endpoint/id/
    final Uri uri = Uri.parse('$_baseUrl/$endpoint/$id/');

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      // Detail tidak dibungkus dalam "results", langsung berupa Map
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return ArticleModel.fromJson(jsonData, type: type);
    } else {
      throw Exception('Gagal memuat detail: HTTP ${response.statusCode}');
    }
  }
}
