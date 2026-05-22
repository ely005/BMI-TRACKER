import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryTeal = Color(0xFF14B8A6);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFDC2626);

  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color mutedGray = Color(0xFF64748B);

  // Additional colors for gradients, borders, shadows, and BMI categories
  static const Color gradientStart = Color(0xFF2563EB); // primaryBlue
  static const Color gradientEnd = Color(0xFF14B8A6); // secondaryTeal

  static const Color lightBlue = Color(0xFFBFDBFE);
  static const Color lightTeal = Color(0xFFCCFBF1);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  static const Color shadowColor = Color(0x1A0F172A); // 10% opacity of textDark

  // BMI category colors
  static const Color underweightColor = Color(0xFF3B82F6); // blue
  static const Color normalColor = Color(0xFF10B981); // green
  static const Color overweightColor = Color(
    0xFFF59E0B,
  ); // orange (same as warning)
  static const Color obeseColor = Color(0xFFEF4444); // red
}
