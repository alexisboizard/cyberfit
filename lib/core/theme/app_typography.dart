import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme get lightTextTheme => _buildTextTheme(
    primary: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    tertiary: AppColors.textTertiary,
  );

  static TextTheme get darkTextTheme => _buildTextTheme(
    primary: AppColors.darkTextPrimary,
    secondary: AppColors.darkTextSecondary,
    tertiary: AppColors.darkTextTertiary,
  );

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) =>
      TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -1,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: tertiary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
      );
}
