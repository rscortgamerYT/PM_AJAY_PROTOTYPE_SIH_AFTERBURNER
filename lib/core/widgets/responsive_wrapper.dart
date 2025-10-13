import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';

/// A comprehensive responsive wrapper that automatically adapts content for mobile and tablet
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useMaxWidth;
  final ScrollPhysics? scrollPhysics;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.padding,
    this.useMaxWidth = true,
    this.scrollPhysics,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget content = child;
    
    // Apply max width constraint for desktop/tablet
    if (useMaxWidth) {
      content = Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          child: content,
        ),
      );
    }
    
    // Wrap in SingleChildScrollView with responsive padding
    return SingleChildScrollView(
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      child: content,
    );
  }
}

/// Responsive section wrapper with title
class ResponsiveSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<Widget>? actions;
  
  const ResponsiveSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.margin,
    this.actions,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(
        bottom: ResponsiveLayout.getResponsiveSpacing(context) * 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding ?? ResponsiveLayout.getResponsiveHorizontalPadding(context),
            child: Row(
              children: [
                Expanded(
                  child: ResponsiveLayout.responsiveText(
                    title,
                    context: context,
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          child,
        ],
      ),
    );
  }
}

/// Responsive grid for KPI cards and similar content
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
  });
  
  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.valueByDevice(
      context: context,
      mobile: mobileColumns ?? 1,
      mobileWide: mobileColumns ?? 2,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 4,
    );
    
    final aspectRatio = childAspectRatio ?? ResponsiveLayout.getKpiAspectRatio(context);
    
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing ?? ResponsiveLayout.getResponsiveSpacing(context),
      crossAxisSpacing: spacing ?? ResponsiveLayout.getResponsiveSpacing(context),
      childAspectRatio: aspectRatio,
      children: children,
    );
  }
}

/// Responsive list wrapper
class ResponsiveList extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  
  const ResponsiveList({
    super.key,
    required this.children,
    this.spacing,
    this.physics,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(
        height: spacing ?? ResponsiveLayout.getResponsiveSpacing(context),
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive row that becomes column on mobile
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;
  final bool forceColumn;
  
  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing,
    this.forceColumn = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? ResponsiveLayout.getResponsiveSpacing(context);
    final spacedChildren = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: gap, height: gap));
      }
    }
    
    if (forceColumn || ResponsiveLayout.isMobile(context)) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// Responsive card with proper sizing and padding
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.responsiveCard(
      context: context,
      child: child,
      padding: padding,
      margin: margin,
      color: color,
      elevation: elevation,
      onTap: onTap,
    );
  }
}

/// Responsive stat card for KPIs
class ResponsiveStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;
  
  const ResponsiveStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = ResponsiveLayout.getResponsiveIconSize(context) * 1.5;
    
    return ResponsiveCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? theme.colorScheme.primary,
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context)),
          ResponsiveLayout.responsiveText(
            value,
            context: context,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveHeadingSize(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
          ResponsiveLayout.responsiveText(
            title,
            context: context,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveCaptionSize(context),
              color: theme.textTheme.bodySmall?.color,
            ),
            maxLines: 2,
          ),
          if (subtitle != null) ...[
            SizedBox(height: ResponsiveLayout.getResponsiveSpacing(context) / 2),
            ResponsiveLayout.responsiveText(
              subtitle!,
              context: context,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveCaptionSize(context) - 1,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

/// Responsive dialog wrapper
class ResponsiveDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;
  
  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.contentPadding,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.responsiveDialog(
      context: context,
      title: title,
      child: child,
      actions: actions,
      contentPadding: contentPadding,
    );
  }
}