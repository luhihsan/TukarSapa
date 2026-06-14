import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/sapa_santai/presentation/sapa_santai_screen.dart';

void main() {
  runApp(const TukarSapaApp());
}

class TukarSapaApp extends StatelessWidget {
  const TukarSapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TukarSapa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'TukarSapa 💬',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Letakkan HP di tengah meja, pilih modenya, dan mulailah mengobrol.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuCard(
                      title: '1. Sapa Santai',
                      description:
                          'Mode kartu reflektif & ice-breaker untuk mengenal lebih dalam.',
                      color: AppColors.primaryCard,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SapaSantaiScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      title: '2. Sapa Kilat (Hot Potato)',
                      description:
                          'Oper HP-nya sebelum waktu habis dan bom meledak!',
                      color: AppColors.secondaryCard,
                      onTap: () {
                        // Nanti kita arahkan ke game Sapa Kilat
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      title: '3. Sapa Tebak',
                      description:
                          'Taruh HP di jidat, tebak kata dari petunjuk temanmu.',
                      color: AppColors.accentCard,
                      onTap: () {
                        // Nanti kita arahkan ke game Sapa Tebak
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
