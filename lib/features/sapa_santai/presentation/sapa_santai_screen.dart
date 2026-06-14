import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../data/question_model.dart';

class SapaSantaiScreen extends StatefulWidget {
  final List<String> selectedCategories;
  const SapaSantaiScreen({super.key, required this.selectedCategories});

  @override
  State<SapaSantaiScreen> createState() => _SapaSantaiScreenState();
}

class _SapaSantaiScreenState extends State<SapaSantaiScreen> {
  List<Question> _filteredQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String _currentTwist = "";

  // Kumpulan mekanik interaktif agar tidak bosan cuma geser kartu doang
  final List<String> _twistList = [
    "Jawab sambil menatap mata orang di sebelah kirimu.",
    "Tunjuk satu orang lain di meja untuk ikut menjawab pertanyaan ini.",
    "Orang di sebelah kananmu berhak memberikan satu pertanyaan interogasi tambahan!",
    "Jawab jujur dalam waktu maksimal 15 detik.",
    "Kalau kamu tidak mau menjawab, kamu harus minum atau menerima hukuman kecil dari meja.",
    "Jawab dengan nada suara seolah-olah kamu lagi berbisik rahasia.",
    "Semua orang di meja wajib ikut menjawab pertanyaan ini secara bergiliran!"
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      
      List<Question> all = data.map((json) => Question.fromJson(json)).toList();
      
      setState(() {
        // FILTER: Hanya ambil pertanyaan yang kategorinya dipilih oleh user
        _filteredQuestions = all.where((q) => widget.selectedCategories.contains(q.category)).toList();
        _filteredQuestions.shuffle();
        _getRandomTwist();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat pertanyaan: $e");
    }
  }

  void _getRandomTwist() {
    final random = Random();
    // 70% kemungkinan muncul twist biar seru, 30% standar tanpa twist
    if (random.nextDouble() > 0.3) {
      _currentTwist = _twistList[random.nextInt(_twistList.length)];
    } else {
      _currentTwist = "Jawab dengan santai bersama semua teman di meja.";
    }
  }

  void _nextCard() {
    if (_filteredQuestions.isEmpty) return;
    setState(() {
      if (_currentIndex < _filteredQuestions.length - 1) {
        _currentIndex++;
      } else {
        _filteredQuestions.shuffle();
        _currentIndex = 0;
      }
      _getRandomTwist(); // Acak ulang tantangan twistnya di kartu baru
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _isLoading 
          ? null 
          : Text(
              "KARTU ${_currentIndex + 1}/${_filteredQuestions.length}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2.0),
            ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentOrange))
          : _filteredQuestions.isEmpty
              ? const Center(child: Text("Tidak ada pertanyaan ditemukan."))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _nextCard,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOutBack,
                            child: Container(
                              key: ValueKey<int>(_currentIndex),
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Label Kategori
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentOrange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _filteredQuestions[_currentIndex].category.toUpperCase(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentOrange, letterSpacing: 1.5),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Pertanyaan Utama
                                  Text(
                                    _filteredQuestions[_currentIndex].question,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.5),
                                  ),
                                  const Spacer(),
                                  // BOX MEKANIK TWIST (Biar tidak bosan)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.accentOrange.withOpacity(0.15)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.bolt, size: 16, color: AppColors.accentOrange),
                                            const SizedBox(width: 4),
                                            Text("TANTANGAN EKSTRA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentOrange, letterSpacing: 1.0)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _currentTwist,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text("Ketuk kartu untuk selanjutnya", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}