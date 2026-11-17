// ============================================================
// FILE: pages/favorite_page.dart
// FUNGSI: Halaman yang menampilkan semua artikel yang telah
//         difavoritkan oleh user (dari News, Blog, maupun Reports).
//
//         Ketentuan soal gambar 4:
//         ✅ Semua data favourite (news/blog/report) tercantum di sini
//         ✅ Penambahan favourite dilakukan dari halaman detail
//         ✅ List favourite terupdate terlepas dari mana perubahan dilakukan
//            (baik dari halaman list maupun halaman detail)
//         ✅ Menampilkan gambar dan judul sebagai leading
//         ✅ Ikon hati untuk unfavorite langsung dari halaman ini
// ============================================================

import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // _favorites: list semua artikel yang sudah difavoritkan
  List<ArticleModel> _favorites = [];

  // _isLoading: status loading saat membaca dari SharedPreferences
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Muat data favorites saat halaman pertama kali dibuka
    _loadFavorites();
  }

  /// Memuat data favorites dari SharedPreferences via FavoriteService.
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final List<ArticleModel> favs = await FavoriteService.getFavorites();

    setState(() {
      _favorites = favs;
      _isLoading = false;
    });
  }

  /// Menghapus artikel dari favorites langsung dari halaman ini.
  /// Ketentuan: "List data favourite terupdate terlepas dilakukannya perubahan
  /// di halaman favourite maupun dari halaman detil"
  Future<void> _removeFavorite(ArticleModel article) async {
    await FavoriteService.removeFavorite(article.id);

    // Reload list setelah penghapusan
    _loadFavorites();

    // Beri feedback ke user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${article.title} dihapus dari favorit.'),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          // Tampilkan spinner saat loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              // Pesan jika belum ada favorite
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada favorit.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tambahkan artikel dari halaman detail.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              // Tampilkan list favorites
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final ArticleModel article = _favorites[index];
                    return _buildFavoriteTile(article);
                  },
                ),
    );
  }

  /// Widget untuk setiap item di halaman favorite.
  Widget _buildFavoriteTile(ArticleModel article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),

        // Gambar thumbnail sebagai leading
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: article.imageUrl.isNotEmpty
              ? Image.network(
                  article.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  // errorBuilder: exception handling saat gambar tidak bisa dimuat
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),

        // Judul artikel
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),

        // Nama sumber/author
        subtitle: Text(
          article.newsSite,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),

        // Trailing: ikon hati merah — klik untuk unfavorite
        // Ketentuan: tombol di halaman favorite untuk menghapus
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          tooltip: 'Hapus dari Favorit',
          onPressed: () => _removeFavorite(article),
        ),

        // Klik item → navigasi ke DetailPage
        // Setelah kembali dari DetailPage, reload favorites
        // agar perubahan dari halaman detail juga terupdate di sini
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(article: article),
            ),
          );
          // Setelah kembali dari DetailPage, reload favorites
          // Ini memenuhi ketentuan: "List data favourite terupdate terlepas
          // dilakukannya perubahan di halaman favourite maupun dari halaman detil"
          _loadFavorites();
        },
      ),
    );
  }
}

