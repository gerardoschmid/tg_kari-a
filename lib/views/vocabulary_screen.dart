import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OPTIMIZADO: Datos tipados correctamente para evitar errores de acceso
    final List<Map<String, String>> words = [
      {'karina': 'Aau', 'spanish': 'Yo', 'category': 'Pronombres'},
      {'karina': 'Amooro', 'spanish': 'Tú', 'category': 'Pronombres'},
      {'karina': 'Mojko', 'spanish': 'Él / Ella', 'category': 'Pronombres'},
      {'karina': 'Wewe', 'spanish': 'Árbol', 'category': 'Sustantivos'},
      {'karina': 'Tuna', 'spanish': 'Agua', 'category': 'Sustantivos'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: words.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildBanner();
        }
        final word = words[index - 1];
        return _buildVocabularyCard(word);
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBkqEPf7IYTFBh8e21xr4AXnMi_JSr14n95FzPG5L-WxgC6AhKsqn-vH5rZCu_6XITTzQ-W-tsrQx9sD82_NlJN2Ah-DeHFjgzPDpgNMujcVVsgyC7JCzDnF7CR_F4ryp6vzG4WLBt4jkIhcJGaR7CmuI-Naq25znUxeIfL3nRQ71TM8uP6e_B_Liw3s6uF3EKpp8KJx5Wyb2krufA6TXFUk2kjDBA67jSt3tQZFjZL3Tu-yfvDRpm85U_bR-1UH149H6pUegYn28_8'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.primary.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(24),
        child: const Text(
          'Aprende sobre la naturaleza',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(Map<String, String> word) {
    // OPTIMIZADO [NUL-001]: Eliminación de aserciones '!' y uso de valores por defecto seguros
    final category = (word['category'] ?? 'General').toUpperCase();
    final karinaWord = word['karina'] ?? '---';
    final spanishWord = word['spanish'] ?? '---';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                karinaWord,
                style: AppTheme.karinaTextStyle,
              ),
              Text(
                spanishWord,
                style: AppTheme.spanishTranslationStyle,
              ),
            ],
          ),
          TactileButton(
            onPressed: () {},
            height: 56,
            padding: 0,
            child: const SizedBox(
              width: 56,
              child: Icon(Icons.volume_up, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
