import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../data/question_model.dart';

class SapaSantaiScreen extends StatefulWidget {
  const SapaSantaiScreen({super.key});

  @override
  State<SapaSantaiScreen> createState() => _SapaSantaiScreenState();
}

class _SapaSantaiScreenState extends State<SapaSantaiScreen> {
  List<Question> _allQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // Fungsi membaca file JSON dari assets
  Future<void> _loadQuestions() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        _allQuestions = data.map((json) => Question.fromJson(json)).toList();
        _allQuestions.shuffle(); // Kita acak biar seru tiap kali main!
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat question: $e");
    }
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _allQuestions.length - 1) {
        _currentIndex++;
      } else {
        // Kalau question habis, kita acak ulang lagi dari awal
        _allQuestions.shuffle();
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "💬 Mode: Sapa Santai",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ketuk kartu untuk menarik question baru",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  // Kartu question Utama
                  Expanded(
                    child: GestureDetector(
                      onTap: _nextCard,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Container(
                          key: ValueKey<int>(_currentIndex),
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCard,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCard.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _allQuestions[_currentIndex].category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                _allQuestions[_currentIndex].question,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}