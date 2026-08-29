import 'package:flutter/material.dart';

enum AppAccentColor {
  blue,
  teal,
  violet,
  coral,
}

class AccentPalette {
  final String name;
  final Color base;
  final Color hover;
  final Color soft;
  final Color lightBg;
  final Color lightBorder;
  final Color darkCanvas;
  final Color darkSurface;
  final Color darkElevated;
  final Color darkBorder;
  final Color darkSoftFill;

  const AccentPalette({
    required this.name,
    required this.base,
    required this.hover,
    required this.soft,
    required this.lightBg,
    required this.lightBorder,
    required this.darkCanvas,
    required this.darkSurface,
    required this.darkElevated,
    required this.darkBorder,
    required this.darkSoftFill,
  });
}

class AppColors {
  AppColors._();

  // --- Light Palette (ZenFlow Light Canvas) ---
  static const Color lightCanvas = Color(0xFFFAFBFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8EDF3);
  static const Color lightTextPrimary = Color(0xFF222831);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightMuted = Color(0xFF94A3B8);
  static const Color lightSubtleFill = Color(0xFFF1F5F9);

  // --- Dark Palette (ZenFlow Obsidian Canvas) ---
  static const Color darkCanvas = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkElevated = Color(0xFF243044);
  static const Color darkBorder = Color(0xFF2E3A4D);
  static const Color darkTextPrimary = Color(0xFFE8EEF6);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkMuted = Color(0xFF64748B);
  static const Color darkSubtleFill = Color(0xFF1E293B);

  // --- Semantics ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // --- Category Specific Colors ---
  static const Color categoryBills = Color(0xFF8B5CF6);
  static const Color categoryEducation = Color(0xFF06B6D4);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categorySubscription = Color(0xFF3B82F6);
  static const Color categoryFood = Color(0xFFF59E0B);
  static const Color categoryTransportation = Color(0xFF10B981);
  static const Color categoryHealthcare = Color(0xFFEF4444);
  static const Color categoryTravel = Color(0xFF6366F1);
  static const Color categoryOthers = Color(0xFF64748B);

  // --- Multi-Accent Palettes ---
  static const Map<AppAccentColor, AccentPalette> accents = {
    AppAccentColor.blue: AccentPalette(
      name: 'ZenFlow Blue',
      base: Color(0xFF1D70E8),
      hover: Color(0xFF1660CC),
      soft: Color(0xFFE2EEFC),
      lightBg: Color(0xFFF5F9FE),
      lightBorder: Color(0xFFD7E7FA),
      darkCanvas: Color(0xFF0F1419),
      darkSurface: Color(0xFF1A2332),
      darkElevated: Color(0xFF243044),
      darkBorder: Color(0xFF2E3A4D),
      darkSoftFill: Color(0xFF1E293B),
    ),
    AppAccentColor.teal: AccentPalette(
      name: 'Soft Teal',
      base: Color(0xFF14B8A6),
      hover: Color(0xFF0F9B8A),
      soft: Color(0xFFE0F7F4),
      lightBg: Color(0xFFF0FDFA),
      lightBorder: Color(0xFFC3F0EA),
      darkCanvas: Color(0xFF0F1716),
      darkSurface: Color(0xFF1A2E2B),
      darkElevated: Color(0xFF24403B),
      darkBorder: Color(0xFF2E4D47),
      darkSoftFill: Color(0xFF1E3330),
    ),
    AppAccentColor.violet: AccentPalette(
      name: 'Violet',
      base: Color(0xFF8B5CF6),
      hover: Color(0xFF7C3AED),
      soft: Color(0xFFEDE9FE),
      lightBg: Color(0xFFF5F3FF),
      lightBorder: Color(0xFFDDD6FE),
      darkCanvas: Color(0xFF110F19),
      darkSurface: Color(0xFF221A33),
      darkElevated: Color(0xFF312444),
      darkBorder: Color(0xFF3D2E4D),
      darkSoftFill: Color(0xFF27203B),
    ),
    AppAccentColor.coral: AccentPalette(
      name: 'Coral',
      base: Color(0xFFF97316),
      hover: Color(0xFFEA580C),
      soft: Color(0xFFFFEDD5),
      lightBg: Color(0xFFFFF7ED),
      lightBorder: Color(0xFFFED7AA),
      darkCanvas: Color(0xFF171210),
      darkSurface: Color(0xFF2D2118),
      darkElevated: Color(0xFF3D2E22),
      darkBorder: Color(0xFF4D3A2E),
      darkSoftFill: Color(0xFF33271E),
    ),
  };
}
