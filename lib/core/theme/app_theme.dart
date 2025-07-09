import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color surfaceColor = Color(0xFFF9FAFB);
  static const Color backgroundColor = Color(0xFFF3F4F6);

  // Dark Colors
  static const Color darkPrimaryColor = Color(0xFF818CF8);
  static const Color darkSecondaryColor = Color(0xFFA78BFA);
  static const Color darkAccentColor = Color(0xFF22D3EE);
  static const Color darkSuccessColor = Color(0xFF34D399);
  static const Color darkWarningColor = Color(0xFFFBBF24);
  static const Color darkErrorColor = Color(0xFFF87171);
  static const Color darkInfoColor = Color(0xFF60A5FA);

  static const Color darkTextPrimaryColor = Color(0xFFF9FAFB);
  static const Color darkTextSecondaryColor = Color(0xFFD1D5DB);
  static const Color darkSurfaceColor = Color(0xFF1F2937);
  static const Color darkBackgroundColor = Color(0xFF111827);

  // Glassmorphic Decoration
  static BoxDecoration get glassmorphicDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get darkGlassmorphicDecoration => BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Typography
  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      );

  static TextStyle get heading3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      );

  static TextStyle get heading4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
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
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkTextPrimaryColor,
      );

  static TextStyle get darkHeading2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkTextPrimaryColor,
      );

  static TextStyle get darkHeading3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextPrimaryColor,
      );

  static TextStyle get darkHeading4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkTextPrimaryColor,
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
          textStyle: body1,
          actionTextStyle: body1.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          tabLabelTextStyle: caption,
          navTitleTextStyle: heading3,
          navLargeTitleTextStyle: heading1,
          pickerTextStyle: body1,
          dateTimePickerTextStyle: body1,
        ),
      );

  static CupertinoThemeData get darkTheme => CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: darkPrimaryColor,
        scaffoldBackgroundColor: darkBackgroundColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: darkPrimaryColor,
          textStyle: darkBody1,
          actionTextStyle: darkBody1.copyWith(
            color: darkPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          tabLabelTextStyle: darkCaption,
          navTitleTextStyle: darkHeading3,
          navLargeTitleTextStyle: darkHeading1,
          pickerTextStyle: darkBody1,
          dateTimePickerTextStyle: darkBody1,
        ),
      );
}
