import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE53E3E); // Red/Coral primary
  static const Color secondaryColor = Color(0xFFF59E0B); // Amber/Orange
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  
  // Splash screen specific colors - matching the design
  static const Color splashGradientStart = Color(0xFFFF6B8A); // Light coral/pink
  static const Color splashGradientEnd = Color(0xFFE53E3E); // Red coral

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(color: textPrimaryColor),
        bodyMedium: GoogleFonts.outfit(color: textSecondaryColor),
      ),
      // Lobster font for splash screen
      extensions: <ThemeExtension<dynamic>>[
        CustomTextTheme(
          lobsterStyle: GoogleFonts.lobster(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimaryColor),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Red/coral color
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor, // Red/coral text
          side: BorderSide(color: primaryColor), // Red/coral border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor, // Red/coral text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor, // Red/coral background
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  // Helper method to get Lobster font style
  static TextStyle get lobsterStyle => GoogleFonts.lobster(
    color: Colors.white,
    fontSize: 48,
    fontWeight: FontWeight.w400,
  );
}

// Custom theme extension for additional text styles
@immutable
class CustomTextTheme extends ThemeExtension<CustomTextTheme> {
  final TextStyle lobsterStyle;

  const CustomTextTheme({
    required this.lobsterStyle,
  });

  @override
  CustomTextTheme copyWith({
    TextStyle? lobsterStyle,
  }) {
    return CustomTextTheme(
      lobsterStyle: lobsterStyle ?? this.lobsterStyle,
    );
  }

  @override
  CustomTextTheme lerp(ThemeExtension<CustomTextTheme>? other, double t) {
    if (other is! CustomTextTheme) {
      return this;
    }
    return CustomTextTheme(
      lobsterStyle: TextStyle.lerp(lobsterStyle, other.lobsterStyle, t)!,
    );
  }
}
