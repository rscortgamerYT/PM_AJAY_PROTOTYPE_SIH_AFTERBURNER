import 'package:flutter/material.dart';

/// Milestone status enum
enum MilestoneStatus {
  notStarted('Not Started', Colors.grey),
  inProgress('In Progress', Colors.blue),
  completed('Completed', Colors.green),
  delayed('Delayed', Colors.orange),
  blocked('Blocked', Colors.red);

  final String label;
  final Color color;
  const MilestoneStatus(this.label, this.color);

  static MilestoneStatus fromString(String value) {
    return MilestoneStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MilestoneStatus.notStarted,
    );
  }
}

/// Milestone claim status enum
enum MilestoneClaimStatus {
  notClaimed('Not Claimed', Colors.grey),
  claimed('Claimed', Colors.blue),
  underReview('Under Review', Colors.orange),
  approved('Approved', Colors.green),
  rejected('Rejected', Colors.red);

  final String label;
  final Color color;
  const MilestoneClaimStatus(this.label, this.color);

  static MilestoneClaimStatus fromString(String value) {
    return MilestoneClaimStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MilestoneClaimStatus.notClaimed,
    );
  }
}

/// Project milestone model
class ProjectMilestone {
  final String id;
  final String projectId;
  final String milestoneNumber;
  final String name;
  final String description;
  final double targetAmount;
  final double claimedAmount;
  final double approvedAmount;
  final MilestoneStatus status;
  final MilestoneClaimStatus claimStatus;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? completionDate;
  final DateTime? claimSubmittedDate;
  final int sequenceOrder;
  final List<String> dependencies; // IDs of milestones that must be completed first
  final Map<String, dynamic> deliverables;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.milestoneNumber,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.claimedAmount = 0.0,
    this.approvedAmount = 0.0,
    this.status = MilestoneStatus.notStarted,
    this.claimStatus = MilestoneClaimStatus.notClaimed,
    this.startDate,
    this.targetDate,
    this.completionDate,
    this.claimSubmittedDate,
    required this.sequenceOrder,
    this.dependencies = const [],
    this.deliverables = const {},
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      milestoneNumber: json['milestone_number'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      claimedAmount: (json['claimed_amount'] as num?)?.toDouble() ?? 0.0,
      approvedAmount: (json['approved_amount'] as num?)?.toDouble() ?? 0.0,
      status: MilestoneStatus.fromString(json['status'] as String),
      claimStatus: MilestoneClaimStatus.fromString(json['claim_status'] as String),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date'] as String) : null,
      completionDate: json['completion_date'] != null ? DateTime.parse(json['completion_date'] as String) : null,
      claimSubmittedDate: json['claim_submitted_date'] != null ? DateTime.parse(json['claim_submitted_date'] as String) : null,
      sequenceOrder: json['sequence_order'] as int,
      dependencies: List<String>.from(json['dependencies'] ?? []),
      deliverables: json['deliverables'] as Map<String, dynamic>? ?? {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'milestone_number': milestoneNumber,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'claimed_amount': claimedAmount,
      'approved_amount': approvedAmount,
      'status': status.name,
      'claim_status': claimStatus.name,
      'start_date': startDate?.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'claim_submitted_date': claimSubmittedDate?.toIso8601String(),
      'sequence_order': sequenceOrder,
      'dependencies': dependencies,
      'deliverables': deliverables,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProjectMilestone copyWith({
    String? id,
    String? projectId,
    String? milestoneNumber,
    String? name,
    String? description,
    double? targetAmount,
    double? claimedAmount,
    double? approvedAmount,
    MilestoneStatus? status,
    MilestoneClaimStatus? claimStatus,
    DateTime? startDate,
    DateTime? targetDate,
    DateTime? completionDate,
    DateTime? claimSubmittedDate,
    int? sequenceOrder,
    List<String>? dependencies,
    Map<String, dynamic>? deliverables,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      milestoneNumber: milestoneNumber ?? this.milestoneNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      claimedAmount: claimedAmount ?? this.claimedAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      status: status ?? this.status,
      claimStatus: claimStatus ?? this.claimStatus,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      completionDate: completionDate ?? this.completionDate,
      claimSubmittedDate: claimSubmittedDate ?? this.claimSubmittedDate,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      dependencies: dependencies ?? this.dependencies,
      deliverables: deliverables ?? this.deliverables,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status == MilestoneStatus.completed;
  bool get isClaimed => claimStatus != MilestoneClaimStatus.notClaimed;
  bool get canBeClaimed => isCompleted && claimStatus == MilestoneClaimStatus.notClaimed;
  bool get isApproved => claimStatus == MilestoneClaimStatus.approved;
  
  double get completionPercentage {
    if (isCompleted) return 100.0;
    if (status == MilestoneStatus.inProgress) return 50.0;
    return 0.0;
  }
}