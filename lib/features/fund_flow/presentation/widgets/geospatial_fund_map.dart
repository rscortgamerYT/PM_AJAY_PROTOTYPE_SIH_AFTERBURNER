import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/models/fund_transaction_model.dart';
import '../../../../core/models/state_model.dart';
import '../../../../core/models/agency_model.dart';
import 'dart:math' as math;

/// Geospatial Fund Map with choropleth layer, markers, and animated flow arrows
class GeospatialFundMap extends StatefulWidget {
  final List<FundTransaction> transactions;
  final List<StateModel> states;
  final List<AgencyModel> agencies;
  final Function(String entityId)? onEntityClick;
  final Function(FundTransaction)? onTransactionClick;

  const GeospatialFundMap({
    super.key,
    required this.transactions,
    required this.states,
    required this.agencies,
    this.onEntityClick,
    this.onTransactionClick,
  });

  @override
  State<GeospatialFundMap> createState() => _GeospatialFundMapState();
}

class _GeospatialFundMapState extends State<GeospatialFundMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _flowAnimationController;
  DateTime _selectedDate = DateTime.now();
  String _selectedPeriod = 'all'; // all, monthly, quarterly
  String? _hoveredEntityId;
  bool _showFlowArrows = true;
  bool _showChoropleth = true;
  bool _showMarkers = true;

  @override
  void initState() {
    super.initState();
    _flowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _flowAnimationController.dispose();
    super.dispose();
  }

  List<FundTransaction> get _filteredTransactions {
    if (_selectedPeriod == 'all') return widget.transactions;
    
    final now = _selectedDate;
    return widget.transactions.where((tx) {
      if (_selectedPeriod == 'monthly') {
        return tx.transactionDate.year == now.year &&
               tx.transactionDate.month == now.month;
      } else if (_selectedPeriod == 'quarterly') {
        final txQuarter = (tx.transactionDate.month - 1) ~/ 3;
        final nowQuarter = (now.month - 1) ~/ 3;
        return tx.transactionDate.year == now.year && txQuarter == nowQuarter;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildHeader(),
          _buildControls(),
          Expanded(
            child: Stack(
              children: [
                _buildMap(),
                if (_hoveredEntityId != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildEntityInfo(_hoveredEntityId!),
                  ),
              ],
            ),
          ),
          if (_selectedPeriod != 'all') _buildTimeSlider(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geospatial Fund Flow',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Interactive map with choropleth, markers, and flow visualization',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              _buildLegend(),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: () {
                  // TODO: Toggle fullscreen mode
                },
                tooltip: 'Fullscreen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('High Utilization', Colors.green),
        const SizedBox(width: 12),
        _buildLegendItem('Medium Utilization', Colors.orange),
        const SizedBox(width: 12),
        _buildLegendItem('Low Utilization', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All Time'),
            selected: _selectedPeriod == 'all',
            onSelected: (selected) {
              if (selected) setState(() => _selectedPeriod = 'all');
            },
          ),
          ChoiceChip(
            label: const Text('Monthly'),
            selected: _selectedPeriod == 'monthly',
            onSelected: (selected) {
              if (selected) setState(() => _selectedPeriod = 'monthly');
            },
          ),
          ChoiceChip(
            label: const Text('Quarterly'),
            selected: _selectedPeriod == 'quarterly',
            onSelected: (selected) {
              if (selected) setState(() => _selectedPeriod = 'quarterly');
            },
          ),
          const VerticalDivider(),
          FilterChip(
            label: const Text('Choropleth'),
            selected: _showChoropleth,
            onSelected: (selected) {
              setState(() => _showChoropleth = selected);
            },
          ),
          FilterChip(
            label: const Text('Markers'),
            selected: _showMarkers,
            onSelected: (selected) {
              setState(() => _showMarkers = selected);
            },
          ),
          FilterChip(
            label: const Text('Flow Arrows'),
            selected: _showFlowArrows,
            onSelected: (selected) {
              setState(() => _showFlowArrows = selected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(20.5937, 78.9629), // Center of India
        initialZoom: 5,
        minZoom: 4,
        maxZoom: 18,
        onTap: (tapPosition, point) {
          setState(() => _hoveredEntityId = null);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.pmajay.app',
        ),
        if (_showChoropleth) _buildChoroplethLayer(),
        if (_showFlowArrows) _buildFlowArrowsLayer(),
        if (_showMarkers) _buildMarkersLayer(),
      ],
    );
  }

  Widget _buildChoroplethLayer() {
    return PolygonLayer(
      polygons: widget.states.map((state) {
        final utilization = _calculateStateUtilization(state.id);
        final color = _getUtilizationColorForState(utilization);
        
        return Polygon(
          points: _getStateBoundaryPoints(state),
          color: color.withOpacity(0.3),
          borderColor: color,
          borderStrokeWidth: 2,
          isFilled: true,
        );
      }).toList(),
    );
  }

  Widget _buildMarkersLayer() {
    final markers = <Marker>[];

    // Add agency markers
    for (final agency in widget.agencies) {
      final fundsReceived = _calculateAgencyFunds(agency.id);
      final markerSize = _calculateMarkerSizeForAgency(fundsReceived);
      
      markers.add(
        Marker(
          point: agency.location,
          width: markerSize,
          height: markerSize,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredEntityId = agency.id),
            onExit: (_) => setState(() => _hoveredEntityId = null),
            child: GestureDetector(
              onTap: () => widget.onEntityClick?.call(agency.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _hoveredEntityId == agency.id
                        ? Colors.black
                        : Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.business,
                    color: Colors.white,
                    size: markerSize * 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add state capital markers
    for (final state in widget.states) {
      // Skip if no capital location available
      
      markers.add(
        Marker(
          point: state.capitalLocation,
          width: 30,
          height: 30,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredEntityId = state.id),
            onExit: (_) => setState(() => _hoveredEntityId = null),
            child: GestureDetector(
              onTap: () => widget.onEntityClick?.call(state.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _hoveredEntityId == state.id
                        ? Colors.black
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_city,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MarkerLayer(markers: markers);
  }

  Widget _buildFlowArrowsLayer() {
    return AnimatedBuilder(
      animation: _flowAnimationController,
      builder: (context, child) {
        return PolylineLayer(
          polylines: _filteredTransactions
              .where((tx) => tx.location != null)
              .map((tx) => _createFlowArrow(tx))
              .toList(),
        );
      },
    );
  }

  Polyline _createFlowArrow(FundTransaction tx) {
    // Get source and destination points
    final sourceState = widget.states.firstWhere(
      (s) => s.id == tx.fromEntityId,
      orElse: () => widget.states.first,
    );
    final destLocation = tx.location ?? const LatLng(20.5937, 78.9629);
    
    final sourcePoint = sourceState.capitalLocation;
    
    // Create curved path
    final points = _createCurvedPath(sourcePoint, destLocation);
    
    // Calculate arrow width based on amount
    final width = _calculateArrowWidthForTransaction(tx.amount);
    
    // Animate dash pattern
    final animationValue = _flowAnimationController.value;
    
    return Polyline(
      points: points,
      strokeWidth: width,
      color: _getStageColorForTransaction(tx.stage).withOpacity(0.6),
      isDotted: true,
      borderColor: Colors.white,
      borderStrokeWidth: 1,
    );
  }

  List<LatLng> _createCurvedPath(LatLng start, LatLng end) {
    final points = <LatLng>[];
    const segments = 20;
    
    // Calculate control point for curve (perpendicular to midpoint)
    final midLat = (start.latitude + end.latitude) / 2;
    final midLng = (start.longitude + end.longitude) / 2;
    final offsetLat = (end.longitude - start.longitude) * 0.2;
    final offsetLng = -(end.latitude - start.latitude) * 0.2;
    
    final controlPoint = LatLng(midLat + offsetLat, midLng + offsetLng);
    
    // Generate curve points using quadratic bezier
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final lat = math.pow(1 - t, 2) * start.latitude +
          2 * (1 - t) * t * controlPoint.latitude +
          math.pow(t, 2) * end.latitude;
      final lng = math.pow(1 - t, 2) * start.longitude +
          2 * (1 - t) * t * controlPoint.longitude +
          math.pow(t, 2) * end.longitude;
      points.add(LatLng(lat.toDouble(), lng.toDouble()));
    }
    
    return points;
  }

  Widget _buildTimeSlider() {
    final minDate = widget.transactions.isEmpty
        ? DateTime.now().subtract(const Duration(days: 365))
        : widget.transactions
            .map((tx) => tx.transactionDate)
            .reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = DateTime.now();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDateForDisplay(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedPeriod == 'monthly'
                        ? DateTime(_selectedDate.year, _selectedDate.month - 1)
                        : DateTime(_selectedDate.year, _selectedDate.month - 3);
                  });
                },
                tooltip: 'Previous Period',
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedPeriod == 'monthly'
                        ? DateTime(_selectedDate.year, _selectedDate.month + 1)
                        : DateTime(_selectedDate.year, _selectedDate.month + 3);
                  });
                },
                tooltip: 'Next Period',
              ),
            ],
          ),
          Slider(
            value: _selectedDate.millisecondsSinceEpoch.toDouble(),
            min: minDate.millisecondsSinceEpoch.toDouble(),
            max: maxDate.millisecondsSinceEpoch.toDouble(),
            onChanged: (value) {
              setState(() {
                _selectedDate = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntityInfo(String entityId) {
    final agency = widget.agencies.firstWhere(
      (a) => a.id == entityId,
      orElse: () => widget.agencies.first,
    );
    
    final funds = _calculateAgencyFunds(entityId);
    
    return Card(
      elevation: 8,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    agency.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Funds Received', '₹${_formatAmountForDisplay(funds)}'),
            _buildInfoRow('Type', _getAgencyTypeLabel(agency.type)),
            _buildInfoRow('Address', agency.address ?? 'N/A'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Open StreetView
                  },
                  icon: const Icon(Icons.streetview, size: 16),
                  label: const Text('Street View'),
                ),
                TextButton(
                  onPressed: () => widget.onEntityClick?.call(entityId),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  
  List<LatLng> _getStateBoundaryPoints(StateModel state) {
    // Mock boundary points - replace with actual GeoJSON boundaries
    final center = state.capitalLocation;
    return [
      LatLng(center.latitude + 1, center.longitude - 1),
      LatLng(center.latitude + 1, center.longitude + 1),
      LatLng(center.latitude - 1, center.longitude + 1),
      LatLng(center.latitude - 1, center.longitude - 1),
    ];
  }

  double _calculateStateUtilization(String stateId) {
    final allocated = widget.transactions
        .where((tx) => tx.stateId == stateId && tx.stage == FundFlowStage.stateTransfer)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    
    final spent = widget.transactions
        .where((tx) => tx.stateId == stateId && tx.stage == FundFlowStage.projectSpend)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    
    return allocated > 0 ? (spent / allocated) * 100 : 0;
  }

  double _calculateAgencyFunds(String agencyId) {
    return _filteredTransactions
        .where((tx) => tx.agencyId == agencyId)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
  }

  // Helper method to get utilization color for choropleth
  Color _getUtilizationColorForState(double utilization) {
    if (utilization >= 90) return Colors.green.shade700;
    if (utilization >= 70) return Colors.green.shade400;
    if (utilization >= 50) return Colors.yellow.shade700;
    if (utilization >= 30) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  // Helper method to calculate marker size proportional to funds
  double _calculateMarkerSizeForAgency(double amount) {
    // Logarithmic scale for better visual distribution
    return (math.log(amount + 1) * 5).clamp(20.0, 80.0);
  }

  // Helper method to calculate arrow width based on transaction amount
  double _calculateArrowWidthForTransaction(double amount) {
    // Logarithmic scale, clamped between 2 and 12 pixels
    return (math.log(amount + 1) * 0.5).clamp(2.0, 12.0);
  }

  // Helper method to get color for fund flow stage
  Color _getStageColorForTransaction(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Colors.blue;
      case FundFlowStage.stateTransfer:
        return Colors.green;
      case FundFlowStage.agencyDisbursement:
        return Colors.orange;
      case FundFlowStage.projectSpend:
        return Colors.purple;
      case FundFlowStage.beneficiaryPayment:
        return Colors.teal;
    }
  }

  // Helper method to format amount for display
  String _formatAmountForDisplay(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }

  // Helper method to format date for display
  String _formatDateForDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get agency type label
  String _getAgencyTypeLabel(AgencyType type) {
    switch (type) {
      case AgencyType.implementingAgency:
        return 'Implementing Agency';
      case AgencyType.nodalAgency:
        return 'Nodal Agency';
      case AgencyType.technicalAgency:
        return 'Technical Agency';
      case AgencyType.monitoringAgency:
        return 'Monitoring Agency';
    }
  }
}

  Color _getUtilizationColor(double percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getStageColor(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Colors.blue;
      case FundFlowStage.stateTransfer:
        return Colors.green;
      case FundFlowStage.agencyDisbursement:
        return Colors.orange;
      case FundFlowStage.projectSpend:
        return Colors.purple;
      case FundFlowStage.beneficiaryPayment:
        return Colors.teal;
    }
  }

  double _calculateMarkerSize(double amount) {
    // Scale marker size between 20 and 80 pixels
    return (math.log(amount + 1) * 5).clamp(20.0, 80.0);
  }

  double _calculateArrowWidth(double amount) {
    // Scale arrow width between 2 and 8 pixels
    return (math.log(amount + 1) * 0.5).clamp(2.0, 8.0);
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }