// lib/theme.dart
import 'package:flutter/material.dart';

/// Unified Black & White Design System for KULAIDOVERSE
class AppTheme {
  AppTheme._();

  // === COLORS ===
  static const Color pureBlack = Colors.black;
  static const Color pureWhite = Colors.white;
  static const Color softBlack = Color(0xFF1A1A1A);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFCCCCCC);

  // === BORDER RADIUS ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // === SPACING ===
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // === ELEVATION ===
  static const double elevationNone = 0;
  static const double elevationLow = 2;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

  // === SHADOWS ===
  static List<BoxShadow> get shadowLow => [
    BoxShadow(
      color: pureBlack.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: pureBlack.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // === TEXT STYLES ===
  static const TextStyle appName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: pureBlack,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: pureBlack,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: pureWhite,
  );

  static const TextStyle cardTitleBlack = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: pureBlack,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: pureBlack,
  );

  static const TextStyle bodyTextWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: pureWhite,
  );

  // === DECORATIONS ===
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: softBlack,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: shadowLow,
  );

  static BoxDecoration get whiteCardDecoration => BoxDecoration(
    color: pureWhite,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: shadowLow,
    border: Border.all(color: lightGrey.withOpacity(0.5)),
  );
}
