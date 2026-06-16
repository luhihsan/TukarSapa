import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:soundpool/soundpool.dart';
import '../../../core/constants/colors.dart';

/// Halaman permainan Mode Sapa Tebak (Charades).
/// Memanfaatkan sensor akselerometer untuk mendeteksi kemiringan perangkat,
/// serta menggunakan Soundpool untuk pemutaran audio latensi rendah.
class SapaTebakScreen extends StatefulWidget {
  const SapaTebakScreen({super.key});

  @override
  State<SapaTebakScreen> createState() => _SapaTebakScreenState();
}

class _SapaTebakScreenState extends State<SapaTebakScreen> {
  final List<String> _fallbackWords = ["Bermain Gitar", "Makan Pedas", "Menangis", "Berenang"];
  List<String> _wordsList = [];
  
  int _wordIndex = 0;
  int _score = 0;
  int _remainingSeconds = 60; // Durasi permainan 60 detik
  
  bool _isLoading = true;
  bool _isGameActive = false;
  bool _isGameOver = false;
  bool _isCooldown = false; // Mencegah pemicu ganda pada sensor gerak
  
  Color _backgroundColor = AppColors.background;
  
  Timer? _gameTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  // Konfigurasi Soundpool
  late Soundpool _soundpool;
  int? _countdownSoundId;

  @override
  void initState() {
    super.initState();
    _initializeSoundpool();
    _loadWords();
    // Mengunci orientasi perangkat agar lebih nyaman saat diletakkan di dahi
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    _cleanupResources();
    // Mengembalikan orientasi ke mode potret saat keluar dari halaman ini
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  /// Menginisialisasi Soundpool dan memuat aset audio ke memori
  Future<void> _initializeSoundpool() async {
    _soundpool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification),
    );
    
    try {
      final ByteData soundData = await rootBundle.load('assets/audio/countdown.mp3');
      _countdownSoundId = await _soundpool.load(soundData);
    } catch (e) {
      debugPrint("Gagal memuat audio Soundpool: $e");
    }
  }

  void _cleanupResources() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _soundpool.release(); // Membersihkan memori audio
  }

  Future<void> _loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/charades_words.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _wordsList = data.map((item) => item['kata'].toString()).toList();
        _wordsList.shuffle();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat kata tebakan: $e");
      setState(() {
        _wordsList = List.from(_fallbackWords);
        _isLoading = false;
      });
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _remainingSeconds = 60;
      _wordIndex = 0;
      _wordsList.shuffle();
      _isGameActive = true;
      _isGameOver = false;
      _backgroundColor = AppColors.background;
    });

    _startTimer();
    _startSensorListener();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        // Memutar suara countdown di 5 detik terakhir
        if (_remainingSeconds <= 5 && _countdownSoundId != null) {
          _soundpool.play(_countdownSoundId!);
        }
      } else {
        _endGame();
      }
    });
  }

  /// Mengaktifkan pendengar sensor akselerometer.
  void _startSensorListener() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isGameActive || _isCooldown) return;

      // Sumbu Z positif mendeteksi layar menghadap ke atas (Plafon) -> LEWATI
      if (event.z > 6.0) {
        _registerAnswer(isCorrect: false);
      } 
      // Sumbu Z negatif mendeteksi layar menghadap ke bawah (Lantai) -> BENAR
      else if (event.z < -6.0) {
        _registerAnswer(isCorrect: true);
      }
    });
  }

  /// Mengelola logika penilaian dan transisi visual saat sensor terpicu.
  void _registerAnswer({required bool isCorrect}) {
    setState(() {
      _isCooldown = true;
      _backgroundColor = isCorrect ? AppColors.accentGreen : AppColors.accentOrange;
      if (isCorrect) _score++;
    });

    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!_isGameActive) return;
      setState(() {
        _wordIndex = (_wordIndex + 1) % _wordsList.length;
        _backgroundColor = AppColors.background;
        _isCooldown = false;
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();
    HapticFeedback.vibrate();
    
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
      _backgroundColor = AppColors.background;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _backgroundColor,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : _buildGameInterface(),
        ),
      ),
    );
  }

  Widget _buildGameInterface() {
    if (!_isGameActive && !_isGameOver) {
      return _buildInstructionScreen();
    } else if (_isGameActive) {
      return _buildActiveGameScreen();
    } else {
      return _buildScoreScreen();
    }
  }

  Widget _buildInstructionScreen() {
    return Stack(
      children: [
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("SAPA TEBAK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                const Text("Letakkan perangkat di depan dahi Anda.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.screen_rotation_rounded, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text("Miringkan ke Bawah = Benar  |  Miringkan ke Atas = Lewati", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _startGame,
                  child: const Text("Mulai Permainan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGameScreen() {
    return Center(
      child: _isCooldown
          ? Text(
              _backgroundColor == AppColors.accentGreen ? "BENAR!" : "LEWATI",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4.0),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SISA WAKTU: $_remainingSeconds",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: _remainingSeconds <= 10 ? AppColors.accentOrange : AppColors.textMuted
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _wordsList[_wordIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildScoreScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Waktu Habis", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text("Skor Anda: $_score", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: AppColors.textPrimary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _startGame,
                child: const Text("Main Lagi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}