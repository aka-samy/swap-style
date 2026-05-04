import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF00FFC2); // Electric Cyan
  static const _secondaryColor = Color(0xFF7B2CBF); // Vivid Purple
  static const _accentColor = Color(0xFFFF007F); // Neon Magenta
  
  static final _baseTextTheme = GoogleFonts.outfitTextTheme();
  static final _baseDarkTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: _baseTextTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFF3F4F6),
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F6F9),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF111827),
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF111827)),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: _primaryColor, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFFF3366), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      hintStyle: GoogleFonts.outfit(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        shadowColor: _primaryColor.withOpacity(0.4),
        backgroundColor: const Color(0xFF111827), // Dark button in light mode for modern feel
        foregroundColor: _primaryColor,
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.black,
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: Color(0xFF111827), width: 2),
        foregroundColor: const Color(0xFF111827),
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        foregroundColor: _secondaryColor,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      indicatorColor: _primaryColor.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 75,
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF111827), size: 28);
        }
        return const IconThemeData(color: Color(0xFF9CA3AF), size: 26);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF111827));
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF));
      }),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      showDragHandle: true,
      dragHandleColor: Color(0xFFD1D5DB),
      elevation: 20,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF111827),
      contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
      elevation: 10,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xFF111827),
      unselectedLabelColor: const Color(0xFF9CA3AF),
      indicatorColor: _primaryColor,
      labelStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      dividerHeight: 1,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: _baseDarkTextTheme,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF090A0F), // Very deep space
      surfaceContainerHighest: const Color(0xFF151822),
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF090A0F),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 5,
      shadowColor: Colors.black,
      backgroundColor: const Color(0xFF090A0F),
      surfaceTintColor: const Color(0xFF090A0F),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.5),
      color: const Color(0xFF151822),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      surfaceTintColor: const Color(0xFF151822),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF151822),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF2A2F42), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: _primaryColor, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFFF3366), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      hintStyle: GoogleFonts.outfit(color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        shadowColor: _primaryColor.withOpacity(0.3),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.black,
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF2A2F42),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        side: const BorderSide(color: Color(0xFF2A2F42), width: 2),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        foregroundColor: _primaryColor,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF090A0F),
      surfaceTintColor: const Color(0xFF090A0F),
      indicatorColor: _primaryColor.withOpacity(0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 75,
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _primaryColor, size: 28);
        }
        return const IconThemeData(color: Color(0xFF6B7280), size: 26);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: _primaryColor);
        }
        return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280));
      }),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF151822),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      showDragHandle: true,
      dragHandleColor: Color(0xFF374151),
      elevation: 20,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: BorderSide.none,
      backgroundColor: const Color(0xFF1F2433),
      labelStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _primaryColor,
      contentTextStyle: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700),
      elevation: 10,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2F42),
      thickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _primaryColor,
      unselectedLabelColor: const Color(0xFF6B7280),
      indicatorColor: _primaryColor,
      labelStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
      dividerHeight: 1,
    ),
  );
}

