import 'package:flutter/material.dart';

/// Colores institucionales de la FET.
/// Si quieres cambiar un color en toda la app, cámbialo SOLO aquí.
class FetColors {
  static const Color verde = Color(0xFFF40009);
  static const Color verdeOscuro = Color(0xFFB00007);
  static const Color verdeClaro = Color(0xFFFDE8E9);
  static const Color fondo = Color(0xFFFAF5F5);
  static const Color gris = Color(0xFF4A4F4B);
}

/// Tema general de la aplicación.
class FetTheme {
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FetColors.verde,
        primary: FetColors.verde,
        secondary: FetColors.verdeOscuro,
      ),
      scaffoldBackgroundColor: FetColors.fondo,
    );
  }
}
