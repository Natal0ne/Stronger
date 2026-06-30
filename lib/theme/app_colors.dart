import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cambiato il nome per riflettere Material 3 (es: un grigio scurissimo o nero)
  static const Color backgroundSurface = Color(0xFF121212);
  // Superfici rialzate (Card, AppBar, NavigationBar)
  static const Color surfaceContainer = Color(0xFF1E1E1E);

  static const Color accent = Color(0xFF96E6A1); // Il tuo verde acido

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;

  static const Color beginner = Colors.greenAccent;
  static const Color intermediate = Colors.amberAccent;
  static const Color advanced = Colors.redAccent;
}
