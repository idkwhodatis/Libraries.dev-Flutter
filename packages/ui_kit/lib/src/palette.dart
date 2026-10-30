import 'package:flutter/material.dart';

abstract final class SiteColors {
  static const page = Color(0xFF121212);
  static const card = Color(0xFF181818);
  static const cardHover = Color(0xFF1C1C1C);
  static const stage = Color(0xFF131313);
  static const code = Color(0xFF171717);
  static const panel = Color(0xFF1B1B1B);
  static const menu = Color(0xFF202020);
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFF9E9E9E);
  static const subtle = Color(0xFF767676);
  static const faint = Color(0xFF5C5C5C);
  static const accent = Color(0xFF55CFFF);
  static const accentStrong = Color(0xFF0071FC);
  static const proInk = Color(0xFF7DB4FF);
  static const proTint = Color(0x2E0071FC);
  static const line = Color(0x14FFFFFF);
  static const lineStrong = Color(0x24FFFFFF);
  static const danger = Color(0xFFE2857A);
  static const success = Color(0xFF4ADE80);
}

ThemeData buildSiteTheme() {
  const scheme = ColorScheme.dark(
    primary: SiteColors.accent,
    onPrimary: SiteColors.page,
    secondary: SiteColors.accentStrong,
    onSecondary: SiteColors.text,
    surface: SiteColors.card,
    onSurface: SiteColors.text,
    error: SiteColors.danger,
    onError: SiteColors.page,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: SiteColors.page,
    fontFamily: 'Inter',
    splashFactory: NoSplash.splashFactory,
  );

  final text = base.textTheme.copyWith(
    displayLarge: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 52,
      height: 1.05,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
      color: SiteColors.text,
    ),
    displayMedium: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 42,
      height: 1.07,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.4,
      color: SiteColors.text,
    ),
    displaySmall: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 36,
      height: 1.16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
      color: SiteColors.text,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
      color: SiteColors.text,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 22,
      height: 1.25,
      fontWeight: FontWeight.w500,
      color: SiteColors.text,
    ),
    titleMedium: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: SiteColors.text,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: SiteColors.muted,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      height: 1.55,
      fontWeight: FontWeight.w400,
      color: SiteColors.muted,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: SiteColors.subtle,
    ),
    labelLarge: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: SiteColors.text,
    ),
    labelMedium: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: SiteColors.muted,
    ),
    labelSmall: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: SiteColors.subtle,
    ),
  );

  return base.copyWith(
    textTheme: text,
    dividerColor: SiteColors.line,
    iconTheme: const IconThemeData(color: SiteColors.muted, size: 18),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: SiteColors.menu,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SiteColors.lineStrong),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: SiteColors.text,
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(const Color(0x33FFFFFF)),
      radius: const Radius.circular(99),
    ),
  );
}
