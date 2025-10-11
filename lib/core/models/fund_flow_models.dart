import 'package:flutter/material.dart';

/// Fund flow status enumeration
enum FundFlowStatus {
  pending,
  active,
  completed,
  delayed,
  flagged,
  onHold,
  cancelled,
}

/// Extension to get status properties
extension FundFlowStatusExtension on FundFlowStatus {
  Color get color {
    switch (this) {
      case FundFlowStatus.completed:
        return const Color(0xFF4CAF50);
      case FundFlowStatus.active:
        return const Color(0xFF2196F3);
      case FundFlowStatus.delayed:
        return const Color(0xFFFF9800);
      case FundFlowStatus.flagged:
        return const Color(0xFFF44336);
      case FundFlowStatus.onHold:
        return const Color(0xFF9E9E9E);
      case FundFlowStatus.cancelled:
        return const Color(0xFF616161);
      case FundFlowStatus.pending:
        return const Color(0xFFFFC107);
    }
  }

  IconData get icon {
    switch (this) {
      case FundFlowStatus.completed:
        return Icons.check_circle;
      case FundFlowStatus.active:
        return Icons.play_circle;
      case FundFlowStatus.delayed:
        return Icons.warning;
      case FundFlowStatus.flagged:
        return Icons.flag;
      case FundFlowStatus.onHold:
        return Icons.pause_circle;
      case FundFlowStatus.cancelled:
        return Icons.cancel;
      case FundFlowStatus.pending:
        return Icons.pending;
    }
  }

  String get displayName {
    switch (this) {
      case FundFlowStatus.completed:
        return 'Completed';
      case FundFlowStatus.active:
        return 'Active';
      case FundFlowStatus.delayed:
        return 'Delayed';
      case FundFlowStatus.flagged:
        return 'Flagged';
      case FundFlowStatus.onHold:
        return 'On Hold';
      case FundFlowStatus.cancelled:
        return 'Cancelled';
      case FundFlowStatus.pending:
        return 'Pending';
    }
  }
}

/// Represents a node in the Sankey diagram hierarchy
class FundFlowNode {
  final String id;
  final String name;
  final int level; // 0=Centre, 1=State, 2=Agency, 3=Project, 4=Milestone, 5=Expenditure
  final double amount;
  final double? allocatedAmount;
  final double? utilizedAmount;
  final double? remainingAmount;
  final Color color;
  final DateTime? allocatedDate;
  final DateTime? utilizationStartDate;
  final DateTime? utilizationEndDate;
  final String? responsibleOfficer;
  final String? contact;
  final double? utilizationRate;
  final double? performanceScore;
  final FundFlowStatus status;
  final List<String> evidenceDocuments;
  final Map<String, dynamic>? metadata;

  FundFlowNode({
    required this.id,
    required this.name,
    required this.level,
    required this.amount,
    this.allocatedAmount,
    this.utilizedAmount,
    this.remainingAmount,
    required this.color,
    this.allocatedDate,
    this.utilizationStartDate,
    this.utilizationEndDate,
    this.responsibleOfficer,
    this.contact,
    this.utilizationRate,
    this.performanceScore,
    this.status = FundFlowStatus.active,
    this.evidenceDocuments = const [],
    this.metadata,
  });

  double get utilizationPercentage {
    if (allocatedAmount == null || allocatedAmount == 0) return 0;
    return ((utilizedAmount ?? 0) / allocatedAmount!) * 100;
  }

  bool get isDelayed {
    if (utilizationEndDate == null) return false;
    return DateTime.now().isAfter(utilizationEndDate!) && status != FundFlowStatus.completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'amount': amount,
      'allocatedAmount': allocatedAmount,
      'utilizedAmount': utilizedAmount,
      'remainingAmount': remainingAmount,
      'color': color.value,
      'allocatedDate': allocatedDate?.toIso8601String(),
      'utilizationStartDate': utilizationStartDate?.toIso8601String(),
      'utilizationEndDate': utilizationEndDate?.toIso8601String(),
      'responsibleOfficer': responsibleOfficer,
      'contact': contact,
      'utilizationRate': utilizationRate,
      'performanceScore': performanceScore,
      'status': status.name,
      'evidenceDocuments': evidenceDocuments,
      'metadata': metadata,
    };
  }
}

/// Represents a link between two nodes in the Sankey diagram
class FundFlowLink {
  final String id;
  final String sourceId;
  final String targetId;
  final double value;
  final String? pfmsId;
  final DateTime? transferDate;
  final DateTime? initiationDate;
  final DateTime? completionDate;
  final FundFlowStatus status;
  final int? processingDays;
  final List<String> intermediaryBanks;
  final List<String> evidenceDocuments;
  final String? approvedBy;
  final DateTime? approvalDate;
  final List<AuditLogEntry> auditTrail;
  final String? ucStatus;
  final List<String> flags;
  final String? comments;
  final Map<String, dynamic>? metadata;

  FundFlowLink({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.value,
    this.pfmsId,
    this.transferDate,
    this.initiationDate,
    this.completionDate,
    this.status = FundFlowStatus.active,
    this.processingDays,
    this.intermediaryBanks = const [],
    this.evidenceDocuments = const [],
    this.approvedBy,
    this.approvalDate,
    this.auditTrail = const [],
    this.ucStatus,
    this.flags = const [],
    this.comments,
    this.metadata,
  });

  bool get isDelayed {
    if (processingDays == null) return false;
    return processingDays! > 7; // More than 7 days is considered delayed
  }

  bool get hasFlagsOrIssues => flags.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'targetId': targetId,
      'value': value,
      'pfmsId': pfmsId,
      'transferDate': transferDate?.toIso8601String(),
      'initiationDate': initiationDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'status': status.name,
      'processingDays': processingDays,
      'intermediaryBanks': intermediaryBanks,
      'evidenceDocuments': evidenceDocuments,
      'approvedBy': approvedBy,
      'approvalDate': approvalDate?.toIso8601String(),
      'auditTrail': auditTrail.map((e) => e.toJson()).toList(),
      'ucStatus': ucStatus,
      'flags': flags,
      'comments': comments,
      'metadata': metadata,
    };
  }
}

/// Audit log entry for tracking changes and approvals
class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String performedBy;
  final String? comments;
  final Map<String, dynamic>? changeDetails;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.performedBy,
    this.comments,
    this.changeDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'performedBy': performedBy,
      'comments': comments,
      'changeDetails': changeDetails,
    };
  }
}

/// Expenditure detail for milestone-level breakdown
class ExpenditureDetail {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String vendor;
  final List<String> invoices;
  final List<String> receipts;
  final List<String> photos;
  final List<String> qualityCertificates;
  final String? geoLocation;
  final FundFlowStatus verificationStatus;

  ExpenditureDetail({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.vendor,
    this.invoices = const [],
    this.receipts = const [],
    this.photos = const [],
    this.qualityCertificates = const [],
    this.geoLocation,
    this.verificationStatus = FundFlowStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'vendor': vendor,
      'invoices': invoices,
      'receipts': receipts,
      'photos': photos,
      'qualityCertificates': qualityCertificates,
      'geoLocation': geoLocation,
      'verificationStatus': verificationStatus.name,
    };
  }
}

/// Complete Sankey data structure
class SankeyFlowData {
  final List<FundFlowNode> nodes;
  final List<FundFlowLink> links;
  final Map<String, List<ExpenditureDetail>> expenditures; // nodeId -> expenditures
  final DateTime generatedAt;
  final String? filterCriteria;

  SankeyFlowData({
    required this.nodes,
    required this.links,
    this.expenditures = const {},
    required this.generatedAt,
    this.filterCriteria,
  });

  /// Get child nodes for a given parent node
  List<FundFlowNode> getChildNodes(String parentId) {
    final childIds = links
        .where((link) => link.sourceId == parentId)
        .map((link) => link.targetId)
        .toSet();
    
    return nodes.where((node) => childIds.contains(node.id)).toList();
  }

  /// Get links originating from a node
  List<FundFlowLink> getOutgoingLinks(String nodeId) {
    return links.where((link) => link.sourceId == nodeId).toList();
  }

  /// Get links ending at a node
  List<FundFlowLink> getIncomingLinks(String nodeId) {
    return links.where((link) => link.targetId == nodeId).toList();
  }

  /// Get expenditure details for a node
  List<ExpenditureDetail> getExpenditures(String nodeId) {
    return expenditures[nodeId] ?? [];
  }

  /// Get total allocated amount
  double get totalAllocated {
    return nodes
        .where((node) => node.level == 0)
        .fold(0.0, (sum, node) => sum + node.amount);
  }

  /// Get total utilized amount
  double get totalUtilized {
    return nodes.fold(0.0, (sum, node) => sum + (node.utilizedAmount ?? 0));
  }

  /// Get nodes by level
  List<FundFlowNode> getNodesByLevel(int level) {
    return nodes.where((node) => node.level == level).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'links': links.map((l) => l.toJson()).toList(),
      'expenditures': expenditures.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'generatedAt': generatedAt.toIso8601String(),
      'filterCriteria': filterCriteria,
    };
  }
}

/// Breadcrumb item for navigation
class FundFlowBreadcrumb {
  final String nodeId;
  final String nodeName;
  final int level;

  FundFlowBreadcrumb({
    required this.nodeId,
    required this.nodeName,
    required this.level,
  });
}