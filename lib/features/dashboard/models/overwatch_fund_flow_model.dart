import 'package:flutter/material.dart';
import 'overwatch_project_model.dart';

/// Fund flow node type hierarchy
enum FundFlowNodeType {
  centre,
  state,
  agency,
  project,
  milestone,
  expense;

  String get label {
    switch (this) {
      case FundFlowNodeType.centre:
        return 'Centre';
      case FundFlowNodeType.state:
        return 'State';
      case FundFlowNodeType.agency:
        return 'Agency';
      case FundFlowNodeType.project:
        return 'Project';
      case FundFlowNodeType.milestone:
        return 'Milestone';
      case FundFlowNodeType.expense:
        return 'Expense';
    }
  }

  Color get color {
    switch (this) {
      case FundFlowNodeType.centre:
        return const Color(0xFF3B82F6); // Blue
      case FundFlowNodeType.state:
        return const Color(0xFF10B981); // Green
      case FundFlowNodeType.agency:
        return const Color(0xFFF59E0B); // Amber
      case FundFlowNodeType.project:
        return const Color(0xFF8B5CF6); // Purple
      case FundFlowNodeType.milestone:
        return const Color(0xFFEF4444); // Red
      case FundFlowNodeType.expense:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  int get level {
    switch (this) {
      case FundFlowNodeType.centre:
        return 0;
      case FundFlowNodeType.state:
        return 1;
      case FundFlowNodeType.agency:
        return 2;
      case FundFlowNodeType.project:
        return 3;
      case FundFlowNodeType.milestone:
        return 4;
      case FundFlowNodeType.expense:
        return 5;
    }
  }
}

/// Transaction details for fund flow
class TransactionDetails {
  final String transactionId;
  final DateTime date;
  final String bankDetails;
  final String approvalStatus;
  final String? utrNumber;
  final String? pfmsId;

  TransactionDetails({
    required this.transactionId,
    required this.date,
    required this.bankDetails,
    required this.approvalStatus,
    this.utrNumber,
    this.pfmsId,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionId: json['transaction_id'] as String,
      date: DateTime.parse(json['date'] as String),
      bankDetails: json['bank_details'] as String,
      approvalStatus: json['approval_status'] as String,
      utrNumber: json['utr_number'] as String?,
      pfmsId: json['pfms_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'date': date.toIso8601String(),
      'bank_details': bankDetails,
      'approval_status': approvalStatus,
      'utr_number': utrNumber,
      'pfms_id': pfmsId,
    };
  }
}

/// Fund flow node with detailed tracking
class FundFlowNode {
  final String id;
  final String name;
  final FundFlowNodeType type;
  final int level;
  final double amount;
  final ResponsiblePerson? responsiblePerson;
  final TransactionDetails? details;
  final List<String> childNodeIds;
  final String? parentNodeId;
  final Map<String, dynamic> metadata;

  FundFlowNode({
    required this.id,
    required this.name,
    required this.type,
    required this.level,
    required this.amount,
    this.responsiblePerson,
    this.details,
    this.childNodeIds = const [],
    this.parentNodeId,
    this.metadata = const {},
  });

  factory FundFlowNode.fromJson(Map<String, dynamic> json) {
    return FundFlowNode(
      id: json['id'] as String,
      name: json['name'] as String,
      type: FundFlowNodeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => FundFlowNodeType.centre,
      ),
      level: json['level'] as int,
      amount: (json['amount'] as num).toDouble(),
      responsiblePerson: json['responsible_person'] != null
          ? ResponsiblePerson.fromJson(json['responsible_person'] as Map<String, dynamic>)
          : null,
      details: json['details'] != null
          ? TransactionDetails.fromJson(json['details'] as Map<String, dynamic>)
          : null,
      childNodeIds: json['child_node_ids'] != null
          ? List<String>.from(json['child_node_ids'] as List)
          : [],
      parentNodeId: json['parent_node_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'level': level,
      'amount': amount,
      'responsible_person': responsiblePerson?.toJson(),
      'details': details?.toJson(),
      'child_node_ids': childNodeIds,
      'parent_node_id': parentNodeId,
      'metadata': metadata,
    };
  }
}

/// Fund flow link status
enum FlowLinkStatus {
  completed,
  pending,
  delayed,
  flagged;

  String get label {
    switch (this) {
      case FlowLinkStatus.completed:
        return 'Completed';
      case FlowLinkStatus.pending:
        return 'Pending';
      case FlowLinkStatus.delayed:
        return 'Delayed';
      case FlowLinkStatus.flagged:
        return 'Flagged';
    }
  }

  Color get color {
    switch (this) {
      case FlowLinkStatus.completed:
        return const Color(0xFF10B981); // Green
      case FlowLinkStatus.pending:
        return const Color(0xFF3B82F6); // Blue
      case FlowLinkStatus.delayed:
        return const Color(0xFFF59E0B); // Yellow
      case FlowLinkStatus.flagged:
        return const Color(0xFFEF4444); // Red
    }
  }
}

/// PFMS details for fund transfers
class PFMSDetails {
  final String pfmsId;
  final DateTime transferDate;
  final int processingDays;
  final List<String> documents;
  final String? trackingNumber;

  PFMSDetails({
    required this.pfmsId,
    required this.transferDate,
    required this.processingDays,
    required this.documents,
    this.trackingNumber,
  });

  factory PFMSDetails.fromJson(Map<String, dynamic> json) {
    return PFMSDetails(
      pfmsId: json['pfms_id'] as String,
      transferDate: DateTime.parse(json['transfer_date'] as String),
      processingDays: json['processing_days'] as int,
      documents: List<String>.from(json['documents'] as List),
      trackingNumber: json['tracking_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pfms_id': pfmsId,
      'transfer_date': transferDate.toIso8601String(),
      'processing_days': processingDays,
      'documents': documents,
      'tracking_number': trackingNumber,
    };
  }
}

/// Fund flow link between nodes
class FundFlowLink {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final double value;
  final FlowLinkStatus status;
  final PFMSDetails details;
  final Map<String, dynamic> metadata;

  FundFlowLink({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.value,
    required this.status,
    required this.details,
    this.metadata = const {},
  });

  factory FundFlowLink.fromJson(Map<String, dynamic> json) {
    return FundFlowLink(
      id: json['id'] as String,
      sourceNodeId: json['source'] as String,
      targetNodeId: json['target'] as String,
      value: (json['value'] as num).toDouble(),
      status: FlowLinkStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => FlowLinkStatus.pending,
      ),
      details: PFMSDetails.fromJson(json['details'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': sourceNodeId,
      'target': targetNodeId,
      'value': value,
      'status': status.name,
      'details': details.toJson(),
      'metadata': metadata,
    };
  }
}

/// Complete fund flow data structure
class CompleteFundFlowData {
  final List<FundFlowNode> nodes;
  final List<FundFlowLink> links;
  final DateTime timestamp;
  final Map<String, dynamic> analytics;

  CompleteFundFlowData({
    required this.nodes,
    required this.links,
    required this.timestamp,
    this.analytics = const {},
  });

  /// Get nodes by type
  List<FundFlowNode> getNodesByType(FundFlowNodeType type) {
    return nodes.where((node) => node.type == type).toList();
  }

  /// Get nodes by level
  List<FundFlowNode> getNodesByLevel(int level) {
    return nodes.where((node) => node.level == level).toList();
  }

  /// Get node by ID
  FundFlowNode? getNodeById(String id) {
    try {
      return nodes.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get links for a node
  List<FundFlowLink> getLinksForNode(String nodeId) {
    return links.where(
      (link) => link.sourceNodeId == nodeId || link.targetNodeId == nodeId,
    ).toList();
  }

  /// Get outgoing links from a node
  List<FundFlowLink> getOutgoingLinks(String nodeId) {
    return links.where((link) => link.sourceNodeId == nodeId).toList();
  }

  /// Get incoming links to a node
  List<FundFlowLink> getIncomingLinks(String nodeId) {
    return links.where((link) => link.targetNodeId == nodeId).toList();
  }

  /// Calculate total allocated amount
  double get totalAllocated {
    final centreNodes = getNodesByType(FundFlowNodeType.centre);
    return centreNodes.fold(0.0, (sum, node) => sum + node.amount);
  }

  /// Calculate total utilized amount
  double get totalUtilized {
    final expenseNodes = getNodesByType(FundFlowNodeType.expense);
    return expenseNodes.fold(0.0, (sum, node) => sum + node.amount);
  }

  /// Get flagged links
  List<FundFlowLink> get flaggedLinks {
    return links.where((link) => link.status == FlowLinkStatus.flagged).toList();
  }

  /// Get delayed links
  List<FundFlowLink> get delayedLinks {
    return links.where((link) => link.status == FlowLinkStatus.delayed).toList();
  }

  factory CompleteFundFlowData.fromJson(Map<String, dynamic> json) {
    return CompleteFundFlowData(
      nodes: (json['nodes'] as List)
          .map((n) => FundFlowNode.fromJson(n as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List)
          .map((l) => FundFlowLink.fromJson(l as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      analytics: json['analytics'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'links': links.map((l) => l.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'analytics': analytics,
    };
  }
}