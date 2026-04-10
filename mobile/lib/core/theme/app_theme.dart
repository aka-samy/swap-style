import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF6C63FF);
  static const _secondaryColor = Color(0xFF03DAC6);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F8FC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F8FC),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F0F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF3B30)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9E9EA7), fontWeight: FontWeight.w400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: Color(0xFFE0E0E6)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: _primaryColor.withAlpha(30),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 65,
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primaryColor, size: 26);
        }
        return const IconThemeData(color: Color(0xFF9E9EA7), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _primaryColor);
        }
        return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF9E9EA7));
      }),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFFE0E0E6)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0F0F5),
      thickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _primaryColor,
      unselectedLabelColor: const Color(0xFF9E9EA7),
      indicatorColor: _primaryColor,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      dividerHeight: 0.5,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF121218),
    ),
    scaffoldBackgroundColor: const Color(0xFF121218),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1E1E2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF3B30)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: Color(0xFF2E2E3A)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF1E1E2A),
      surfaceTintColor: Colors.transparent,
      indicatorColor: _primaryColor.withAlpha(30),
      height: 65,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _primaryColor,
      indicatorColor: _primaryColor,
      dividerHeight: 0.5,
    ),
  );
}
