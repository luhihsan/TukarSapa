import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';

/// Halaman permainan untuk Mode Sapa Kilat (Hot Potato).
/// Menggunakan mekanik penghitung waktu mundur acak dan umpan balik haptik
/// untuk menciptakan interaksi kelompok yang dinamis.
class SapaKilatScreen extends StatefulWidget {
  const SapaKilatScreen({super.key});

  @override
  State<SapaKilatScreen> createState() => _SapaKilatScreenState();
}

class _SapaKilatScreenState extends State<SapaKilatScreen> {
  // Daftar topik spontan untuk dijawab oleh pemain secara bergiliran
  final List<String> _topics = [
    "Sebutkan nama kota di Indonesia yang berawalan huruf S.",
    "Sebutkan benda berbentuk bulat yang biasa ditemukan di dalam rumah.",
    "Sebutkan alasan klasik yang sering digunakan saat terlambat menghadiri rapat.",
    "Sebutkan jenis pekerjaan yang berhubungan langsung dengan teknologi informasi.",
    "Sebutkan menu sarapan yang praktis dan cepat untuk disajikan.",
    "Sebutkan judul lagu Indonesia yang bertemakan tentang persahabatan.",
    "Sebutkan aplikasi telepon genggam yang paling sering Anda buka setiap hari.",
    "Sebutkan kata benda yang memiliki tekstur kasar saat disentuh."
  ];

  String _currentTopic = "";
  Timer? _countdownTimer;
  Timer? _hapticTimer;
  
  int _remainingSeconds = 0;
  bool _isGameActive = false;
  bool _isGameOver = false;

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  /// Memulai sesi permainan baru dengan menginisialisasi topik dan waktu acak.
  void _startGame() {
    final random = Random();
    setState(() {
      // Menentukan durasi permainan secara acak antara 15 hingga 30 detik
      _remainingSeconds = 15 + random.nextInt(16);
      _currentTopic = _topics[random.nextInt(_topics.length)];
      _isGameActive = true;
      _isGameOver = false;
    });

    _startCountdown();
    _startHapticFeedback();
  }

  /// Menghentikan seluruh proses pengukur waktu (timer) yang sedang berjalan.
  void _stopTimers() {
    _countdownTimer?.cancel();
    _hapticTimer?.cancel();
  }

  /// Mengelola logika penghitung waktu mundur per detik.
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _triggerExplosion();
      }
    });
  }

  /// Mengelola intensitas getaran perangkat berdasarkan sisa waktu yang tersedia.
  void _startHapticFeedback() {
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      // Intensitas getaran meningkat (durasi jeda mengecil) saat waktu di bawah 7 detik
      if (_remainingSeconds <= 7) {
        HapticFeedback.vibrate();
      } else if (_remainingSeconds % 2 == 0) {
        // Getaran normal berkala sebelum memasuki fase kritis
        HapticFeedback.selectionClick();
      }
    });
  }

  /// Mengeksekusi kondisi ketika waktu permainan telah habis (Bom Meledak).
  void _triggerExplosion() {
    _stopTimers();
    HapticFeedback.heavyImpact();
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });
  }

  /// Memindahkan giliran permainan ke pemain berikutnya tanpa mengubah topik.
  void _passTurn() {
    HapticFeedback.lightImpact();
    // Tambahkan visualisasi transisi singkat di sini jika diperlukan pada pengembangan lanjutan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MODE SAPA KILAT",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
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
                    if (!_isGameActive && !_isGameOver) ...[
                      const Text(
                        "Aturan Permainan",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Formasi melingkar. Berikan satu jawaban yang valid sesuai topik di layar, kemudian segera oper perangkat ke pemain di sebelah Anda sebelum waktu habis.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: _startGame,
                          child: const Text("Mulai Permainan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else if (_isGameActive) ...[
                      const Text(
                        "Topik Saat Ini",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentGreen, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _currentTopic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.4),
                      ),
                      const Spacer(),
                      // Indikator visual ketegangan (warna berubah saat kritis)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _remainingSeconds <= 7 
                              ? AppColors.accentOrange.withOpacity(0.1) 
                              : AppColors.accentGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            color: _remainingSeconds <= 7 ? AppColors.accentOrange : AppColors.accentGreen,
                            size: 32,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.textPrimary, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _passTurn,
                          child: const Text(
                            "Selesai Jawab dan Oper Perangkat",
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ] else if (_isGameOver) ...[
                      const Icon(Icons.gavel_rounded, color: AppColors.accentOrange, size: 64),
                      const SizedBox(height: 24),
                      const Text(
                        "Waktu Habis",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pemain yang memegang perangkat saat ini dinyatakan kalah dan wajib menerima konsekuensi sesuai kesepakatan bersama.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: _startGame,
                          child: const Text("Main Lagi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}