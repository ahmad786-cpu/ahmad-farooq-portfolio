import 'package:flutter/material.dart';

/// Colours and type from the HTML portfolio (style.css), so both versions look like one brand.
abstract final class AppColors {
  static const bg = Color(0xFF03091A);
  static const card = Color(0xFF081A3D);
  static const cardHover = Color(0xFF112B5A);
  static const primary = Color(0xFF18B5FF);
  static const secondary = Color(0xFF0D5CFF);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFFCBD5E1);
  static const dim = Color(0xFF94A3B8);
  static const border = Color(0x14FFFFFF);
  static const borderHover = Color(0x4D18B5FF);
  static const glass = Color(0xB3081A3D);

  static const gradient = LinearGradient(colors: [primary, secondary]);
}

/// Breakpoints shared by every section.
abstract final class Breakpoints {
  static const tablet = 760.0;
  static const desktop = 1100.0;
  static const maxContent = 1200.0;
}

TextStyle display(
  double size, {
  FontWeight weight = FontWeight.w700,
  Color color = AppColors.text,
  double height = 1.1,
}) => TextStyle(
  fontFamily: 'Outfit',
  fontSize: size,
  fontWeight: weight,
  // Variable fonts: set the weight axis too, so bold renders as bold everywhere.
  fontVariations: [FontVariation.weight(weight.value.toDouble())],
  color: color,
  height: height,
  letterSpacing: -0.5,
);

TextStyle body(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.muted,
  double height = 1.7,
}) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation.weight(weight.value.toDouble())],
  color: color,
  height: height,
);

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.muted,
      displayColor: AppColors.text,
    ),
    splashFactory: NoSplash.splashFactory,
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textStyle: TextStyle(color: AppColors.text),
    ),
  );
}
