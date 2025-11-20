import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const _navy = Color(0xFF071633);
  static const _navyLight = Color(0xFF102347);
  static const _gold = Color(0xFFFFC94A);
  static const _errorRed = Color(0xFFE53935);

  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: Colors.grey[100],
      primaryColor: _navy,
      colorScheme: base.colorScheme.copyWith(
        primary: _navy,
        secondary: _gold,
        error: _errorRed,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _navy,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _navy,
        selectedItemColor: _gold,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _gold,
        foregroundColor: _navy,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _navy,
        ),
      ),

      // لازم CardThemeData في Flutter الجديد
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // نستعمل TargetPlatform.values بدل TargetPlatform.web
      pageTransitionsTheme: PageTransitionsTheme(
        builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
          TargetPlatform.values,
          value: (_) => const FadeUpwardsPageTransitionsBuilder(),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: _navy,
      primaryColor: _gold,
      colorScheme: base.colorScheme.copyWith(
        primary: _gold,
        secondary: _gold,
        error: _errorRed,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _navyLight,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: _navyLight,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _navyLight,
        selectedItemColor: _gold,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _gold,
        foregroundColor: _navy,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: _navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _gold,
        ),
      ),

      cardTheme: CardThemeData(
        color: _navyLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      pageTransitionsTheme: PageTransitionsTheme(
        builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
          TargetPlatform.values,
          value: (_) => const FadeUpwardsPageTransitionsBuilder(),
        ),
      ),
    );
  }
}
