import 'package:flutter/material.dart';

/// Request model for State Dashboard Request & Approval System
class RequestModel {
  final String id;
  final String agencyId;
  final String agencyName;
  final String? agencyLogo;
  final RequestType type;
  final RequestPriority priority;
  final RequestStatus status;
  final String title;
  final String description;
  final String rationale;
  final ProjectComponent? component;
  final String? projectName;
  final String? projectId;
  final String? stateId;
  final String? stateName;
  final String? districtId;
  final double? budgetAmount;
  final double? allocatedFund;
  final double? proposedFundAllocation;
  final int? proposedProjects;
  final List<String>? targetDistricts;
  final DateTime? proposedStartDate;
  final DateTime? proposedEndDate;
  final Map<String, dynamic>? kpis;
  final String? submittedBy;
  final List<RequestDocument>? supportingDocuments;
  final String? projectScope;
  final List<String>? objectives;
  final Map<String, dynamic>? taskBreakdown;
  final List<Map<String, dynamic>>? paymentMilestones;
  final String? pfmsTrackingId;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, dynamic>? resourcePlan;
  final List<Map<String, dynamic>>? teamRoles;
  final String? geoFencedSiteLocation;
  final int? estimatedBeneficiaries;
  final String? assignedBy;
  final DateTime? assignedAt;
  final DateTime? slaDeadline;
  final DateTime? updatedAt;
  final DateTime submittedAt;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewerName;
  final String? reviewComments;
  final List<RequestDocument> documents;
  final CapacityAnalysis? capacityAnalysis;
  final List<RequestComment> comments;
  final ESignStatus eSignStatus;
  final String? eSignDocumentUrl;
  final Map<String, dynamic>? metadata;

  const RequestModel({
    required this.id,
    required this.agencyId,
    required this.agencyName,
    this.agencyLogo,
    required this.type,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.rationale,
    this.component,
    this.projectName,
    this.projectId,
    this.stateId,
    this.stateName,
    this.districtId,
    this.budgetAmount,
    this.allocatedFund,
    this.proposedFundAllocation,
    this.proposedProjects,
    this.targetDistricts,
    this.proposedStartDate,
    this.proposedEndDate,
    this.kpis,
    this.submittedBy,
    this.supportingDocuments,
    this.projectScope,
    this.objectives,
    this.taskBreakdown,
    this.paymentMilestones,
    this.pfmsTrackingId,
    this.startDate,
    this.endDate,
    this.resourcePlan,
    this.teamRoles,
    this.geoFencedSiteLocation,
    this.estimatedBeneficiaries,
    this.assignedBy,
    this.assignedAt,
    this.slaDeadline,
    this.updatedAt,
    required this.submittedAt,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewerName,
    this.reviewComments,
    this.documents = const [],
    this.capacityAnalysis,
    this.comments = const [],
    this.eSignStatus = ESignStatus.pending,
    this.eSignDocumentUrl,
    this.metadata,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      agencyId: json['agency_id'] as String,
      agencyName: json['agency_name'] as String,
      agencyLogo: json['agency_logo'] as String?,
      type: RequestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RequestType.projectAssignment,
      ),
      priority: RequestPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => RequestPriority.medium,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      rationale: json['rationale'] as String,
      component: json['component'] != null
          ? ProjectComponent.values.firstWhere((e) => e.name == json['component'])
          : null,
      projectName: json['project_name'] as String?,
      budgetAmount: json['budget_amount'] != null
          ? (json['budget_amount'] as num).toDouble()
          : null,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      reviewComments: json['review_comments'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => RequestDocument.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
      capacityAnalysis: json['capacity_analysis'] != null
          ? CapacityAnalysis.fromJson(json['capacity_analysis'] as Map<String, dynamic>)
          : null,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) => RequestComment.fromJson(comment as Map<String, dynamic>))
              .toList() ??
          [],
      eSignStatus: json['esign_status'] != null
          ? ESignStatus.values.firstWhere((e) => e.name == json['esign_status'])
          : ESignStatus.pending,
      eSignDocumentUrl: json['esign_document_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agency_id': agencyId,
      'agency_name': agencyName,
      'agency_logo': agencyLogo,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'title': title,
      'description': description,
      'rationale': rationale,
      'component': component?.name,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewer_name': reviewerName,
      'review_comments': reviewComments,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'capacity_analysis': capacityAnalysis?.toJson(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'esign_status': eSignStatus.name,
      'esign_document_url': eSignDocumentUrl,
      'metadata': metadata,
    };
  }

  RequestModel copyWith({
    String? id,
    String? agencyId,
    String? agencyName,
    String? agencyLogo,
    RequestType? type,
    RequestPriority? priority,
    RequestStatus? status,
    String? title,
    String? description,
    String? rationale,
    ProjectComponent? component,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewerName,
    String? reviewComments,
    List<RequestDocument>? documents,
    CapacityAnalysis? capacityAnalysis,
    List<RequestComment>? comments,
    ESignStatus? eSignStatus,
    String? eSignDocumentUrl,
    Map<String, dynamic>? metadata,
  }) {
    return RequestModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      agencyName: agencyName ?? this.agencyName,
      agencyLogo: agencyLogo ?? this.agencyLogo,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      rationale: rationale ?? this.rationale,
      component: component ?? this.component,
      projectName: projectName ?? projectName,
      budgetAmount: budgetAmount ?? budgetAmount,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewComments: reviewComments ?? this.reviewComments,
      documents: documents ?? this.documents,
      capacityAnalysis: capacityAnalysis ?? this.capacityAnalysis,
      comments: comments ?? this.comments,
      eSignStatus: eSignStatus ?? this.eSignStatus,
      eSignDocumentUrl: eSignDocumentUrl ?? this.eSignDocumentUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Request document model
class RequestDocument {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final String? thumbnailUrl;

  const RequestDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    this.thumbnailUrl,
  });

  factory RequestDocument.fromJson(Map<String, dynamic> json) {
    return RequestDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploaded_at': uploadedAt.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }
}

/// Capacity analysis model
class CapacityAnalysis {
  final double requestedCapacity;
  final double currentCapacity;
  final double agencyRating;
  final double utilizationScore;
  final String recommendation;
  final List<String> insights;

  const CapacityAnalysis({
    required this.requestedCapacity,
    required this.currentCapacity,
    required this.agencyRating,
    required this.utilizationScore,
    required this.recommendation,
    this.insights = const [],
  });

  factory CapacityAnalysis.fromJson(Map<String, dynamic> json) {
    return CapacityAnalysis(
      requestedCapacity: (json['requested_capacity'] as num).toDouble(),
      currentCapacity: (json['current_capacity'] as num).toDouble(),
      agencyRating: (json['agency_rating'] as num).toDouble(),
      utilizationScore: (json['utilization_score'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requested_capacity': requestedCapacity,
      'current_capacity': currentCapacity,
      'agency_rating': agencyRating,
      'utilization_score': utilizationScore,
      'recommendation': recommendation,
      'insights': insights,
    };
  }
}

/// Request comment model
class RequestComment {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String content;
  final DateTime createdAt;
  final bool isInternal;

  const RequestComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.createdAt,
    this.isInternal = false,
  });

  factory RequestComment.fromJson(Map<String, dynamic> json) {
    return RequestComment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userRole: json['user_role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isInternal: json['is_internal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_internal': isInternal,
    };
  }
}

/// Request type enum
enum RequestType {
  projectAssignment,
  fundAllocation,
  capacityIncrease,
  documentApproval,
  milestoneReview,
  exception,
  other;

  String get displayName {
    switch (this) {
      case RequestType.projectAssignment:
        return 'Project Assignment';
      case RequestType.fundAllocation:
        return 'Fund Allocation';
      case RequestType.capacityIncrease:
        return 'Capacity Increase';
      case RequestType.documentApproval:
        return 'Document Approval';
      case RequestType.milestoneReview:
        return 'Milestone Review';
      case RequestType.exception:
        return 'Exception Request';
      case RequestType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case RequestType.projectAssignment:
        return Icons.assignment;
      case RequestType.fundAllocation:
        return Icons.account_balance_wallet;
      case RequestType.capacityIncrease:
        return Icons.trending_up;
      case RequestType.documentApproval:
        return Icons.description;
      case RequestType.milestoneReview:
        return Icons.flag;
      case RequestType.exception:
        return Icons.error_outline;
      case RequestType.other:
        return Icons.more_horiz;
    }
  }
}

/// Request priority enum
enum RequestPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case RequestPriority.low:
        return 'Low';
      case RequestPriority.medium:
        return 'Medium';
      case RequestPriority.high:
        return 'High';
      case RequestPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case RequestPriority.low:
        return Colors.grey;
      case RequestPriority.medium:
        return Colors.amber;
      case RequestPriority.high:
        return Colors.orange;
      case RequestPriority.urgent:
        return Colors.red;
    }
  }
}

/// Request status enum
enum RequestStatus {
  pending,
  underReview,
  moreInfoRequired,
  infoRequested,
  approved,
  rejected,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.underReview:
        return 'Under Review';
      case RequestStatus.moreInfoRequired:
        return 'More Info Required';
      case RequestStatus.infoRequested:
        return 'Info Requested';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.expired:
        return 'Expired';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return Colors.amber;
      case RequestStatus.underReview:
        return Colors.blue;
      case RequestStatus.moreInfoRequired:
        return Colors.orange;
      case RequestStatus.infoRequested:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.cancelled:
        return Colors.grey;
      case RequestStatus.expired:
        return Colors.grey.shade400;
    }
  }
}

/// E-Sign status enum
enum ESignStatus {
  pending,
  inProgress,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case ESignStatus.pending:
        return 'Pending';
      case ESignStatus.inProgress:
        return 'In Progress';
      case ESignStatus.completed:
        return 'Completed';
      case ESignStatus.failed:
        return 'Failed';
    }
  }

  IconData get icon {
    switch (this) {
      case ESignStatus.pending:
        return Icons.pending;
      case ESignStatus.inProgress:
        return Icons.hourglass_empty;
      case ESignStatus.completed:
        return Icons.check_circle;
      case ESignStatus.failed:
        return Icons.error;
    }
  }
}

/// Project component enum
enum ProjectComponent {
  all,
  adarshGram,
  gia,
  hostel;

  String get displayName {
    switch (this) {
      case ProjectComponent.all:
        return 'All Components';
      case ProjectComponent.adarshGram:
        return 'Adarsh Gram';
      case ProjectComponent.gia:
        return 'GIA (Grant-in-Aid)';
      case ProjectComponent.hostel:
        return 'Hostel Construction';
      default:
        return name;
    }
  }
}