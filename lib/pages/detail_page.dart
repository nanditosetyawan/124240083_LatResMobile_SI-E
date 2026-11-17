// ============================================================
// FILE: pages/detail_page.dart
// FUNGSI: Halaman detail satu artikel (News / Blog / Report).
//
//         Ketentuan soal gambar 6 & 7:
//         ✅ Wajib menampilkan gambar
//         ✅ Wajib menampilkan judul data
//         ✅ Wajib menampilkan author data (newsSite)
//         ✅ Wajib menampilkan tanggal publish
//         ✅ Wajib menampilkan summary data
//         ✅ Tombol untuk launch URL ke situs resmi
//         ✅ Tombol untuk menambah/hapus dari Favorite (ikon hati)
//         ✅ Penambahan favorite dilakukan dari halaman ini
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // untuk buka link di browser
import '../models/article_model.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  // article: data artikel yang diterima dari ListPage
  // Sudah berisi semua informasi (title, imageUrl, summary, dll.)
  final ArticleModel article;

  const DetailPage({super.key, required this.article});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // _isFavorite: status apakah artikel ini sudah difavoritkan
  // Digunakan untuk toggle ikon hati (merah = favorite, putih = belum)
  bool _isFavorite = false;

  // _isCheckingFav: status loading saat mengecek/mengubah favorite
  bool _isCheckingFav = true;

  @override
  void initState() {
    super.initState();
    // Cek apakah artikel ini sudah ada di favorites saat halaman dibuka
    _checkFavoriteStatus();
  }

  /// Mengecek status favorite artikel ini dari SharedPreferences.
  Future<void> _checkFavoriteStatus() async {
    final bool isFav = await FavoriteService.isFavorite(widget.article.id);
    setState(() {
      _isFavorite = isFav;
      _isCheckingFav = false;
    });
  }

  /// Toggle favorite: tambah jika belum, hapus jika sudah.
  /// Ketentuan: "penambahan data sebagai favourite dari halaman detail"
  Future<void> _toggleFavorite() async {
    setState(() => _isCheckingFav = true); // loading sementara

    // Panggil FavoriteService untuk toggle
    final bool nowFavorite =
        await FavoriteService.toggleFavorite(widget.article);

    setState(() {
      _isFavorite = nowFavorite;
      _isCheckingFav = false;
    });

    // Tampilkan SnackBar informasi kepada user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFavorite
              ? '${widget.article.title} ditambahkan ke favorit!'
              : '${widget.article.title} dihapus dari favorit.',
        ),
        backgroundColor: nowFavorite ? const Color(0xFF5C6BC0) : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Membuka URL artikel di browser menggunakan url_launcher.
  /// Ketentuan: "Terdapat tombol yang akan mengarahkan (launch url) ke situs resmi"
  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.article.url);
    // canLaunchUrl: cek apakah URL bisa dibuka
    if (await canLaunchUrl(uri)) {
      // launchUrl membuka di browser eksternal
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Jika tidak bisa dibuka, tampilkan pesan error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Format tanggal dari ISO 8601 menjadi lebih mudah dibaca.
  /// Contoh: "2026-11-08T13:45:00Z" → "2026-11-08 13:45"
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'Tanggal tidak tersedia';
    try {
      final DateTime dt = DateTime.parse(isoDate);
      // Format manual: YYYY-MM-DD HH:mm
      return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
    } catch (_) {
      // Jika parsing gagal, tampilkan string asli
      return isoDate;
    }
  }

  /// Helper: tambah leading zero (1 → "01", 12 → "12")
  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final ArticleModel article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        // Tombol Favorite di AppBar kanan (ikon hati)
        // Sesuai gambar 6: ikon hati bisa merah (favorite) atau outline (belum)
        actions: [
          _isCheckingFav
              // Tampilkan loading spinner kecil saat cek/ubah status favorite
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    // Ikon hati merah jika sudah favorite, outline jika belum
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView agar bisa scroll jika konten panjang
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Gambar Utama ----
            // Wajib menampilkan gambar (ketentuan soal gambar 6)
            article.imageUrl.isNotEmpty
                ? Image.network(
                    article.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    // errorBuilder: exception handling jika gambar gagal load
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),

            // ---- Konten Artikel ----
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Judul Artikel ----
                  // Ketentuan: "Wajib menampilkan judul data"
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---- Author (newsSite) ----
                  // Ketentuan: "Wajib menampilkan author data"
                  Row(
                    children: [
                      const Icon(Icons.source, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.newsSite,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ---- Tanggal Publish ----
                  // Ketentuan: "Wajib menampilkan tanggal publish"
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(article.publishedAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Garis pemisah antara metadata dan summary
                  const Divider(),
                  const SizedBox(height: 8),

                  // ---- Summary ----
                  // Ketentuan: "Wajib menampilkan summary data"
                  Text(
                    article.summary.isNotEmpty
                        ? article.summary
                        : 'Tidak ada ringkasan tersedia.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6, // line height untuk keterbacaan
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Tombol Buka Situs Resmi ----
                  // Ketentuan: "Terdapat tombol yang akan mengarahkan (launch url) ke situs resmi"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: article.url.isNotEmpty ? _launchUrl : null,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Buka Situs Resmi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- Tombol Tambah/Hapus Favorite ----
                  // Ketentuan: "Terdapat tombol untuk menambahkan data sebagai favourite"
                  // Tombol ini sebagai alternatif dari ikon di AppBar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isCheckingFav ? null : _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : const Color(0xFF5C6BC0),
                      ),
                      label: Text(
                        _isFavorite
                            ? 'Hapus dari Favorit'
                            : 'Tambahkan ke Favorit',
                        style: TextStyle(
                          color: _isFavorite
                              ? Colors.red
                              : const Color(0xFF5C6BC0),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _isFavorite
                              ? Colors.red
                              : const Color(0xFF5C6BC0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

