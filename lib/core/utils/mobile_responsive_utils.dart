import 'package:flutter/material.dart';

/// Utility class for mobile-responsive design
class MobileResponsiveUtils {
  /// Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get appropriate font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.85;
    } else if (isTablet(context)) {
      return baseSize * 0.95;
    } else {
      return baseSize;
    }
  }

  /// Get appropriate grid column count
  static int getGridColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get appropriate card height based on screen
  static double getCardHeight(BuildContext context, double baseHeight) {
    if (isMobile(context)) {
      return baseHeight * 0.8;
    } else {
      return baseHeight;
    }
  }

  /// Get appropriate width percentage for dialogs
  static double getDialogWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.95;
    } else if (isTablet(context)) {
      return MediaQuery.of(context).size.width * 0.8;
    } else {
      return 600;
    }
  }

  /// Responsive horizontal spacing
  static double getHorizontalSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  /// Responsive vertical spacing
  static double getVerticalSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }
}

/// Collapsible section widget for mobile optimization
class CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? icon;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.icon,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: MobileResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          ListTile(
            leading: widget.icon != null ? Icon(widget.icon) : null,
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MobileResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

/// Responsive grid wrapper
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MobileResponsiveUtils.getGridColumnCount(context),
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      children: children,
    );
  }
}

/// Responsive row/column layout
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (MobileResponsiveUtils.isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.map((child) => Expanded(child: child)).toList(),
      );
    }
  }
}

/// Mobile-optimized card
class MobileOptimizedCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final bool collapsible;

  const MobileOptimizedCard({
    super.key,
    required this.child,
    this.title,
    this.padding,
    this.collapsible = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Padding(
      padding: padding ?? MobileResponsiveUtils.getResponsivePadding(context),
      child: child,
    );

    if (collapsible && title != null) {
      return CollapsibleSection(
        title: title!,
        child: cardChild,
      );
    }

    return Card(
      margin: MobileResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MobileResponsiveUtils.getResponsiveFontSize(context, 18),
                ),
              ),
            ),
          cardChild,
        ],
      ),
    );
  }
}

/// Responsive dialog wrapper
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MobileResponsiveUtils.getDialogWidth(context),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MobileResponsiveUtils.getResponsiveFontSize(context, 20),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: MobileResponsiveUtils.getResponsivePadding(context),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}