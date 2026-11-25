import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BillTracker Design System — Flat design / minimalism
///
/// Monochrome surfaces, one quiet green accent, hairline borders and a single
/// sans-serif family. No shadows, no gradients, no decoration: hierarchy comes
/// from type scale, spacing and contrast.
class AppTheme {
  AppTheme._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const _accentLight = Color(0xFF1A6B4A);
  static const _accentDark = Color(0xFF6FCF97);

  // ── Neutral palette (light) ───────────────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF5F5F6);
  static const line = Color(0xFFE9E9EC);
  static const ink = Color(0xFF111113);
  static const muted = Color(0xFF6E6E76);

  // ── Neutral palette (dark) ────────────────────────────────────────────────
  static const _darkBackground = Color(0xFF0B0B0C);
  static const _darkSurfaceAlt = Color(0xFF1C1C1F);
  static const _darkLine = Color(0xFF2A2A2E);
  static const _darkInk = Color(0xFFF4F4F5);
  static const _darkMuted = Color(0xFF9A9AA2);

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => _buildFlat(brightness: Brightness.light);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => _buildFlat(brightness: Brightness.dark);

  static ThemeData _buildFlat({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? _darkBackground : AppTheme.background;
    final surfaceAlt = isDark ? _darkSurfaceAlt : AppTheme.surfaceAlt;
    final line = isDark ? _darkLine : AppTheme.line;
    final ink = isDark ? _darkInk : AppTheme.ink;
    final muted = isDark ? _darkMuted : AppTheme.muted;
    final accent = isDark ? _accentDark : _accentLight;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: ink,
      brightness: brightness,
    ).copyWith(
      surface: background,
      onSurface: ink,
      surfaceTint: Colors.transparent,
      onSurfaceVariant: muted,
      outline: line,
      outlineVariant: line,
      primary: ink,
      onPrimary: background,
      primaryContainer: surfaceAlt,
      onPrimaryContainer: ink,
      secondary: accent,
      onSecondary: isDark ? const Color(0xFF06210F) : Colors.white,
      secondaryContainer: surfaceAlt,
      onSecondaryContainer: ink,
      tertiary: accent,
      tertiaryContainer: surfaceAlt,
      onTertiaryContainer: ink,
      surfaceContainerHighest: surfaceAlt,
      surfaceContainerHigh: surfaceAlt,
      surfaceContainer: surfaceAlt,
      surfaceContainerLow: background,
      surfaceContainerLowest: background,
    );

    final textTheme = _flatTextTheme(ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: line,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: ink, size: 22),
      disabledColor: muted.withValues(alpha: 0.5),
      unselectedWidgetColor: muted,
      highlightColor: ink.withValues(alpha: 0.04),
      splashColor: ink.withValues(alpha: 0.06),
      visualDensity: VisualDensity.standard,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ink,
        selectionColor: ink.withValues(alpha: 0.15),
        selectionHandleColor: ink,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        titleSpacing: 20,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        shape: Border(bottom: BorderSide(color: line)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: ink,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: line),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: muted),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: muted),
        helperStyle: GoogleFonts.inter(fontSize: 12, color: muted),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),

      // ── Buttons ────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ink,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: ink,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          side: BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Navigation ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: surfaceAlt,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? ink : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? ink : muted, size: 22);
        }),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: background),
        actionTextColor: background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: line),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: ink,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          height: 1.45,
          color: muted,
        ),
      ),

      // ── BottomSheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: background,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Popup menu ─────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: line),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, color: ink),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: ink,
        foregroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Misc ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: line,
        thickness: 1,
        space: 16,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: ink),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: ink,
      ),

      // ── Page Transitions ───────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _flatTextTheme(Color ink) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -1,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.6,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    return textTheme.apply(bodyColor: ink, displayColor: ink);
  }
}

/// App-specific color constants (not from Material 3 scheme)
class AppColors {
  AppColors._();

  // Category colors
  static const foodDrinks = Color(0xFFFF6B35);
  static const transport = Color(0xFF2196F3);
  static const shopping = Color(0xFF9C27B0);
  static const entertainment = Color(0xFFE91E63);
  static const health = Color(0xFF4CAF50);
  static const education = Color(0xFF00BCD4);
  static const bills = Color(0xFFFF9800);
  static const work = Color(0xFF607D8B);
  static const travel = Color(0xFF009688);
  static const other = Color(0xFF9E9E9E);

  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFF44336);

  // Budget progress colors
  static const budgetSafe = Color(0xFF4CAF50);
  static const budgetWarning = Color(0xFFFF9800);
  static const budgetExceeded = Color(0xFFF44336);
}

/// Spacing constants
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Border radius constants
class AppRadius {
  AppRadius._();
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);
  static const full = Radius.circular(999);

  static const borderSm = BorderRadius.all(sm);
  static const borderMd = BorderRadius.all(md);
  static const borderLg = BorderRadius.all(lg);
  static const borderXl = BorderRadius.all(xl);
  static const borderFull = BorderRadius.all(full);
}
