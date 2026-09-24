import 'package:flutter/material.dart';

/// Raw colors and shared design tokens for the app.
///
/// The accent colors are sampled from the banner artwork
/// (`assets/moon.webp`): a muted sky blue, a warm cream moon, and soft teal
/// clouds.
abstract final class AppColors {
  // Accent seeds.
  static const Color skyBlue = Color(0xFF4E93B8);
  static const Color cream = Color(0xFFF2D6AE);
  static const Color teal = Color(0xFF4C7A72);

  // Neutral surfaces.
  static const Color lightSurface = Color(0xFFF6F8FA);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);

  static const Color darkSurface = Color(0xFF101418);
  static const Color darkSurfaceContainer = Color(0xFF1A1F24);
  static const Color darkOnSurface = Color(0xFFE2E8EC);

  static const Color amoledSurface = Color(0xFF000000);
  static const Color amoledSurfaceContainer = Color(0xFF0B0D0F);
  static const Color amoledOnSurface = Color(0xFFE2E8EC);

  // Secondary (cream) roles, tuned per brightness for contrast.
  static const Color lightSecondary = Color(0xFF8A6A3A);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFF6E3C6);
  static const Color lightOnSecondaryContainer = Color(0xFF2A1C05);

  static const Color darkSecondary = cream;
  static const Color darkOnSecondary = Color(0xFF3E2E12);
  static const Color darkSecondaryContainer = Color(0xFF574424);
  static const Color darkOnSecondaryContainer = Color(0xFFF6E3C6);
}

/// Spacing, radius, and motion tokens shared across the UI.
abstract final class AppTokens {
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
}
