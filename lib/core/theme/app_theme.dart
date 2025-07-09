import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Blue Palette
  static const Color primaryColor = Color(0xFF2563EB); // Blue 600
  static const Color secondaryColor = Color(0xFF1D4ED8); // Blue 700
  static const Color accentColor = Color(0xFF60A5FA); // Blue 400
  static const Color successColor = Color(0xFF38BDF8); // Blue 300
  static const Color warningColor = Color(0xFF3B82F6); // Blue 500
  static const Color errorColor = Color(0xFF1E40AF); // Blue 800
  static const Color infoColor = Color(0xFF93C5FD); // Blue 300

  static const Color textPrimaryColor = Color(0xFF1E293B); // Slate 800
  static const Color textSecondaryColor = Color(0xFF64748B); // Slate 500
  static const Color surfaceColor = Color(0xFFF1F5F9); // Slate 100
  static const Color backgroundColor =
      Color(0xFFE0E7EF); // Blue-tinted background

  // Dark Colors
  static const Color darkPrimaryColor = Color(0xFF60A5FA); // Blue 400
  static const Color darkSecondaryColor = Color(0xFF2563EB); // Blue 600
  static const Color darkAccentColor = Color(0xFF1E40AF); // Blue 800
  static const Color darkSuccessColor = Color(0xFF38BDF8); // Blue 300
  static const Color darkWarningColor = Color(0xFF3B82F6); // Blue 500
  static const Color darkErrorColor = Color(0xFF1D4ED8); // Blue 700
  static const Color darkInfoColor = Color(0xFF93C5FD); // Blue 300

  static const Color darkTextPrimaryColor = Color(0xFFF1F5F9);
  static const Color darkTextSecondaryColor = Color(0xFFCBD5E1);
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  static const Color darkBackgroundColor = Color(0xFF0F172A);

  // Glassmorphic Decoration (Blue)
  static BoxDecoration get glassmorphicDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get darkGlassmorphicDecoration => BoxDecoration(
        color: darkPrimaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: darkPrimaryColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: darkPrimaryColor.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Typography
  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: -1.2,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.8,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: -0.4,
      );

  static TextStyle get heading4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      );

  static TextStyle get body1 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
      );

  static TextStyle get body2 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
      );

  // Dark Typography
  static TextStyle get darkHeading1 => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: darkPrimaryColor,
        letterSpacing: -1.2,
      );

  static TextStyle get darkHeading2 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: darkPrimaryColor,
        letterSpacing: -0.8,
      );

  static TextStyle get darkHeading3 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkPrimaryColor,
        letterSpacing: -0.4,
      );

  static TextStyle get darkHeading4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkPrimaryColor,
      );

  static TextStyle get darkBody1 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkTextPrimaryColor,
      );

  static TextStyle get darkBody2 => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkTextPrimaryColor,
      );

  static TextStyle get darkCaption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkTextSecondaryColor,
      );

  // Cupertino Theme Data
  static CupertinoThemeData get lightTheme => CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: primaryColor,
          textStyle: body1.copyWith(inherit: false),
          actionTextStyle: body1.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            inherit: false,
          ),
          tabLabelTextStyle: caption.copyWith(inherit: false),
          navTitleTextStyle: heading3.copyWith(inherit: false),
          navLargeTitleTextStyle: heading1.copyWith(inherit: false),
          pickerTextStyle: body1.copyWith(inherit: false),
          dateTimePickerTextStyle: body1.copyWith(inherit: false),
        ),
      );

  static CupertinoThemeData get darkTheme => CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: darkPrimaryColor,
        scaffoldBackgroundColor: darkBackgroundColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: darkPrimaryColor,
          textStyle: darkBody1.copyWith(inherit: false),
          actionTextStyle: darkBody1.copyWith(
            color: darkPrimaryColor,
            fontWeight: FontWeight.w600,
            inherit: false,
          ),
          tabLabelTextStyle: darkCaption.copyWith(inherit: false),
          navTitleTextStyle: darkHeading3.copyWith(inherit: false),
          navLargeTitleTextStyle: darkHeading1.copyWith(inherit: false),
          pickerTextStyle: darkBody1.copyWith(inherit: false),
          dateTimePickerTextStyle: darkBody1.copyWith(inherit: false),
        ),
      );
}
