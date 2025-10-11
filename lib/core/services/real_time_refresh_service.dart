import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing periodic data refresh across all dashboards
/// Implements 15-minute refresh intervals with intelligent caching
class RealTimeRefreshService {
  static const Duration refreshInterval = Duration(minutes: 15);
  
  final Map<String, Timer> _activeTimers = {};
  final Map<String, DateTime> _lastRefreshTimes = {};
  final Map<String, StreamController> _refreshControllers = {};

  /// Register a dashboard for periodic refresh
  void registerDashboard(String dashboardId, VoidCallback refreshCallback) {
    // Cancel existing timer if any
    _activeTimers[dashboardId]?.cancel();
    
    // Create new periodic timer
    _activeTimers[dashboardId] = Timer.periodic(refreshInterval, (_) {
      _lastRefreshTimes[dashboardId] = DateTime.now();
      refreshCallback();
    });
    
    // Initial refresh
    _lastRefreshTimes[dashboardId] = DateTime.now();
  }

  /// Unregister a dashboard from periodic refresh
  void unregisterDashboard(String dashboardId) {
    _activeTimers[dashboardId]?.cancel();
    _activeTimers.remove(dashboardId);
    _lastRefreshTimes.remove(dashboardId);
    _refreshControllers[dashboardId]?.close();
    _refreshControllers.remove(dashboardId);
  }

  /// Force refresh for a specific dashboard
  void forceRefresh(String dashboardId) {
    _lastRefreshTimes[dashboardId] = DateTime.now();
    _refreshControllers[dashboardId]?.add(null);
  }

  /// Get last refresh time for a dashboard
  DateTime? getLastRefreshTime(String dashboardId) {
    return _lastRefreshTimes[dashboardId];
  }

  /// Get refresh stream for a dashboard
  Stream<void> getRefreshStream(String dashboardId) {
    if (!_refreshControllers.containsKey(dashboardId)) {
      _refreshControllers[dashboardId] = StreamController.broadcast();
    }
    return _refreshControllers[dashboardId]!.stream;
  }

  /// Check if refresh is needed based on last refresh time
  bool needsRefresh(String dashboardId, {Duration? customInterval}) {
    final lastRefresh = _lastRefreshTimes[dashboardId];
    if (lastRefresh == null) return true;
    
    final interval = customInterval ?? refreshInterval;
    return DateTime.now().difference(lastRefresh) >= interval;
  }

  /// Dispose all timers
  void dispose() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _lastRefreshTimes.clear();
    
    for (var controller in _refreshControllers.values) {
      controller.close();
    }
    _refreshControllers.clear();
  }
}

// Riverpod provider for the refresh service
final realTimeRefreshServiceProvider = Provider<RealTimeRefreshService>((ref) {
  final service = RealTimeRefreshService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Mixin for widgets that need periodic refresh
mixin RefreshableDashboard<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get dashboardId;
  
  void onRefresh();
  
  @override
  void initState() {
    super.initState();
    
    // Register dashboard for periodic refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final refreshService = ref.read(realTimeRefreshServiceProvider);
      refreshService.registerDashboard(dashboardId, onRefresh);
    });
  }
  
  @override
  void dispose() {
    // Unregister dashboard
    final refreshService = ref.read(realTimeRefreshServiceProvider);
    refreshService.unregisterDashboard(dashboardId);
    super.dispose();
  }
  
  /// Manually trigger refresh
  void triggerRefresh() {
    final refreshService = ref.read(realTimeRefreshServiceProvider);
    refreshService.forceRefresh(dashboardId);
    onRefresh();
  }
  
  /// Get last refresh time
  DateTime? getLastRefreshTime() {
    final refreshService = ref.read(realTimeRefreshServiceProvider);
    return refreshService.getLastRefreshTime(dashboardId);
  }
}

/// Provider state notifier for dashboard data with auto-refresh
class DashboardDataNotifier<T> extends StateNotifier<AsyncValue<T>> {
  final String dashboardId;
  final Future<T> Function() dataFetcher;
  final RealTimeRefreshService refreshService;
  Timer? _refreshTimer;

  DashboardDataNotifier({
    required this.dashboardId,
    required this.dataFetcher,
    required this.refreshService,
  }) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    // Initial data load
    refresh();
    
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(RealTimeRefreshService.refreshInterval, (_) {
      refresh();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final data = await dataFetcher();
      state = AsyncValue.data(data);
      refreshService.forceRefresh(dashboardId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Widget to display last refresh time
class RefreshIndicator extends ConsumerWidget {
  final String dashboardId;
  final VoidCallback? onRefresh;

  const RefreshIndicator({
    super.key,
    required this.dashboardId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshService = ref.watch(realTimeRefreshServiceProvider);
    final lastRefresh = refreshService.getLastRefreshTime(dashboardId);

    return StreamBuilder<void>(
      stream: refreshService.getRefreshStream(dashboardId),
      builder: (context, snapshot) {
        final timeSinceRefresh = lastRefresh != null
            ? DateTime.now().difference(lastRefresh)
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatRefreshTime(timeSinceRefresh),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (onRefresh != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onRefresh,
                  child: Icon(
                    Icons.refresh_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatRefreshTime(Duration? duration) {
    if (duration == null) return 'Never refreshed';
    
    if (duration.inSeconds < 60) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inHours}h ago';
    }
  }
}