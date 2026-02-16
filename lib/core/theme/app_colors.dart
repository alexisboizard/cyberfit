import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF1D4ED8);

  // Secondary (success/validation)
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF059669);

  // Accent (gamification/energy)
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);
  static const accentDark = Color(0xFFD97706);

  // Error/Alert
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFCA5A5);

  // Neutrals
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F4F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFF3F4F6);

  // Semantic
  static const streak = Color(0xFFFF6B35);
  static const bronze = Color(0xFFCD7F32);
  static const silver = Color(0xFFC0C0C0);
  static const gold = Color(0xFFFFD700);

  // Score domain colors
  static const passwords = Color(0xFF8B5CF6);
  static const authentication = Color(0xFF06B6D4);
  static const privacy = Color(0xFFEC4899);
  static const emails = Color(0xFF14B8A6);
  static const devices = Color(0xFFF97316);
}
