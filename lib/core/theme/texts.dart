import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';

/// Centraliza todos os estilos de texto do aplicativo para fácil acesso e manutenção.
class AppTextStyles {
  // Estilo base privado para definir a fonte padrão.
  static const TextStyle _base = TextStyle(fontFamily: 'Montserrat');

  // Efeito de brilho/sombra padrão para ser reutilizado.
  static const List<Shadow> _brightShadows = [
    Shadow(blurRadius: 4, color: Colors.white),
  ];

  // --- ESTILOS DE TÍTULO ---

  static final TextStyle titleLarge = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: tColorPrimary, // Cor explícita para títulos
  );

  static final TextStyle titleLargeBright = titleLarge.copyWith(
    color: tColorPrimary,
    shadows: _brightShadows,
  );

  static final TextStyle titleMedium = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: tColorPrimary,
  );

  static final TextStyle titleSmall = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: tColorSecondary, // Cor secundária para subtítulos
  );

  // estando certo mas a sua dpi dimiunuindo confia pois eu vou arrumar minha dpi // e vou deixar ela igual a sua disse onde arruma dpimandar
  // --- ESTILOS DE CORPO ---

  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyLargeBright = bodyLarge.copyWith(
    color: tColorPrimary,
    shadows: _brightShadows,
  );

  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );

  // --- ESTILOS DE LABEL ---

  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle labelLargeBright = labelLarge.copyWith(
    color: tColorPrimary,
    shadows: _brightShadows,
  );

  static final TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle labelSmall = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}

// TextTheme principal
/// OBS.: Estilos sem cor explícita herdarão a cor do tema.
final TextTheme appTextTheme = TextTheme(
  displayLarge: AppTextStyles.titleLarge,
  displayMedium: AppTextStyles.titleMedium,
  displaySmall: AppTextStyles.titleSmall,
  headlineMedium: AppTextStyles.titleSmall,
  bodyLarge: AppTextStyles.bodyLarge,
  bodyMedium: AppTextStyles.bodyMedium,
  bodySmall: AppTextStyles.bodySmall,
  labelLarge: AppTextStyles.labelLarge,
  labelMedium: AppTextStyles.labelMedium,
  labelSmall: AppTextStyles.labelSmall,
);
