import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Red Wine color
  static const Color primaryColor = Color(0xFF722F37);
  static const Color primaryDark = Color(0xFF4A1A22);
  static const Color primaryLight = Color(0xFF9A4E58);
  
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF9F9F9);
  
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold, fontSize: 28),
        titleLarge: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.w600, fontSize: 22),
        bodyLarge: GoogleFonts.outfit(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: textLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      useMaterial3: true,
    );
  }
}
