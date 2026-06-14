import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/sapa_kilat/presentation/sapa_kilat_screen.dart';
import 'features/sapa_santai/presentation/category_selection_screen.dart';

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
     themeMode: ThemeMode.light, 
     theme: ThemeData(
       brightness: Brightness.light,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'TukarSapa',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'v1.0',
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Letakkan HP di tengah meja. Pilih mode permainan dan mulailah berinteraksi tatap muka.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildModernMenuCard(
                      context,
                      title: 'Sapa Santai',
                      tagline: 'ICE BREAKER & REFLEKTIF',
                      description: 'Tumpukan kartu pertanyaan mendalam untuk mengenal satu sama lain lebih intim.',
                      icon: Icons.chat_bubble_outline_rounded,
                      accentColor: AppColors.accentOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModernMenuCard(
                      context,
                      title: 'Sapa Kilat',
                      tagline: 'HOT POTATO GAME',
                      description: 'Oper HP-nya secepat mungkin! Sebutkan jawaban sebelum bom waktu meledak di tanganmu.',
                      icon: Icons.timer_outlined,
                      accentColor: AppColors.accentGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SapaKilatScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModernMenuCard(
                      context,
                      title: 'Sapa Tebak',
                      tagline: 'CHARADES PERFORMANCE',
                      description: 'Taruh HP di jidatmu. Tebak kata konyol berdasarkan gerakan dan petunjuk dari temanmu.',
                      icon: Icons.theater_comedy_outlined,
                      accentColor: AppColors.accentBlue,
                      onTap: () {
                        // Untuk pengembangan mode sapa tebak nanti
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

  Widget _buildModernMenuCard(
    BuildContext context, {
    required String title,
    required String tagline,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tagline,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}