import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 28,
                  fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 12,
                  color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }
}
