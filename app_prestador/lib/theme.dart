import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary = Color(0xFF173426);
const _onPrimary = Color(0xFFFFFFFF);
const _primaryContainer = Color(0xFF2E4B3C);
const _onPrimaryContainer = Color(0xFF9ABAA7);
const _secondary = Color(0xFF79591D);
const _onSecondary = Color(0xFFFFFFFF);
const _secondaryContainer = Color(0xFFFDD089);
const _onSecondaryContainer = Color(0xFF78581C);
const _tertiary = Color(0xFF322F26);
const _onTertiary = Color(0xFFFFFFFF);
const _tertiaryContainer = Color(0xFF49453B);
const _onTertiaryContainer = Color(0xFFB9B2A6);
const _error = Color(0xFFBA1A1A);
const _onError = Color(0xFFFFFFFF);
const _errorContainer = Color(0xFFFFDAD6);
const _onErrorContainer = Color(0xFF93000A);
const _surface = Color(0xFFFCF9F8);
const _onSurface = Color(0xFF1C1B1B);
const _onSurfaceVariant = Color(0xFF424844);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _surfaceContainerLow = Color(0xFFF6F3F2);
const _surfaceContainer = Color(0xFFF0EDED);
const _surfaceContainerHigh = Color(0xFFEAE7E7);
const _surfaceContainerHighest = Color(0xFFE5E2E1);
const _outline = Color(0xFF727973);
const _outlineVariant = Color(0xFFC2C8C2);
const _inverseSurface = Color(0xFF313030);
const _inverseOnSurface = Color(0xFFF3F0EF);
const _inversePrimary = Color(0xFFADCEBA);

final efraimTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: _onPrimary,
    primaryContainer: _primaryContainer,
    onPrimaryContainer: _onPrimaryContainer,
    secondary: _secondary,
    onSecondary: _onSecondary,
    secondaryContainer: _secondaryContainer,
    onSecondaryContainer: _onSecondaryContainer,
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    tertiaryContainer: _tertiaryContainer,
    onTertiaryContainer: _onTertiaryContainer,
    error: _error,
    onError: _onError,
    errorContainer: _errorContainer,
    onErrorContainer: _onErrorContainer,
    surface: _surface,
    onSurface: _onSurface,
    onSurfaceVariant: _onSurfaceVariant,
    outline: _outline,
    outlineVariant: _outlineVariant,
    inverseSurface: _inverseSurface,
    onInverseSurface: _inverseOnSurface,
    inversePrimary: _inversePrimary,
    surfaceContainerLowest: _surfaceContainerLowest,
    surfaceContainerLow: _surfaceContainerLow,
    surfaceContainer: _surfaceContainer,
    surfaceContainerHigh: _surfaceContainerHigh,
    surfaceContainerHighest: _surfaceContainerHighest,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.w700),
    headlineLarge: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.w500),
    headlineSmall: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
    bodyMedium: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
    labelLarge: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.4),
    labelSmall: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500),
  ),
  cardTheme: const CardThemeData(
    color: _surfaceContainerLowest,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      side: BorderSide(color: Color(0x1A173426)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: _onPrimary,
      textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.4),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _secondary,
      side: const BorderSide(color: _secondary, width: 1.5),
      textStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surfaceContainerLowest,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: _outlineVariant),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: _secondary, width: 1.5),
    ),
    labelStyle: GoogleFonts.montserrat(color: _onSurfaceVariant),
  ),
  scaffoldBackgroundColor: _surface,
  appBarTheme: AppBarTheme(
    backgroundColor: _surface,
    foregroundColor: _primary,
    elevation: 0,
    titleTextStyle: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w500, color: _primary),
    iconTheme: const IconThemeData(color: _primary),
  ),
  dividerColor: _outlineVariant,
);
