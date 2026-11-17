// ============================================================
// FILE: models/article_model.dart
// FUNGSI: Model data untuk News, Blog, dan Report dari API
//         Spaceflight News API v4.
//         Semua tipe (news/blog/report) memiliki struktur JSON
//         yang SAMA, sehingga 1 model ini digunakan untuk ketiganya.
// ============================================================

class ArticleModel {
  // id digunakan untuk memanggil endpoint detail:
  // https://api.spaceflightnewsapi.net/v4/{menu}/{id}/
  final int id;

  // title: judul berita/blog/report — wajib ditampilkan di halaman list & detail
  final String title;

  // url: link ke situs sumber berita — digunakan oleh url_launcher di halaman detail
  final String url;

  // imageUrl: URL gambar thumbnail — ditampilkan sebagai leading di list & gambar besar di detail
  final String imageUrl;

  // newsSite: nama sumber/author berita (contoh: "NASA", "Spaceflight Now")
  //           digunakan untuk filter chip di halaman list
  final String newsSite;

  // summary: ringkasan isi berita — ditampilkan di halaman detail
  final String summary;

  // publishedAt: tanggal publish — ditampilkan di halaman detail
  final String publishedAt;

  // type: menyimpan tipe artikel ("news", "blogs", "reports")
  //       digunakan agar FavoritePage tahu dari endpoint mana item ini berasal
  final String type;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.type,
  });

  // Factory constructor: mengubah JSON Map menjadi objek ArticleModel
  // "type" tidak ada di JSON API sehingga dikirim sebagai parameter tambahan
  factory ArticleModel.fromJson(Map<String, dynamic> json, {required String type}) {
    return ArticleModel(
      id: json['id'] as int,                          // id integer dari API
      title: json['title'] as String? ?? '',           // judul, default string kosong jika null
      url: json['url'] as String? ?? '',               // URL sumber
      imageUrl: json['image_url'] as String? ?? '',    // URL gambar (key: image_url di JSON)
      newsSite: json['news_site'] as String? ?? '',    // nama situs/author (key: news_site)
      summary: json['summary'] as String? ?? '',       // ringkasan
      publishedAt: json['published_at'] as String? ?? '', // tanggal (key: published_at)
      type: type,                                      // dikirim dari luar, bukan dari JSON
    );
  }

  // toMap: mengubah objek menjadi Map untuk disimpan di SharedPreferences sebagai favorites
  // SharedPreferences hanya bisa menyimpan String, jadi kita simpan sebagai JSON string
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'imageUrl': imageUrl,
      'newsSite': newsSite,
      'summary': summary,
      'publishedAt': publishedAt,
      'type': type,
    };
  }

  // Factory constructor untuk membaca kembali dari Map (saat load dari SharedPreferences)
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      url: map['url'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      newsSite: map['newsSite'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      publishedAt: map['publishedAt'] as String? ?? '',
      type: map['type'] as String? ?? '',
    );
  }
}

