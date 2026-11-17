// ============================================================
// FILE: pages/list_page.dart
// FUNGSI: Halaman daftar artikel (News / Blog / Reports).
//
//         Ketentuan soal:
//         ✅ Menampilkan judul dari tiap data
//         ✅ Menampilkan gambar sebagai leading (thumbnail)
//         ✅ Exception handling jika gambar tidak muncul
//         ✅ Menampilkan author (newsSite) dari data
//         ✅ Fitur Filter berupa Chip berdasarkan author
//         ✅ Tombol Favorite (ikon hati) di AppBar
// ============================================================

import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class ListPage extends StatefulWidget {
  // type menentukan jenis data yang dimuat: "news", "blogs", atau "reports"
  // Dikirim dari HomePage saat user menekan salah satu menu
  final String type;

  const ListPage({super.key, required this.type});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // _articles: menyimpan semua data yang sudah diambil dari API
  List<ArticleModel> _articles = [];

  // _filteredArticles: data yang ditampilkan setelah filter chip aktif
  // Jika tidak ada filter, isinya sama dengan _articles
  List<ArticleModel> _filteredArticles = [];

  // _authors: daftar unik nama author (newsSite) dari semua artikel
  // Digunakan untuk membuat chip filter secara dinamis
  List<String> _authors = [];

  // _selectedAuthor: author yang sedang dipilih untuk filter
  // null = tidak ada filter (tampilkan semua)
  String? _selectedAuthor;

  // _isLoading: status loading saat fetch API
  bool _isLoading = true;

  // _errorMessage: pesan error jika fetch gagal
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman pertama kali dibuka
    _fetchData();
  }

  /// Mengambil data dari API berdasarkan widget.type (news/blogs/reports).
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil ApiService dengan type dari widget
      final List<ArticleModel> data = await ApiService.fetchList(widget.type);

      // Ekstrak daftar author yang unik untuk membuat chip filter
      // toSet() menghilangkan duplikat, toList() mengubah kembali ke List
      final List<String> uniqueAuthors =
          data.map((article) => article.newsSite).toSet().toList();

      setState(() {
        _articles = data;
        _filteredArticles = data; // awalnya tampilkan semua
        _authors = uniqueAuthors;
        _isLoading = false;
      });
    } catch (e) {
      // Tangani error (network error, timeout, dll.)
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  /// Mengaplikasikan filter berdasarkan author yang dipilih.
  /// Jika author sama dengan yang sudah dipilih → reset filter (toggle).
  void _applyFilter(String author) {
    setState(() {
      if (_selectedAuthor == author) {
        // Chip yang sama diklik lagi → hapus filter
        _selectedAuthor = null;
        _filteredArticles = _articles; // tampilkan semua
      } else {
        // Pilih filter baru → tampilkan hanya artikel dengan author ini
        _selectedAuthor = author;
        _filteredArticles =
            _articles.where((a) => a.newsSite == author).toList();
      }
    });
  }

  /// Menentukan judul AppBar berdasarkan tipe yang dipilih.
  String get _pageTitle {
    switch (widget.type) {
      case 'news':
        return 'News';
      case 'blogs':
        return 'Blog';
      case 'reports':
        return 'Reports';
      default:
        return widget.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        // Tombol Favorite di kanan AppBar sesuai gambar soal (ikon hati)
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Membangun body sesuai state: loading, error, atau data berhasil.
  Widget _buildBody() {
    if (_isLoading) {
      // Tampilkan spinner saat data sedang dimuat
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      // Tampilkan pesan error beserta tombol retry
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Tampilkan data: chip filter + list artikel
    return Column(
      children: [
        // ---- Baris Chip Filter ----
        // Chip dibuat secara dinamis dari daftar author yang unik
        // Sesuai ketentuan soal gambar 5: filter berdasarkan author
        if (_authors.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // scroll horizontal
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _authors.length,
              itemBuilder: (context, index) {
                final String author = _authors[index];
                final bool isSelected = _selectedAuthor == author;

                // FilterChip: chip yang bisa dipilih dan di-unselect
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      author,
                      style: TextStyle(
                        fontSize: 12,
                        // Teks putih jika terpilih, gelap jika tidak
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    // Chip terpilih berwarna biru/ungu, tidak terpilih transparan
                    selected: isSelected,
                    selectedColor: const Color(0xFF5C6BC0),
                    backgroundColor: Colors.grey.shade200,
                    checkmarkColor: Colors.white, // ✓ berwarna putih
                    onSelected: (_) => _applyFilter(author),
                  ),
                );
              },
            ),
          ),

        // ---- Daftar Artikel ----
        Expanded(
          child: _filteredArticles.isEmpty
              ? const Center(
                  // Pesan jika tidak ada artikel yang cocok dengan filter
                  child: Text('Tidak ada data untuk filter ini.'),
                )
              : ListView.builder(
                  itemCount: _filteredArticles.length,
                  itemBuilder: (context, index) {
                    final ArticleModel article = _filteredArticles[index];
                    return _buildArticleTile(article);
                  },
                ),
        ),
      ],
    );
  }

  /// Widget untuk setiap item artikel di list.
  Widget _buildArticleTile(ArticleModel article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),

        // Leading: gambar thumbnail sesuai ketentuan soal gambar 3
        // Wajib ada exception handling jika gambar tidak muncul
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: article.imageUrl.isNotEmpty
              ? Image.network(
                  article.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  // errorBuilder: exception handling saat gambar gagal dimuat
                  // Ketentuan soal: "memberikan exception handling apabila gambarnya tidak muncul"
                  errorBuilder: (context, error, stackTrace) {
                    // Tampilkan ikon sebagai fallback jika gambar gagal load
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                  // loadingBuilder: tampilkan spinner kecil saat gambar masih loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child; // sudah selesai
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  // Jika imageUrl kosong → tampilkan placeholder langsung
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),

        // Judul artikel — sesuai ketentuan soal: "Wajib menampilkan judul dari data"
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // potong jika terlalu panjang
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        // Author (newsSite) — sesuai ketentuan: "Wajib memunculkan author dari data"
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            article.newsSite,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),

        // Saat item diklik → navigasi ke DetailPage
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(article: article),
            ),
          );
        },
      ),
    );
  }
}

