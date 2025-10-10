enum FlagReason {
  delay('delay'),
  fundIssue('fund_issue'),
  qualityIssue('quality_issue'),
  complianceViolation('compliance_violation'),
  safetyIssue('safety_issue'),
  documentationIssue('documentation_issue'),
  custom('custom');

  final String value;
  const FlagReason(this.value);

  static FlagReason fromString(String value) {
    return FlagReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => FlagReason.custom,
    );
  }

  String get displayName {
    switch (this) {
      case FlagReason.delay:
        return 'Project Delay';
      case FlagReason.fundIssue:
        return 'Fund Issue';
      case FlagReason.qualityIssue:
        return 'Quality Issue';
      case FlagReason.complianceViolation:
        return 'Compliance Violation';
      case FlagReason.safetyIssue:
        return 'Safety Issue';
      case FlagReason.documentationIssue:
        return 'Documentation Issue';
      case FlagReason.custom:
        return 'Custom';
    }
  }
}

enum FlagStatus {
  open('open'),
  acknowledged('acknowledged'),
  inProgress('in_progress'),
  resolved('resolved'),
  escalated('escalated');

  final String value;
  const FlagStatus(this.value);

  static FlagStatus fromString(String value) {
    return FlagStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FlagStatus.open,
    );
  }
}

enum FlagSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const FlagSeverity(this.value);

  static FlagSeverity fromString(String value) {
    return FlagSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => FlagSeverity.medium,
    );
  }
}

class ProjectFlag {
  final String id;
  final String projectId;
  final String agencyId;
  final FlagReason reason;
  final FlagSeverity severity;
  final FlagStatus status;
  final String description;
  final String? customReason;
  final String flaggedBy;
  final DateTime flaggedAt;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final List<String> attachmentUrls;
  final Map<String, dynamic> metadata;

  ProjectFlag({
    required this.id,
    required this.projectId,
    required this.agencyId,
    required this.reason,
    required this.severity,
    required this.status,
    required this.description,
    this.customReason,
    required this.flaggedBy,
    required this.flaggedAt,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
    this.attachmentUrls = const [],
    this.metadata = const {},
  });

  factory ProjectFlag.fromJson(Map<String, dynamic> json) {
    return ProjectFlag(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      agencyId: json['agency_id'] as String,
      reason: FlagReason.fromString(json['reason'] as String),
      severity: FlagSeverity.fromString(json['severity'] as String),
      status: FlagStatus.fromString(json['status'] as String),
      description: json['description'] as String,
      customReason: json['custom_reason'] as String?,
      flaggedBy: json['flagged_by'] as String,
      flaggedAt: DateTime.parse(json['flagged_at'] as String),
      acknowledgedBy: json['acknowledged_by'] as String?,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolutionNotes: json['resolution_notes'] as String?,
      attachmentUrls: List<String>.from(json['attachment_urls'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'agency_id': agencyId,
      'reason': reason.value,
      'severity': severity.value,
      'status': status.value,
      'description': description,
      'custom_reason': customReason,
      'flagged_by': flaggedBy,
      'flagged_at': flaggedAt.toIso8601String(),
      'acknowledged_by': acknowledgedBy,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
      'attachment_urls': attachmentUrls,
      'metadata': metadata,
    };
  }

  ProjectFlag copyWith({
    String? id,
    String? projectId,
    String? agencyId,
    FlagReason? reason,
    FlagSeverity? severity,
    FlagStatus? status,
    String? description,
    String? customReason,
    String? flaggedBy,
    DateTime? flaggedAt,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolutionNotes,
    List<String>? attachmentUrls,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectFlag(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      agencyId: agencyId ?? this.agencyId,
      reason: reason ?? this.reason,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      description: description ?? this.description,
      customReason: customReason ?? this.customReason,
      flaggedBy: flaggedBy ?? this.flaggedBy,
      flaggedAt: flaggedAt ?? this.flaggedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      metadata: metadata ?? this.metadata,
    );
  }
}