import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonPalette {
  static const Color midnight = Color(0xFF050915);
  static const Color midnightSoft = Color(0xFF0B1428);
  static const Color electricBlue = Color(0xFF3A7BD5);
  static const Color cyanPulse = Color(0xFF13D2F2);
  static const Color violetWave = Color(0xFF7a5AF8);
  static const Color hotPink = Color(0xFFFF3CAC);
  static const Color neonLime = Color(0xFFB8FF6A);
  static const Color warningRed = Color(0xFFFF5F6D);
  static const Color successMint = Color(0xFF2AF598);

  static const Color glassOverlay = Color(0x88FFFFFF);
}

class NeonGradients {
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NeonPalette.violetWave, NeonPalette.hotPink, NeonPalette.cyanPulse],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NeonPalette.midnightSoft, NeonPalette.midnight],
  );

  static const LinearGradient glassStrokeGradient = LinearGradient(
    colors: [NeonPalette.cyanPulse, NeonPalette.hotPink],
  );
}

class GlassDecorations {
  static BoxDecoration blurred({double blur = 25}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.white.withOpacity(0.08),
        ],
      ),
      border: Border.all(
        width: 1,
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }
}

ThemeData buildNeonTheme() {
  final textTheme = GoogleFonts.spaceGroteskTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: NeonPalette.electricBlue,
    brightness: Brightness.dark,
    background: NeonPalette.midnight,
    surface: NeonPalette.midnightSoft,
  ).copyWith(
    primary: NeonPalette.cyanPulse,
    secondary: NeonPalette.violetWave,
    tertiary: NeonPalette.successMint,
    error: NeonPalette.warningRed,
    outline: Colors.white.withOpacity(0.4),
    surfaceTint: Colors.white.withOpacity(0.3),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: NeonPalette.midnight,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: NeonPalette.midnightSoft.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NeonPalette.cyanPulse, width: 1.6),
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NeonPalette.hotPink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NeonPalette.violetWave,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: NeonPalette.hotPink,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.18),
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class NeonBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;

  const NeonBackground({super.key, required this.child, this.showGrid = true});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: NeonPalette.midnight),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _NeonGridPainter(showGrid: showGrid),
            ),
          ),
          Positioned(
            top: -120,
            right: -60,
            child: _blurCircle(Colors.pinkAccent),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: _blurCircle(Colors.cyanAccent),
          ),
          child,
        ],
      ),
    );
  }

  Widget _blurCircle(Color color) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), Colors.transparent],
        ),
      ),
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final bool showGrid;

  const _NeonGridPainter({required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    const gridSize = 60.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGridPainter oldDelegate) => false;
}
