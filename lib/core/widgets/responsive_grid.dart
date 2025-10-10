import 'package:flutter/material.dart';
import '../theme/app_design_system.dart';

/// Responsive Grid System for PM-AJAY Platform
/// Implements a 12-column grid with responsive breakpoints
class ResponsiveGrid extends StatelessWidget {
  final List<ResponsiveGridItem> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _getColumns(width);
        
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((item) {
            final itemColumns = _getItemColumns(item, width);
            final itemWidth = (width - (spacing * (columns - 1))) / columns * itemColumns - spacing;
            
            return SizedBox(
              width: itemWidth,
              child: item.child,
            );
          }).toList(),
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width < AppDesignSystem.breakpointMobile) {
      return 4; // Mobile: 4 columns
    } else if (width < AppDesignSystem.breakpointTablet) {
      return 8; // Tablet: 8 columns
    } else {
      return 12; // Desktop: 12 columns
    }
  }

  int _getItemColumns(ResponsiveGridItem item, double width) {
    if (width < AppDesignSystem.breakpointMobile) {
      return item.mobile ?? item.desktop;
    } else if (width < AppDesignSystem.breakpointTablet) {
      return item.tablet ?? item.desktop;
    } else {
      return item.desktop;
    }
  }
}

/// Grid item with responsive column spans
class ResponsiveGridItem {
  final Widget child;
  final int desktop;
  final int? tablet;
  final int? mobile;

  const ResponsiveGridItem({
    required this.child,
    required this.desktop,
    this.tablet,
    this.mobile,
  });
}

/// Responsive Row with automatic wrapping
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppDesignSystem.breakpointMobile) {
          // Stack vertically on mobile
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) => 
              Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: child,
              )
            ).toList(),
          );
        } else {
          // Horizontal row on tablet/desktop
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) => 
              Padding(
                padding: EdgeInsets.only(right: spacing),
                child: child,
              )
            ).toList(),
          );
        }
      },
    );
  }
}

/// Responsive Container with padding based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsivePadding = padding ?? EdgeInsets.all(
          _getResponsivePadding(constraints.maxWidth)
        );
        
        return Padding(
          padding: responsivePadding,
          child: child,
        );
      },
    );
  }

  double _getResponsivePadding(double width) {
    if (width < AppDesignSystem.breakpointMobile) {
      return AppDesignSystem.space16;
    } else if (width < AppDesignSystem.breakpointTablet) {
      return AppDesignSystem.space24;
    } else {
      return AppDesignSystem.space32;
    }
  }
}

/// Responsive Card with adaptive sizing
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final int desktopColumns;
  final int? tabletColumns;
  final int? mobileColumns;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.desktopColumns = 4,
    this.tabletColumns,
    this.mobileColumns,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _getColumns(width);
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(_getCardPadding(width)),
            child: child,
          ),
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width < AppDesignSystem.breakpointMobile) {
      return mobileColumns ?? desktopColumns;
    } else if (width < AppDesignSystem.breakpointTablet) {
      return tabletColumns ?? desktopColumns;
    } else {
      return desktopColumns;
    }
  }

  double _getCardPadding(double width) {
    if (width < AppDesignSystem.breakpointMobile) {
      return AppDesignSystem.space12;
    } else if (width < AppDesignSystem.breakpointTablet) {
      return AppDesignSystem.space16;
    } else {
      return AppDesignSystem.space24;
    }
  }
}