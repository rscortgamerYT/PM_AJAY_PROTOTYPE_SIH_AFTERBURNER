import 'package:flutter/material.dart';
import 'dart:async';

/// Utility class for progressive and lazy loading
class LoadingUtils {
  LoadingUtils._();

  /// Debounce duration for search/filter operations
  static const Duration debounceDuration = Duration(milliseconds: 300);
  
  /// Default page size for pagination
  static const int defaultPageSize = 20;
  
  /// Threshold for triggering lazy load (percentage of scroll)
  static const double lazyLoadThreshold = 0.8;
  
  /// Creates a debouncer for search operations
  static Timer? createDebouncer(VoidCallback callback, Duration duration) {
    Timer? timer;
    return Timer(duration, () {
      timer?.cancel();
      callback();
    });
  }
}

/// Progressive loader for calendar data
class CalendarDataLoader<T> {
  final Future<List<T>> Function(DateTime start, DateTime end, int page, int pageSize) loadData;
  final int pageSize;
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<dynamic> _loadedData = [];
  
  CalendarDataLoader({
    required this.loadData,
    this.pageSize = LoadingUtils.defaultPageSize,
  });
  
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  List<dynamic> get data => _loadedData;
  
  /// Load initial data
  Future<List<T>> loadInitial(DateTime start, DateTime end) async {
    _isLoading = true;
    _currentPage = 0;
    _loadedData.clear();
    
    try {
      final results = await loadData(start, end, _currentPage, pageSize);
      _loadedData.addAll(results);
      _hasMore = results.length >= pageSize;
      _currentPage++;
      return results;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Load next page
  Future<List<T>> loadMore(DateTime start, DateTime end) async {
    if (_isLoading || !_hasMore) return [];
    
    _isLoading = true;
    try {
      final results = await loadData(start, end, _currentPage, pageSize);
      _loadedData.addAll(results);
      _hasMore = results.length >= pageSize;
      _currentPage++;
      return results;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Reset loader
  void reset() {
    _isLoading = false;
    _hasMore = true;
    _currentPage = 0;
    _loadedData.clear();
  }
}

/// Progressive loading widget
class ProgressiveLoadingWidget<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) loadData;
  final Widget Function(BuildContext context, List<T> items) builder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final int pageSize;
  final bool autoLoad;

  const ProgressiveLoadingWidget({
    Key? key,
    required this.loadData,
    required this.builder,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.pageSize = LoadingUtils.defaultPageSize,
    this.autoLoad = true,
  }) : super(key: key);

  @override
  State<ProgressiveLoadingWidget<T>> createState() => _ProgressiveLoadingWidgetState<T>();
}

class _ProgressiveLoadingWidgetState<T> extends State<ProgressiveLoadingWidget<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.autoLoad) {
      _loadInitial();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * LoadingUtils.lazyLoadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _items.clear();
    });

    try {
      final results = await widget.loadData(_currentPage, widget.pageSize);
      setState(() {
        _items.addAll(results);
        _hasMore = results.length >= widget.pageSize;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await widget.loadData(_currentPage, widget.pageSize);
      setState(() {
        _items.addAll(results);
        _hasMore = results.length >= widget.pageSize;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ?? 
        Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty && _isLoading) {
      return widget.loadingWidget ?? 
        const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? 
        const Center(child: Text('No items found'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              widget.builder(context, _items),
              if (_isLoading && _items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lazy loading list view
class LazyLoadListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) loadData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingIndicator;
  final Widget? emptyWidget;
  final int pageSize;
  final double loadThreshold;

  const LazyLoadListView({
    Key? key,
    required this.loadData,
    required this.itemBuilder,
    this.loadingIndicator,
    this.emptyWidget,
    this.pageSize = LoadingUtils.defaultPageSize,
    this.loadThreshold = LoadingUtils.lazyLoadThreshold,
  }) : super(key: key);

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  final List<T> _items = [];
  final ScrollController _controller = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    _loadMore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.position.pixels >= 
        _controller.position.maxScrollExtent * widget.loadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.loadData(_currentPage);
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length >= widget.pageSize;
        _currentPage++;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? 
        const Center(child: Text('No items'));
    }

    return ListView.builder(
      controller: _controller,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return widget.loadingIndicator ?? 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}

/// Debounced search field
class DebouncedSearchField extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;
  final Duration debounceDuration;
  final TextEditingController? controller;

  const DebouncedSearchField({
    Key? key,
    required this.onSearch,
    this.hintText,
    this.debounceDuration = LoadingUtils.debounceDuration,
    this.controller,
  }) : super(key: key);

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearch(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
      ),
    );
  }
}

/// Skeleton loader widget
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: _ShimmerEffect(),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Calendar skeleton loader
class CalendarSkeletonLoader extends StatelessWidget {
  const CalendarSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SkeletonLoader(width: double.infinity, height: 60),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 35,
          itemBuilder: (context, index) {
            return const SkeletonLoader(width: 40, height: 40);
          },
        ),
      ],
    );
  }
}