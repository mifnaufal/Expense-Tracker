import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonPalette {
  static const Color night = Color(0xFF050B16);
  static const Color slate = Color(0xFF0F172A);
  static const Color slateSoft = Color(0xFF141D32);
  static const Color card = Color(0xFF1F2A44);
  static const Color mist = Color(0xFF273352);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentLilac = Color(0xFFB4C3FF);
  static const Color accentAmber = Color(0xFFFAC858);
  static const Color successMint = Color(0xFF34D399);
  static const Color warningRed = Color(0xFFF87171);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
}

class NeonGradients {
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x332DD4BF), Color(0x335675F3)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2A44), Color(0xFF18243A)],
  );

  static const LinearGradient glassStrokeGradient = LinearGradient(
    colors: [NeonPalette.accentTeal, NeonPalette.accentBlue],
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
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.06),
        ],
      ),
      border: Border.all(width: 1, color: Colors.white.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 32,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }
}

ThemeData buildNeonTheme() {
  final textTheme = GoogleFonts.interTextTheme().apply(
    bodyColor: NeonPalette.textPrimary,
    displayColor: NeonPalette.textPrimary,
  );

  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: NeonPalette.accentTeal,
        brightness: Brightness.dark,
      ).copyWith(
        surface: NeonPalette.slate,
        primary: NeonPalette.accentTeal,
        secondary: NeonPalette.accentBlue,
        tertiary: NeonPalette.successMint,
        error: NeonPalette.warningRed,
        outline: NeonPalette.textMuted,
        primaryContainer: NeonPalette.card,
        secondaryContainer: NeonPalette.mist,
        surfaceTint: Colors.white.withValues(alpha: 0.08),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: NeonPalette.night,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: NeonPalette.slate.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: NeonPalette.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: NeonPalette.accentTeal, width: 1.6),
      ),
      labelStyle: TextStyle(color: NeonPalette.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NeonPalette.accentTeal,
        foregroundColor: NeonPalette.night,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NeonPalette.accentBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: NeonPalette.accentAmber,
      foregroundColor: NeonPalette.night,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NeonPalette.slateSoft,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: NeonPalette.textPrimary,
      textColor: NeonPalette.textPrimary,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NeonPalette.slate, NeonPalette.night],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _NeonGridPainter(showGrid: showGrid)),
          ),
          Positioned(
            top: -120,
            right: -40,
            child: _blurCircle(NeonPalette.accentBlue),
          ),
          Positioned(
            bottom: -140,
            left: -40,
            child: _blurCircle(NeonPalette.accentTeal),
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
          colors: [color.withValues(alpha: 0.18), Colors.transparent],
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
      ..color = Colors.white.withValues(alpha: 0.015)
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
