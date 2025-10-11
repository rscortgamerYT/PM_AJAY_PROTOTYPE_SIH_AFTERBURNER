import 'package:flutter/material.dart';

/// Fund flow hierarchy levels
enum FundFlowLevel {
  centre,      // Level 1: Central government
  state,       // Level 2: State government
  district,    // Level 2: District level
  agency,      // Level 2: Implementation agency
  project,     // Level 3: Specific project
  component,   // Level 3: Project component
  milestone,   // Level 4: Project milestone
  category,    // Level 4: Expense category
  lineItem,    // Level 5: Specific line item
  beneficiary, // Level 5: End beneficiary
}

extension FundFlowLevelExtension on FundFlowLevel {
  String get label {
    switch (this) {
      case FundFlowLevel.centre:
        return 'Centre';
      case FundFlowLevel.state:
        return 'State';
      case FundFlowLevel.district:
        return 'District';
      case FundFlowLevel.agency:
        return 'Agency';
      case FundFlowLevel.project:
        return 'Project';
      case FundFlowLevel.component:
        return 'Component';
      case FundFlowLevel.milestone:
        return 'Milestone';
      case FundFlowLevel.category:
        return 'Category';
      case FundFlowLevel.lineItem:
        return 'Line Item';
      case FundFlowLevel.beneficiary:
        return 'Beneficiary';
    }
  }

  int get hierarchyOrder {
    switch (this) {
      case FundFlowLevel.centre:
        return 1;
      case FundFlowLevel.state:
      case FundFlowLevel.district:
      case FundFlowLevel.agency:
        return 2;
      case FundFlowLevel.project:
      case FundFlowLevel.component:
        return 3;
      case FundFlowLevel.milestone:
      case FundFlowLevel.category:
        return 4;
      case FundFlowLevel.lineItem:
      case FundFlowLevel.beneficiary:
        return 5;
    }
  }
}

/// Flow health status
enum FlowHealthStatus {
  healthy,
  warning,
  critical,
  blocked,
}

extension FlowHealthStatusExtension on FlowHealthStatus {
  Color get color {
    switch (this) {
      case FlowHealthStatus.healthy:
        return const Color(0xFF10B981); // Green
      case FlowHealthStatus.warning:
        return const Color(0xFFF59E0B); // Amber
      case FlowHealthStatus.critical:
        return const Color(0xFFEF4444); // Red
      case FlowHealthStatus.blocked:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get label {
    switch (this) {
      case FlowHealthStatus.healthy:
        return 'Healthy';
      case FlowHealthStatus.warning:
        return 'Warning';
      case FlowHealthStatus.critical:
        return 'Critical';
      case FlowHealthStatus.blocked:
        return 'Blocked';
    }
  }

  IconData get icon {
    switch (this) {
      case FlowHealthStatus.healthy:
        return Icons.check_circle;
      case FlowHealthStatus.warning:
        return Icons.warning;
      case FlowHealthStatus.critical:
        return Icons.error;
      case FlowHealthStatus.blocked:
        return Icons.block;
    }
  }
}

/// Enhanced fund flow node with rich metadata
class EnhancedFundFlowNode {
  final String id;
  final String name;
  final FundFlowLevel level;
  final double allocatedAmount;
  final double utilizedAmount;
  final double inTransitAmount;
  final FlowHealthStatus healthStatus;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;
  final List<String> childNodeIds;
  final String? parentNodeId;
  
  // Analytics
  final double utilizationRate;
  final int delayDays;
  final double riskScore;
  final List<String> flags;

  EnhancedFundFlowNode({
    required this.id,
    required this.name,
    required this.level,
    required this.allocatedAmount,
    required this.utilizedAmount,
    required this.inTransitAmount,
    required this.healthStatus,
    required this.lastUpdated,
    this.metadata = const {},
    this.childNodeIds = const [],
    this.parentNodeId,
    required this.utilizationRate,
    this.delayDays = 0,
    this.riskScore = 0.0,
    this.flags = const [],
  });

  double get remainingAmount => allocatedAmount - utilizedAmount - inTransitAmount;
  
  bool get hasIssues => flags.isNotEmpty || riskScore > 5.0 || delayDays > 7;
  
  Color get statusColor => healthStatus.color;

  EnhancedFundFlowNode copyWith({
    String? id,
    String? name,
    FundFlowLevel? level,
    double? allocatedAmount,
    double? utilizedAmount,
    double? inTransitAmount,
    FlowHealthStatus? healthStatus,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
    List<String>? childNodeIds,
    String? parentNodeId,
    double? utilizationRate,
    int? delayDays,
    double? riskScore,
    List<String>? flags,
  }) {
    return EnhancedFundFlowNode(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      utilizedAmount: utilizedAmount ?? this.utilizedAmount,
      inTransitAmount: inTransitAmount ?? this.inTransitAmount,
      healthStatus: healthStatus ?? this.healthStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
      childNodeIds: childNodeIds ?? this.childNodeIds,
      parentNodeId: parentNodeId ?? this.parentNodeId,
      utilizationRate: utilizationRate ?? this.utilizationRate,
      delayDays: delayDays ?? this.delayDays,
      riskScore: riskScore ?? this.riskScore,
      flags: flags ?? this.flags,
    );
  }
}

/// Enhanced fund flow link with analytics
class EnhancedFundFlowLink {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final double amount;
  final DateTime transferDate;
  final DateTime? completionDate;
  final FlowHealthStatus status;
  final double velocity; // Amount per day
  final int transitDays;
  final Map<String, dynamic> metadata;
  
  // Anomaly detection
  final bool isAnomaly;
  final List<String> anomalyReasons;
  final double confidenceScore;

  EnhancedFundFlowLink({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.amount,
    required this.transferDate,
    this.completionDate,
    required this.status,
    required this.velocity,
    this.transitDays = 0,
    this.metadata = const {},
    this.isAnomaly = false,
    this.anomalyReasons = const [],
    this.confidenceScore = 1.0,
  });

  bool get isDelayed => transitDays > 7;
  bool get isComplete => completionDate != null;
  
  Color get statusColor => status.color;

  EnhancedFundFlowLink copyWith({
    String? id,
    String? sourceNodeId,
    String? targetNodeId,
    double? amount,
    DateTime? transferDate,
    DateTime? completionDate,
    FlowHealthStatus? status,
    double? velocity,
    int? transitDays,
    Map<String, dynamic>? metadata,
    bool? isAnomaly,
    List<String>? anomalyReasons,
    double? confidenceScore,
  }) {
    return EnhancedFundFlowLink(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      amount: amount ?? this.amount,
      transferDate: transferDate ?? this.transferDate,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      velocity: velocity ?? this.velocity,
      transitDays: transitDays ?? this.transitDays,
      metadata: metadata ?? this.metadata,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      anomalyReasons: anomalyReasons ?? this.anomalyReasons,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }
}

/// Detected bottleneck in fund flow
class Bottleneck {
  final String id;
  final String nodeId;
  final String nodeName;
  final BottleneckType type;
  final int delayDays;
  final double impactAmount;
  final List<String> affectedProjects;
  final String rootCause;
  final List<String> recommendations;
  final DateTime detectedAt;

  Bottleneck({
    required this.id,
    required this.nodeId,
    required this.nodeName,
    required this.type,
    required this.delayDays,
    required this.impactAmount,
    required this.affectedProjects,
    required this.rootCause,
    required this.recommendations,
    required this.detectedAt,
  });
}

enum BottleneckType {
  processingDelay,
  documentationIssue,
  approvalPending,
  technicalError,
  complianceIssue,
}

/// Detected anomaly in fund flow
class FlowAnomaly {
  final String id;
  final AnomalyType type;
  final double severityScore;
  final String description;
  final List<String> affectedEntities;
  final Map<String, dynamic> evidence;
  final DateTime detectedAt;
  final bool isInvestigated;

  FlowAnomaly({
    required this.id,
    required this.type,
    required this.severityScore,
    required this.description,
    required this.affectedEntities,
    required this.evidence,
    required this.detectedAt,
    this.isInvestigated = false,
  });
}

enum AnomalyType {
  statisticalOutlier,
  unusualPattern,
  possibleLeakage,
  fraudIndicator,
  duplicateTransaction,
  velocityAnomaly,
}

/// Flow analytics data
class FlowAnalytics {
  final List<Bottleneck> detectedBottlenecks;
  final List<FlowAnomaly> leakageAlerts;
  final double averageVelocity;
  final Map<String, double> slaCompliance;
  final Map<FundFlowLevel, double> levelUtilization;
  final List<EfficiencyPattern> patterns;

  FlowAnalytics({
    required this.detectedBottlenecks,
    required this.leakageAlerts,
    required this.averageVelocity,
    required this.slaCompliance,
    required this.levelUtilization,
    required this.patterns,
  });
}

/// Identified efficiency pattern
class EfficiencyPattern {
  final String id;
  final PatternType type;
  final String description;
  final double frequency;
  final double impactScore;
  final List<String> recommendations;

  EfficiencyPattern({
    required this.id,
    required this.type,
    required this.description,
    required this.frequency,
    required this.impactScore,
    required this.recommendations,
  });
}

enum PatternType {
  recurringDelay,
  efficientRoute,
  bottleneckPattern,
  seasonalVariation,
}

/// Enhanced Sankey flow data container
class EnhancedSankeyFlowData {
  final List<EnhancedFundFlowNode> nodes;
  final List<EnhancedFundFlowLink> links;
  final FlowAnalytics analytics;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  EnhancedSankeyFlowData({
    required this.nodes,
    required this.links,
    required this.analytics,
    required this.timestamp,
    this.metadata = const {},
  });

  EnhancedFundFlowNode? getNodeById(String id) {
    try {
      return nodes.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedFundFlowLink> getLinksForNode(String nodeId) {
    return links.where((link) => 
      link.sourceNodeId == nodeId || link.targetNodeId == nodeId
    ).toList();
  }

  List<EnhancedFundFlowNode> getChildNodes(String parentId) {
    final parent = getNodeById(parentId);
    if (parent == null) return [];
    
    return nodes.where((node) => 
      parent.childNodeIds.contains(node.id)
    ).toList();
  }

  EnhancedSankeyFlowData copyWith({
    List<EnhancedFundFlowNode>? nodes,
    List<EnhancedFundFlowLink>? links,
    FlowAnalytics? analytics,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedSankeyFlowData(
      nodes: nodes ?? this.nodes,
      links: links ?? this.links,
      analytics: analytics ?? this.analytics,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}