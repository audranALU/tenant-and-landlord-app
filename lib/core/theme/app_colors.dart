import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF1B4D3E);
  static const Color primaryDark = Color(0xFF0F3028);
  static const Color primaryLight = Color(0xFFE8F0ED);

  // ── Accent / Gold ──
  static const Color accent = Color(0xFFD4A03C);
  static const Color accentLight = Color(0xFFFDF6E3);

  // ── Backgrounds ──
  static const Color background = Color(0xFFF5F3EF);
  static const Color cardBackground = Colors.white;
  static const Color surfaceDark = Color(0xFF2A5F4F);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Color(0xFF1A1A1A);

  // ── Borders ──
  static const Color border = Color(0xFFE0DCD6);
  static const Color inputBorder = Color(0xFFD9D5CF);

  // ── Status colors ──
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF2563EB);

  // ── Status badge backgrounds ──
  static const Color openBg = Color(0xFFFEF3C7);
  static const Color openText = Color(0xFF92400E);
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color inProgressText = Color(0xFF1E40AF);
  static const Color assignedBg = Color(0xFFE8E8E8);
  static const Color assignedText = Color(0xFF444444);
  static const Color resolvedBg = Color(0xFFD1FAE5);
  static const Color resolvedText = Color(0xFF065F46);

  // ── Priority dot colors ──
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);
}
