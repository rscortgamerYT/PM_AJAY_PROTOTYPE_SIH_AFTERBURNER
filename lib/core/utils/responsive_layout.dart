import 'package:flutter/material.dart';
import '../theme/app_design_system.dart';

/// Device type enumeration
enum DeviceType {
  mobile,      // < 600px (phones in portrait)
  mobileWide,  // 600-960px (phones in landscape, small tablets)
  tablet,      // 960-1280px (tablets)
  desktop,     // >= 1280px (desktop, large tablets)
}

/// Navigation type enumeration
enum NavigationType {
  bottom,   // Bottom navigation bar (mobile)
  rail,     // Navigation rail (tablet)
  drawer,   // Navigation drawer (desktop)
}

/// Comprehensive responsive layout utilities for PM-AJAY Platform
/// Provides adaptive layouts, spacing, and typography for all screen sizes
class ResponsiveLayout {
  ResponsiveLayout._();

  // ==================== DEVICE TYPE DETECTION ====================

  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppDesignSystem.breakpointMobile) {
      return DeviceType.mobile;
    } else if (width < AppDesignSystem.breakpointTablet) {
      return DeviceType.mobileWide;
    } else if (width < AppDesignSystem.breakpointDesktop) {
      return DeviceType.tablet;
    }
    return DeviceType.desktop;
  }

  /// Check if device is mobile (portrait or landscape)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDesignSystem.breakpointTablet;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDesignSystem.breakpointTablet && 
           width < AppDesignSystem.breakpointDesktop;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDesignSystem.breakpointDesktop;
  }

  // ==================== RESPONSIVE VALUES ====================

  /// Get value based on current screen size
  static T valueByDevice<T>({
    required BuildContext context,
    required T mobile,
    T? mobileWide,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.mobileWide:
        return mobileWide ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobileWide ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobileWide ?? mobile;
    }
  }

  // ==================== RESPONSIVE SPACING ====================

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: const EdgeInsets.all(12),
      mobileWide: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(24),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 12),
      mobileWide: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 24),
      desktop: const EdgeInsets.symmetric(horizontal: 32),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: const EdgeInsets.symmetric(vertical: 8),
      mobileWide: const EdgeInsets.symmetric(vertical: 12),
      tablet: const EdgeInsets.symmetric(vertical: 16),
      desktop: const EdgeInsets.symmetric(vertical: 20),
    );
  }

  /// Get responsive spacing between elements
  static double getResponsiveSpacing(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 8.0,
      mobileWide: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );
  }

  // ==================== RESPONSIVE GRID ====================

  /// Get responsive grid columns for KPI cards
  static int getKpiGridColumns(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 2,
      mobileWide: 2,
      tablet: 4,
      desktop: 4,
    );
  }

  /// Get responsive grid aspect ratio
  static double getKpiAspectRatio(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 1.2,
      mobileWide: 1.3,
      tablet: 1.4,
      desktop: 1.5,
    );
  }

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: double.infinity,
      mobileWide: double.infinity,
      tablet: 900,
      desktop: 1200,
    );
  }

  // ==================== RESPONSIVE TYPOGRAPHY ====================

  /// Get responsive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 0.9,
      mobileWide: 0.95,
      tablet: 1.0,
      desktop: 1.0,
    );
  }

  /// Get responsive headline style
  static TextStyle getResponsiveHeadline(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: AppDesignSystem.headlineSmall,
      mobileWide: AppDesignSystem.headlineSmall,
      tablet: AppDesignSystem.headlineMedium,
      desktop: AppDesignSystem.headlineLarge,
    );
  }

  /// Get responsive title style
  static TextStyle getResponsiveTitle(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: AppDesignSystem.titleSmall,
      mobileWide: AppDesignSystem.titleMedium,
      tablet: AppDesignSystem.titleLarge,
      desktop: AppDesignSystem.titleLarge,
    );
  }

  /// Get responsive body style
  static TextStyle getResponsiveBody(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: AppDesignSystem.bodySmall,
      mobileWide: AppDesignSystem.bodyMedium,
      tablet: AppDesignSystem.bodyLarge,
      desktop: AppDesignSystem.bodyLarge,
    );
  }

  // ==================== RESPONSIVE LAYOUTS ====================

  /// Get responsive navigation type
  static NavigationType getNavigationType(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: NavigationType.bottom,
      mobileWide: NavigationType.bottom,
      tablet: NavigationType.rail,
      desktop: NavigationType.drawer,
    );
  }

  /// Get responsive calendar width
  static double getCalendarWidth(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: MediaQuery.of(context).size.width * 0.9,
      mobileWide: 360,
      tablet: 380,
      desktop: 400,
    );
  }

  /// Get responsive calendar height
  static double getCalendarHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: MediaQuery.of(context).size.height * 0.7,
      mobileWide: 500,
      tablet: 600,
      desktop: 650,
    );
  }

  /// Get responsive map height
  static double getMapHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 300,
      mobileWide: 400,
      tablet: 500,
      desktop: 600,
    );
  }

  /// Get responsive chart height
  static double getChartHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 250,
      mobileWide: 300,
      tablet: 400,
      desktop: 500,
    );
  }

  // ==================== RESPONSIVE WIDGETS ====================

  /// Build responsive layout based on device type
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? mobileWide,
    Widget? tablet,
    Widget? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.mobileWide:
        return mobileWide ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobileWide ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobileWide ?? mobile;
    }
  }

  /// Build responsive grid
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double? spacing,
    double? runSpacing,
  }) {
    final columns = getKpiGridColumns(context);
    final aspectRatio = getKpiAspectRatio(context);
    
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing ?? getResponsiveSpacing(context),
      crossAxisSpacing: spacing ?? getResponsiveSpacing(context),
      childAspectRatio: aspectRatio,
      children: children,
    );
  }

  /// Build responsive row/column based on device
  static Widget responsiveFlex({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double? spacing,
  }) {
    final gap = spacing ?? getResponsiveSpacing(context);
    final spacedChildren = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: gap, height: gap));
      }
    }
    
    if (isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    }
  }

  /// Build responsive wrap
  static Widget responsiveWrap({
    required BuildContext context,
    required List<Widget> children,
    double? spacing,
    double? runSpacing,
  }) {
    return Wrap(
      spacing: spacing ?? getResponsiveSpacing(context),
      runSpacing: runSpacing ?? getResponsiveSpacing(context),
      children: children,
    );
  }

  // ==================== ORIENTATION HELPERS ====================

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // ==================== BOTTOM NAVIGATION HELPERS ====================

  /// Get bottom navigation bar height
  static double getBottomNavHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 56,
      mobileWide: 64,
      tablet: 0, // Use rail instead
      desktop: 0, // Use drawer instead
    );
  }

  /// Check if should show bottom navigation
  static bool shouldShowBottomNav(BuildContext context) {
    return isMobile(context);
  }

  /// Check if should show navigation rail
  static bool shouldShowNavRail(BuildContext context) {
    return isTablet(context);
  }

  /// Check if should show navigation drawer
  static bool shouldShowNavDrawer(BuildContext context) {
    return isDesktop(context);
  }
}