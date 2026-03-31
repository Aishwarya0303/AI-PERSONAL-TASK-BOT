import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/app_theme.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends State<AppearanceSettingsScreen> {
  int _selectedTheme = 0;
  int _selectedFont = 0;
  double _fontSize = 14;

  final themes = [
    {'name': 'Light Brown', 'color': const Color(0xFF8B5E3C)},
    {'name': 'Dark Brown', 'color': const Color(0xFF4A2C1A)},
    {'name': 'Warm Beige', 'color': const Color(0xFFD4956A)},
    {'name': 'Forest', 'color': const Color(0xFF5A7A5A)},
  ];

  final fonts = ['Playfair Display', 'Lato', 'Roboto', 'Poppins'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildSectionTitle('Theme Color'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _buildThemeSelector(),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSectionTitle('Font Style'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: _buildFontSelector(),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSectionTitle('Font Size'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: _buildFontSizeSlider(),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildSectionTitle('Preview'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: _buildPreview(),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Appearance saved!',
                              style:
                                  GoogleFonts.lato(color: Colors.white)),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Save Appearance',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B3A2A), Color(0xFF8B5E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Customize your experience',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedTheme == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedTheme = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: (themes[index]['color'] as Color)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? themes[index]['color'] as Color
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themes[index]['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  themes[index]['name'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle,
                      size: 14,
                      color: themes[index]['color'] as Color),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fonts.asMap().entries.map((e) {
        final isSelected = _selectedFont == e.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedFont = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceBrown,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              e.value,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : AppColors.textMedium,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A',
                  style: GoogleFonts.lato(
                      fontSize: 12, color: AppColors.textLight)),
              Text(
                '${_fontSize.toInt()}px',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text('A',
                  style: GoogleFonts.lato(
                      fontSize: 20, color: AppColors.textLight)),
            ],
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 20,
            divisions: 4,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _fontSize = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryPale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themes[_selectedTheme]['color'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your tasks will look with the selected settings.',
            style: GoogleFonts.lato(
              fontSize: _fontSize,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (themes[_selectedTheme]['color'] as Color)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Sample Task Item',
              style: GoogleFonts.lato(
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                color: themes[_selectedTheme]['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
