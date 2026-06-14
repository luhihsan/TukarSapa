import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart'; // Menggunakan Soundpool
import 'package:vibration/vibration.dart';
import '../../../core/constants/colors.dart';

class SapaKilatScreen extends StatefulWidget {
  const SapaKilatScreen({super.key});

  @override
  State<SapaKilatScreen> createState() => _SapaKilatScreenState();
}

class _SapaKilatScreenState extends State<SapaKilatScreen> {
  final List<String> _fallbackTopics = [
    "Sebutkan nama kota di Indonesia yang berawalan huruf S.",
    "Sebutkan benda berbentuk bulat di dalam rumah.",
    "Sebutkan alasan klasik saat terlambat rapat.",
    "Sebutkan jenis pekerjaan di bidang teknologi informasi."
  ];

  List<String> _topicsList = [];
  String _currentTopic = "";
  int _gameCardIndex = 0;
  
  Timer? _masterEngineTimer;
  int _remainingMs = 10000;
  int _lastPlayedSecond = 10;
  int _hapticAccumulatorMs = 0;
  
  bool _isLoading = true;
  bool _isGameActive = false;
  bool _isGameOver = false;

  // Variabel untuk Soundpool
  late Soundpool _soundpool;
  int? _beepSoundId;
  int? _explosionSoundId;

  @override
  void initState() {
    super.initState();
    _initializeAudioComponents();
    _loadFastQuestions();
  }

  @override
  void dispose() {
    _masterEngineTimer?.cancel();
    _soundpool.release(); // Melepaskan memori RAM saat keluar layar
    super.dispose();
  }

  /// Menginisialisasi Soundpool dan me-load data mentah audio ke RAM
  Future<void> _initializeAudioComponents() async {
    // Menggunakan streamType notification yang ringan
    _soundpool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification)
    );

    try {
      // Sangat disarankan file asli dikonversi ke format .wav agar CPU tidak perlu decoding
      _beepSoundId = await rootBundle.load('assets/audio/countdown.wav').then((ByteData soundData) {
        return _soundpool.load(soundData);
      });
      
      _explosionSoundId = await rootBundle.load('assets/audio/explosion.wav').then((ByteData soundData) {
        return _soundpool.load(soundData);
      });
    } catch (e) {
      debugPrint("Gagal memuat aset audio ke Soundpool: $e");
    }
  }

  Future<void> _loadFastQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/fast_questions.json');
      final List<dynamic> data = json.decode(response);
      
      final parsedList = data.map((item) {
        final dynamic value = item['topics'];
        return value?.toString() ?? '';
      }).where((text) => text.isNotEmpty).toList();

      if (parsedList.isEmpty) throw Exception("Format JSON valid namun list kosong.");

      setState(() {
        _topicsList = parsedList;
        _topicsList.shuffle();
        _gameCardIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat JSON: $e");
      setState(() {
        _topicsList = List.from(_fallbackTopics);
        _topicsList.shuffle();
        _gameCardIndex = 0;
        _isLoading = false;
      });
    }
  }

  void _startNewCardCycle() {
    _masterEngineTimer?.cancel();
    
    setState(() {
      _remainingMs = 10000;
      _lastPlayedSecond = 11; 
      _hapticAccumulatorMs = 0;
      
      _currentTopic = _topicsList[_gameCardIndex];
      _gameCardIndex = (_gameCardIndex + 1) % _topicsList.length;
      
      if (_gameCardIndex == 0) {
        _topicsList.shuffle();
      }
      
      _isGameActive = true;
      _isGameOver = false;
    });

    _startMasterEngine();
  }

  void _startMasterEngine() {
    _masterEngineTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingMs -= 100;
      });

      final int currentSecond = (_remainingMs / 1000).ceil();

      // Audio Sync: Memanggil file di RAM yang sangat instan
      if (currentSecond < _lastPlayedSecond && currentSecond > 0) {
        _lastPlayedSecond = currentSecond;
        if (_beepSoundId != null) {
          _soundpool.play(_beepSoundId!);
        }
      }

      // Haptic Sync
      _hapticAccumulatorMs += 100;
      int dynamicHapticInterval = 1000; 

      if (currentSecond <= 3) {
        dynamicHapticInterval = 200;  
      } else if (currentSecond <= 6) {
        dynamicHapticInterval = 500;  
      }

      if (_hapticAccumulatorMs >= dynamicHapticInterval) {
        _hapticAccumulatorMs = 0;
        _triggerHardwareHaptic();
      }

      if (_remainingMs <= 0) {
        _triggerTimeOutLoss();
      }
    });
  }

  Future<void> _triggerHardwareHaptic() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    } else {
      HapticFeedback.heavyImpact(); 
    }
  }

  void _triggerTimeOutLoss() {
    _masterEngineTimer?.cancel();
    _triggerHardwareHaptic();
    
    if (_explosionSoundId != null) {
      _soundpool.play(_explosionSoundId!);
    }

    setState(() {
      _remainingMs = 0;
      _isGameActive = false;
      _isGameOver = true;
    });
  }

  void _executePassCard() {
    HapticFeedback.lightImpact(); 
    _startNewCardCycle();
  }

  @override
  Widget build(BuildContext context) {
    final int displaySeconds = (_remainingMs / 1000).ceil();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
          : Padding(
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
                              "Setiap pemain hanya memiliki waktu 10 detik untuk memberikan satu jawaban unik berdasarkan topik yang muncul. Segera tekan tombol oper setelah menjawab untuk menyegarkan waktu ke 10 detik bagi pemain berikutnya.",
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
                                onPressed: _startNewCardCycle,
                                child: const Text("Mulai Permainan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ] else if (_isGameActive) ...[
                            Text(
                              "SISA WAKTU: $displaySeconds DETIK",
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.w800, 
                                color: displaySeconds <= 3 ? AppColors.accentOrange : AppColors.accentGreen, 
                                letterSpacing: 1.0
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _currentTopic,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.4),
                            ),
                            const Spacer(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _remainingMs / 10000,
                                minHeight: 8,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  displaySeconds <= 3 ? AppColors.accentOrange : AppColors.accentGreen
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _executePassCard,
                                child: const Text(
                                  "Selesai Jawab dan Oper Perangkat",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ),
                          ] else if (_isGameOver) ...[
                            const Icon(Icons.alarm_off_rounded, color: AppColors.accentOrange, size: 64),
                            const SizedBox(height: 24),
                            const Text(
                              "Waktu Anda Habis",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Perangkat gagal dioper sebelum batas waktu habis. Pemain yang memegang perangkat saat ini menerima konsekuensi kekalahan.",
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
                                onPressed: _startNewCardCycle,
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