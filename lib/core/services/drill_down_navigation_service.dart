import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Service for managing hierarchical drill-down navigation
/// Supports: National → State → District → Agency → Project navigation
class DrillDownNavigationService {
  final List<NavigationLevel> _navigationStack = [];
  final ValueNotifier<List<NavigationLevel>> _stackNotifier = ValueNotifier([]);

  /// Get current navigation stack
  List<NavigationLevel> get navigationStack => List.unmodifiable(_navigationStack);

  /// Get stack as a stream for reactive updates
  ValueNotifier<List<NavigationLevel>> get stackNotifier => _stackNotifier;

  /// Navigate to state level
  void drillToState({
    required String stateId,
    required String stateName,
    required LatLng centerLocation,
    double? initialZoom,
  }) {
    _clearStack();
    _pushLevel(NavigationLevel(
      level: NavigationType.state,
      id: stateId,
      name: stateName,
      centerLocation: centerLocation,
      zoomLevel: initialZoom ?? 7.0,
    ));
  }

  /// Navigate to district level
  void drillToDistrict({
    required String districtId,
    required String districtName,
    required String parentStateId,
    required String parentStateName,
    required LatLng centerLocation,
    double? initialZoom,
  }) {
    // Ensure state level exists
    if (_navigationStack.isEmpty || _navigationStack.last.level != NavigationType.state) {
      drillToState(
        stateId: parentStateId,
        stateName: parentStateName,
        centerLocation: centerLocation,
      );
    }

    _pushLevel(NavigationLevel(
      level: NavigationType.district,
      id: districtId,
      name: districtName,
      centerLocation: centerLocation,
      zoomLevel: initialZoom ?? 9.0,
      parentId: parentStateId,
      parentName: parentStateName,
    ));
  }

  /// Navigate to agency level
  void drillToAgency({
    required String agencyId,
    required String agencyName,
    required LatLng location,
    String? districtId,
    String? districtName,
    double? initialZoom,
  }) {
    _pushLevel(NavigationLevel(
      level: NavigationType.agency,
      id: agencyId,
      name: agencyName,
      centerLocation: location,
      zoomLevel: initialZoom ?? 11.0,
      parentId: districtId,
      parentName: districtName,
    ));
  }

  /// Navigate to project level
  void drillToProject({
    required String projectId,
    required String projectName,
    required LatLng location,
    String? agencyId,
    String? agencyName,
    double? initialZoom,
  }) {
    _pushLevel(NavigationLevel(
      level: NavigationType.project,
      id: projectId,
      name: projectName,
      centerLocation: location,
      zoomLevel: initialZoom ?? 13.0,
      parentId: agencyId,
      parentName: agencyName,
    ));
  }

  /// Navigate up one level in the hierarchy
  bool navigateUp() {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      _notifyListeners();
      return true;
    }
    return false;
  }

  /// Navigate to a specific level in the stack
  void navigateToLevel(int index) {
    if (index >= 0 && index < _navigationStack.length) {
      _navigationStack.removeRange(index + 1, _navigationStack.length);
      _notifyListeners();
    }
  }

  /// Navigate back to national view
  void navigateToNational() {
    _clearStack();
  }

  /// Get current navigation level
  NavigationLevel? get currentLevel =>
      _navigationStack.isNotEmpty ? _navigationStack.last : null;

  /// Check if can navigate up
  bool get canNavigateUp => _navigationStack.length > 1;

  /// Get breadcrumb trail
  List<String> get breadcrumbs =>
      _navigationStack.map((level) => level.name).toList();

  /// Get current zoom level
  double get currentZoomLevel => currentLevel?.zoomLevel ?? 5.0;

  /// Get current center location
  LatLng get currentCenterLocation =>
      currentLevel?.centerLocation ?? const LatLng(20.5937, 78.9629); // India center

  /// Private methods
  void _pushLevel(NavigationLevel level) {
    _navigationStack.add(level);
    _notifyListeners();
  }

  void _clearStack() {
    _navigationStack.clear();
    _notifyListeners();
  }

  void _notifyListeners() {
    _stackNotifier.value = List.from(_navigationStack);
  }

  void dispose() {
    _stackNotifier.dispose();
  }
}

/// Navigation level model
class NavigationLevel {
  final NavigationType level;
  final String id;
  final String name;
  final LatLng centerLocation;
  final double zoomLevel;
  final String? parentId;
  final String? parentName;
  final Map<String, dynamic>? metadata;

  NavigationLevel({
    required this.level,
    required this.id,
    required this.name,
    required this.centerLocation,
    required this.zoomLevel,
    this.parentId,
    this.parentName,
    this.metadata,
  });

  @override
  String toString() => '$name (${level.displayName})';
}

/// Navigation type enum
enum NavigationType {
  national,
  state,
  district,
  agency,
  project;

  String get displayName {
    switch (this) {
      case NavigationType.national:
        return 'National';
      case NavigationType.state:
        return 'State';
      case NavigationType.district:
        return 'District';
      case NavigationType.agency:
        return 'Agency';
      case NavigationType.project:
        return 'Project';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationType.national:
        return Icons.public;
      case NavigationType.state:
        return Icons.location_city;
      case NavigationType.district:
        return Icons.map;
      case NavigationType.agency:
        return Icons.business;
      case NavigationType.project:
        return Icons.construction;
    }
  }
}

/// Riverpod provider for navigation service
final drillDownNavigationServiceProvider = Provider<DrillDownNavigationService>((ref) {
  final service = DrillDownNavigationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// State provider for current navigation level
final currentNavigationLevelProvider = StateProvider<NavigationLevel?>((ref) => null);

/// Breadcrumb navigation widget
class BreadcrumbNavigationBar extends ConsumerWidget {
  final DrillDownNavigationService navigationService;
  final Function(int)? onNavigate;

  const BreadcrumbNavigationBar({
    super.key,
    required this.navigationService,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<NavigationLevel>>(
      valueListenable: navigationService.stackNotifier,
      builder: (context, stack, child) {
        if (stack.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.home,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < stack.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        _buildBreadcrumbItem(
                          context,
                          stack[i],
                          i,
                          isLast: i == stack.length - 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (navigationService.canNavigateUp) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 20,
                  tooltip: 'Navigate up',
                  onPressed: () {
                    navigationService.navigateUp();
                    onNavigate?.call(stack.length - 2);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    NavigationLevel level,
    int index, {
    required bool isLast,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isLast
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
        );

    return InkWell(
      onTap: isLast
          ? null
          : () {
              navigationService.navigateToLevel(index);
              onNavigate?.call(index);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              level.level.icon,
              size: 16,
              color: isLast
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(level.name, style: textStyle),
          ],
        ),
      ),
    );
  }
}

/// Mixin for widgets that support drill-down navigation
mixin DrillDownNavigationMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  DrillDownNavigationService get navigationService =>
      ref.read(drillDownNavigationServiceProvider);

  /// Handle state tap - drill down to state view
  void onStateTap(String stateId, String stateName, LatLng location) {
    navigationService.drillToState(
      stateId: stateId,
      stateName: stateName,
      centerLocation: location,
    );
    onNavigationChanged();
  }

  /// Handle district tap - drill down to district view
  void onDistrictTap({
    required String districtId,
    required String districtName,
    required String stateId,
    required String stateName,
    required LatLng location,
  }) {
    navigationService.drillToDistrict(
      districtId: districtId,
      districtName: districtName,
      parentStateId: stateId,
      parentStateName: stateName,
      centerLocation: location,
    );
    onNavigationChanged();
  }

  /// Handle agency tap - drill down to agency view
  void onAgencyTap({
    required String agencyId,
    required String agencyName,
    required LatLng location,
    String? districtId,
    String? districtName,
  }) {
    navigationService.drillToAgency(
      agencyId: agencyId,
      agencyName: agencyName,
      location: location,
      districtId: districtId,
      districtName: districtName,
    );
    onNavigationChanged();
  }

  /// Handle project tap - drill down to project view
  void onProjectTap({
    required String projectId,
    required String projectName,
    required LatLng location,
    String? agencyId,
    String? agencyName,
  }) {
    navigationService.drillToProject(
      projectId: projectId,
      projectName: projectName,
      location: location,
      agencyId: agencyId,
      agencyName: agencyName,
    );
    onNavigationChanged();
  }

  /// Override this to handle navigation changes
  void onNavigationChanged() {
    setState(() {});
  }
}