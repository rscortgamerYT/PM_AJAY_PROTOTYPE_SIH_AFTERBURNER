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
  // ==================== MOBILE/TABLET OPTIMIZATION ====================
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 20.0,
      mobileWide: 22.0,
      tablet: 24.0,
      desktop: 24.0,
    );
  }
  
  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 44.0,
      mobileWide: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }
  
  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: const EdgeInsets.all(12),
      mobileWide: const EdgeInsets.all(14),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(20),
    );
  }
  
  /// Get responsive dialog padding
  static EdgeInsets getResponsiveDialogPadding(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: const EdgeInsets.all(16),
      mobileWide: const EdgeInsets.all(20),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(28),
    );
  }
  
  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return valueByDevice(
      context: context,
      mobile: screenWidth * 0.9,
      mobileWide: screenWidth * 0.85,
      tablet: 600,
      desktop: 700,
    );
  }
  
  /// Get responsive dialog max height
  static double getResponsiveDialogMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return valueByDevice(
      context: context,
      mobile: screenHeight * 0.8,
      mobileWide: screenHeight * 0.85,
      tablet: screenHeight * 0.9,
      desktop: screenHeight * 0.9,
    );
  }
  
  /// Get responsive card elevation
  static double getResponsiveCardElevation(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 1.0,
      mobileWide: 2.0,
      tablet: 2.0,
      desktop: 3.0,
    );
  }
  
  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: BorderRadius.circular(8),
      mobileWide: BorderRadius.circular(10),
      tablet: BorderRadius.circular(12),
      desktop: BorderRadius.circular(12),
    );
  }
  
  /// Get responsive font size for headings
  static double getResponsiveHeadingSize(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 18.0,
      mobileWide: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );
  }
  
  /// Get responsive font size for titles
  static double getResponsiveTitleSize(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 16.0,
      mobileWide: 17.0,
      tablet: 18.0,
      desktop: 20.0,
    );
  }
  
  /// Get responsive font size for body text
  static double getResponsiveBodySize(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 14.0,
      mobileWide: 14.5,
      tablet: 15.0,
      desktop: 16.0,
    );
  }
  
  /// Get responsive font size for captions
  static double getResponsiveCaptionSize(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 12.0,
      mobileWide: 12.5,
      tablet: 13.0,
      desktop: 14.0,
    );
  }
  
  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 56.0,
      mobileWide: 60.0,
      tablet: 64.0,
      desktop: 64.0,
    );
  }
  
  /// Get responsive list tile height
  static double getResponsiveListTileHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 56.0,
      mobileWide: 64.0,
      tablet: 72.0,
      desktop: 80.0,
    );
  }
  
  /// Get responsive chip height
  static double getResponsiveChipHeight(BuildContext context) {
    return valueByDevice(
      context: context,
      mobile: 28.0,
      mobileWide: 30.0,
      tablet: 32.0,
      desktop: 32.0,
    );
  }
  
  /// Build responsive container with constraints
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    Color? color,
    BoxDecoration? decoration,
    double? maxWidth,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? getMaxContentWidth(context),
      ),
      padding: padding ?? getResponsiveCardPadding(context),
      decoration: decoration,
      color: decoration == null ? color : null,
      child: child,
    );
  }
  
  /// Build responsive text with automatic overflow handling
  static Widget responsiveText(
    String text, {
    required BuildContext context,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      textScaler: TextScaler.linear(getTextScaleFactor(context)),
    );
  }
  
  /// Build responsive card
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: elevation ?? getResponsiveCardElevation(context),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: getResponsiveBorderRadius(context),
      ),
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? getResponsiveCardPadding(context),
        child: child,
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: getResponsiveBorderRadius(context),
        child: card,
      );
    }
    
    return card;
  }
  
  /// Build responsive dialog
  static Widget responsiveDialog({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    EdgeInsets? contentPadding,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: getResponsiveBorderRadius(context),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: getResponsiveDialogWidth(context),
          maxHeight: getResponsiveDialogMaxHeight(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: getResponsiveDialogPadding(context).copyWith(bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: responsiveText(
                        title,
                        context: context,
                        style: TextStyle(
                          fontSize: getResponsiveHeadingSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: getResponsiveIconSize(context),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ?? getResponsiveDialogPadding(context),
                child: child,
              ),
            ),
            if (actions != null && actions.isNotEmpty)
              Padding(
                padding: getResponsiveDialogPadding(context).copyWith(top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build responsive button
  static Widget responsiveButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = true,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    final buttonHeight = getResponsiveButtonHeight(context);
    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: getResponsiveBorderRadius(context),
            ),
          )
        : OutlinedButton.styleFrom(
            minimumSize: Size(isFullWidth ? double.infinity : 0, buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: getResponsiveBorderRadius(context),
            ),
          );
    
    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: getResponsiveIconSize(context)),
          SizedBox(width: getResponsiveSpacing(context) / 2),
        ],
        responsiveText(
          label,
          context: context,
          style: TextStyle(fontSize: getResponsiveBodySize(context)),
        ),
      ],
    );
    
    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
}