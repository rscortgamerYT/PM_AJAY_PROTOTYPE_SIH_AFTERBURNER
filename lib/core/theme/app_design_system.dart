import 'package:flutter/material.dart';

/// Comprehensive Design System for PM-AJAY Platform
/// Implements visual standards with consistent colors, typography, spacing, and animations
class AppDesignSystem {
  AppDesignSystem._();
  
  // ==================== COLOR PALETTE ====================
  
  /// Primary Colors - Deep Indigo & Vibrant Teal
  static const Color deepIndigo = Color(0xFF3F51B5);
  static const Color deepIndigoDark = Color(0xFF303F9F);
  static const Color deepIndigoLight = Color(0xFF5C6BC0);
  
  static const Color vibrantTeal = Color(0xFF00BCD4);
  static const Color vibrantTealDark = Color(0xFF0097A7);
  static const Color vibrantTealLight = Color(0xFF4DD0E1);
  
  /// Accent Colors - Amber & Coral
  static const Color amber = Color(0xFFFFC107);
  static const Color amberDark = Color(0xFFFFA000);
  static const Color amberLight = Color(0xFFFFD54F);
  
  static const Color coral = Color(0xFFFF7043);
  static const Color coralDark = Color(0xFFE64A19);
  static const Color coralLight = Color(0xFFFF8A65);
  
  /// Neutral Colors with High Contrast
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral50 = Color(0x00fafafa);
  
  /// Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  /// Extended Color Palette
  static const Color sunsetOrange = Color(0xFFFF6B35);
  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color royalPurple = Color(0xFF7209B7);
  static const Color skyBlue = Color(0xFF4CC9F0);
  
  // ==================== TYPOGRAPHY ====================
  
  /// Display Styles - Large headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  /// Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );
  
  /// Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  /// Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
  
  /// Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Google Sans',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
  
  // ==================== SPACING ====================
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  
  // Spacing Aliases
  static const double spacingSmall = space8;
  static const double spacingMedium = space16;
  static const double spacingLarge = space24;
  static const double spacingXLarge = space32;
  
  // ==================== ELEVATION & SHADOWS ====================
  
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // ==================== BORDER RADIUS ====================
  
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusCircular = BorderRadius.all(Radius.circular(9999));
  
  // ==================== ANIMATIONS ====================
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveBounce = Curves.bounceOut;
  
  // ==================== ICON SIZES ====================
  
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  // ==================== RESPONSIVE BREAKPOINTS ====================
  
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 960;
  static const double breakpointDesktop = 1280;
  static const double breakpointWide = 1920;
  
  // ==================== HELPER METHODS ====================
  
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) {
      return const EdgeInsets.all(space16);
    } else if (width < breakpointTablet) {
      return const EdgeInsets.all(space24);
    }
    return const EdgeInsets.all(space32);
  }
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
}