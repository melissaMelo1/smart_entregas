import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Cores Principais (Pantone)
  static const primaryColor = Color(0xFF0A1E2C); // Pantone 5395 C (#0a1e2c)
  static const secondaryColor = Color(0xFF02426A); // Pantone 7694 C (#02426a)
  static const accentColor = Color(0xFFE13C32); // Pantone 179 C (#e13c32)

  // Cores Complementares
  static const legacyBlack = Color(0xFF161616); // #161616 (CMYK 0 0 0 91)
  static const stoneShadow = Color(0xFF383A37); // #383a37 (CMYK 30 5 77)
  static const graniteMist = Color(0xFFA6AEA3); // #a6aea3 (CMYK 50 6 32)
  static const ivoryDust = Color(0xFFF5F4F2); // #f5f4f2 (CMYK 0 0 1 4)

  // Cores do Login
  static const loginPurple = Color(0xFF828bc2); // Cor de fundo da tela de login
  static const loginTextColor = Colors.white; // Cor do texto na tela de login
  static const loginButtonBg = Colors.white; // Cor de fundo do botão de login
  static const loginButtonText = Colors.black; // Cor do texto do botão de login

  // Cores do Sistema
  static const backgroundColor = ivoryDust;
  static const surfaceColor = Colors.white;
  static const textColor = legacyBlack;
  static const textLightColor = graniteMist;

  // Cores de Status
  static const successColor = Color(0xFF34C759);
  static const warningColor = Color(0xFFFF9500);
  static const errorColor = Color(0xFFFF3B30);
  static const infoColor = secondaryColor;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onBackground: textColor,
        onSurface: textColor,
        error: errorColor,
        onError: Colors.white,
      ),

      // Configuração geral
      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
        toolbarHeight: 70,
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: graniteMist.withOpacity(0.2)),
        ),
        color: surfaceColor,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(120, 45),
          textStyle: TextStyle(
            fontFamily: 'Switzer',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: TextStyle(
            fontFamily: 'Switzer',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: graniteMist.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: graniteMist.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor),
        ),
        errorStyle: TextStyle(color: errorColor),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontFamily: 'Switzer', color: textLightColor),
        hintStyle: TextStyle(fontFamily: 'Switzer', color: textLightColor),
      ),

      // Texto
      textTheme: TextTheme(
        // Títulos
        headlineLarge: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        // Corpo
        bodyLarge: TextStyle(
          fontFamily: 'Switzer',
          color: textColor,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Switzer',
          color: textLightColor,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
