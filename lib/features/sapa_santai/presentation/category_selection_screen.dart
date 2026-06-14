import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'sapa_santai_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<String> _categories = [
    "Kenangan Masa Kecil",
    "Ambisi & Karir",
    "Hal Absurd",
    "Refleksi Diri",
    "Hubungan Interpersonal"
  ];
  final List<String> _selectedCategories = [];

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Topik Obrolan',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kamu bisa memilih lebih dari satu kategori atau langsung acak semua.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedCategories.length == _categories.length) {
                    _selectedCategories.clear();
                  } else {
                    _selectedCategories.clear();
                    _selectedCategories.addAll(_categories);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _selectedCategories.length == _categories.length 
                      ? AppColors.accentOrange.withOpacity(0.1) 
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCategories.length == _categories.length 
                        ? AppColors.accentOrange 
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shuffle, 
                      color: _selectedCategories.length == _categories.length ? AppColors.accentOrange : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Semua Kategori (Random)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedCategories.length == _categories.length ? AppColors.accentOrange : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategories.contains(cat);
                  return Card(
                    color: AppColors.surface,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? AppColors.accentOrange : Colors.black.withOpacity(0.05), width: isSelected ? 1.5 : 1),
                    ),
                    child: CheckboxListTile(
                      title: Text(cat, style: const TextStyle(fontWeight:FontWeight.w600, color: AppColors.textPrimary)),
                      value: isSelected,
                      activeColor: AppColors.accentOrange,
                      checkColor: Colors.white,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategories.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _selectedCategories.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SapaSantaiScreen(selectedCategories: _selectedCategories),
                              ),
                            );
                          },
                    child: const Text('Mulai', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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