import 'package:latlong2/latlong.dart';

/// Fund flow stages in PM-AJAY system
enum FundFlowStage {
  centreAllocation('Centre Allocation', 'blue'),
  stateTransfer('State Transfer', 'green'),
  agencyDisbursement('Agency Disbursement', 'orange'),
  projectSpend('Project Spend', 'purple'),
  beneficiaryPayment('Beneficiary Payment', 'teal');

  final String label;
  final String colorCode;
  const FundFlowStage(this.label, this.colorCode);
}

/// Transaction status
enum TransactionStatus {
  pending('Pending', 'orange'),
  processing('Processing', 'blue'),
  completed('Completed', 'green'),
  failed('Failed', 'red'),
  onHold('On Hold', 'grey'),
  cancelled('Cancelled', 'red');

  final String label;
  final String colorCode;
  const TransactionStatus(this.label, this.colorCode);
}

/// Scheme components for fund allocation
enum SchemeComponent {
  adarshaGram('Adarsha Gram'),
  gia('Grant-in-Aid'),
  hostel('Hostel'),
  infrastructure('Infrastructure'),
  capacity('Capacity Building');

  final String label;
  const SchemeComponent(this.label);
}

/// Fund transaction model representing a single fund transfer
class FundTransaction {
  final String id;
  final String pfmsId; // Public Financial Management System ID
  final DateTime transactionDate;
  final FundFlowStage stage;
  final TransactionStatus status;
  
  // Source and destination
  final String fromEntity;
  final String fromEntityId;
  final String fromEntityType; // centre, state, agency, project
  final String toEntity;
  final String toEntityId;
  final String toEntityType;
  
  // Financial details
  final double amount;
  final String currency;
  final SchemeComponent component;
  
  // Additional metadata
  final String? stateId;
  final String? districtId;
  final String? agencyId;
  final String? projectId;
  final LatLng? location;
  
  // Documents and verification
  final List<String> documentUrls;
  final String? utilizationCertificateId;
  final String? notes;
  
  // Processing metrics
  final DateTime? processedDate;
  final int? processingDays;
  final bool isDelayed;
  final String? delayReason;
  
  // Audit trail
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FundTransaction({
    required this.id,
    required this.pfmsId,
    required this.transactionDate,
    required this.stage,
    required this.status,
    required this.fromEntity,
    required this.fromEntityId,
    required this.fromEntityType,
    required this.toEntity,
    required this.toEntityId,
    required this.toEntityType,
    required this.amount,
    this.currency = 'INR',
    required this.component,
    this.stateId,
    this.districtId,
    this.agencyId,
    this.projectId,
    this.location,
    this.documentUrls = const [],
    this.utilizationCertificateId,
    this.notes,
    this.processedDate,
    this.processingDays,
    this.isDelayed = false,
    this.delayReason,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FundTransaction.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['location'] != null) {
      final coords = json['location']['coordinates'] as List;
      location = LatLng(coords[1], coords[0]);
    }

    return FundTransaction(
      id: json['id'] as String,
      pfmsId: json['pfms_id'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      stage: FundFlowStage.values.firstWhere(
        (s) => s.name == json['stage'],
        orElse: () => FundFlowStage.centreAllocation,
      ),
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      fromEntity: json['from_entity'] as String,
      fromEntityId: json['from_entity_id'] as String,
      fromEntityType: json['from_entity_type'] as String,
      toEntity: json['to_entity'] as String,
      toEntityId: json['to_entity_id'] as String,
      toEntityType: json['to_entity_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      component: SchemeComponent.values.firstWhere(
        (c) => c.name == json['component'],
        orElse: () => SchemeComponent.adarshaGram,
      ),
      stateId: json['state_id'] as String?,
      districtId: json['district_id'] as String?,
      agencyId: json['agency_id'] as String?,
      projectId: json['project_id'] as String?,
      location: location,
      documentUrls: (json['document_urls'] as List?)?.cast<String>() ?? [],
      utilizationCertificateId: json['utilization_certificate_id'] as String?,
      notes: json['notes'] as String?,
      processedDate: json['processed_date'] != null
          ? DateTime.parse(json['processed_date'] as String)
          : null,
      processingDays: json['processing_days'] as int?,
      isDelayed: json['is_delayed'] as bool? ?? false,
      delayReason: json['delay_reason'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pfms_id': pfmsId,
      'transaction_date': transactionDate.toIso8601String(),
      'stage': stage.name,
      'status': status.name,
      'from_entity': fromEntity,
      'from_entity_id': fromEntityId,
      'from_entity_type': fromEntityType,
      'to_entity': toEntity,
      'to_entity_id': toEntityId,
      'to_entity_type': toEntityType,
      'amount': amount,
      'currency': currency,
      'component': component.name,
      'state_id': stateId,
      'district_id': districtId,
      'agency_id': agencyId,
      'project_id': projectId,
      'location': location != null
          ? {
              'type': 'Point',
              'coordinates': [location!.longitude, location!.latitude]
            }
          : null,
      'document_urls': documentUrls,
      'utilization_certificate_id': utilizationCertificateId,
      'notes': notes,
      'processed_date': processedDate?.toIso8601String(),
      'processing_days': processingDays,
      'is_delayed': isDelayed,
      'delay_reason': delayReason,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Fund allocation model for budget allocations
class FundAllocation {
  final String id;
  final String entityId;
  final String entityType; // state, agency, project
  final SchemeComponent component;
  final double allocatedAmount;
  final double utilizedAmount;
  final double remainingAmount;
  final String fiscalYear;
  final DateTime allocationDate;
  final DateTime? expiryDate;
  final List<String> conditions;
  final Map<String, dynamic> metadata;

  FundAllocation({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.component,
    required this.allocatedAmount,
    this.utilizedAmount = 0,
    double? remainingAmount,
    required this.fiscalYear,
    required this.allocationDate,
    this.expiryDate,
    this.conditions = const [],
    this.metadata = const {},
  }) : remainingAmount = remainingAmount ?? (allocatedAmount - utilizedAmount);

  double get utilizationPercentage => 
      allocatedAmount > 0 ? (utilizedAmount / allocatedAmount) * 100 : 0;

  bool get isOverUtilized => utilizedAmount > allocatedAmount;
  bool get isUnderUtilized => utilizationPercentage < 50;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);

  factory FundAllocation.fromJson(Map<String, dynamic> json) {
    return FundAllocation(
      id: json['id'] as String,
      entityId: json['entity_id'] as String,
      entityType: json['entity_type'] as String,
      component: SchemeComponent.values.firstWhere(
        (c) => c.name == json['component'],
        orElse: () => SchemeComponent.adarshaGram,
      ),
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      utilizedAmount: (json['utilized_amount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble(),
      fiscalYear: json['fiscal_year'] as String,
      allocationDate: DateTime.parse(json['allocation_date'] as String),
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      conditions: (json['conditions'] as List?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_id': entityId,
      'entity_type': entityType,
      'component': component.name,
      'allocated_amount': allocatedAmount,
      'utilized_amount': utilizedAmount,
      'remaining_amount': remainingAmount,
      'fiscal_year': fiscalYear,
      'allocation_date': allocationDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'conditions': conditions,
      'metadata': metadata,
    };
  }
}

/// Utilization Certificate model
class UtilizationCertificate {
  final String id;
  final String transactionId;
  final String projectId;
  final String agencyId;
  final double claimedAmount;
  final double verifiedAmount;
  final SchemeComponent component;
  final DateTime submissionDate;
  final DateTime? verificationDate;
  final String status; // submitted, under_review, verified, rejected
  final List<String> documentUrls;
  final List<String> expenditureDetails;
  final String? verifierComments;
  final String submittedBy;

  UtilizationCertificate({
    required this.id,
    required this.transactionId,
    required this.projectId,
    required this.agencyId,
    required this.claimedAmount,
    required this.verifiedAmount,
    required this.component,
    required this.submissionDate,
    this.verificationDate,
    required this.status,
    this.documentUrls = const [],
    this.expenditureDetails = const [],
    this.verifierComments,
    required this.submittedBy,
  });

  bool get isPending => status == 'submitted' || status == 'under_review';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  double get varianceAmount => claimedAmount - verifiedAmount;
  double get variancePercentage => 
      claimedAmount > 0 ? (varianceAmount / claimedAmount) * 100 : 0;

  factory UtilizationCertificate.fromJson(Map<String, dynamic> json) {
    return UtilizationCertificate(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      projectId: json['project_id'] as String,
      agencyId: json['agency_id'] as String,
      claimedAmount: (json['claimed_amount'] as num).toDouble(),
      verifiedAmount: (json['verified_amount'] as num).toDouble(),
      component: SchemeComponent.values.firstWhere(
        (c) => c.name == json['component'],
        orElse: () => SchemeComponent.adarshaGram,
      ),
      submissionDate: DateTime.parse(json['submission_date'] as String),
      verificationDate: json['verification_date'] != null
          ? DateTime.parse(json['verification_date'] as String)
          : null,
      status: json['status'] as String,
      documentUrls: (json['document_urls'] as List?)?.cast<String>() ?? [],
      expenditureDetails: (json['expenditure_details'] as List?)?.cast<String>() ?? [],
      verifierComments: json['verifier_comments'] as String?,
      submittedBy: json['submitted_by'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'project_id': projectId,
      'agency_id': agencyId,
      'claimed_amount': claimedAmount,
      'verified_amount': verifiedAmount,
      'component': component.name,
      'submission_date': submissionDate.toIso8601String(),
      'verification_date': verificationDate?.toIso8601String(),
      'status': status,
      'document_urls': documentUrls,
      'expenditure_details': expenditureDetails,
      'verifier_comments': verifierComments,
      'submitted_by': submittedBy,
    };
  }
}

/// Fund health metrics
class FundHealthMetrics {
  final double utilizationRate;
  final double averageTransferDays;
  final int bottleneckCount;
  final int delayedTransactions;
  final double forecastedSpend;
  final double actualSpend;
  final double variance;

  FundHealthMetrics({
    required this.utilizationRate,
    required this.averageTransferDays,
    required this.bottleneckCount,
    required this.delayedTransactions,
    required this.forecastedSpend,
    required this.actualSpend,
    double? variance,
  }) : variance = variance ?? (actualSpend - forecastedSpend);

  bool get isHealthy => 
      utilizationRate > 60 && 
      utilizationRate < 110 && 
      averageTransferDays < 7 &&
      bottleneckCount < 3;

  String get healthStatus {
    if (utilizationRate > 110) return 'Over-utilized';
    if (utilizationRate < 50) return 'Under-utilized';
    if (averageTransferDays > 7) return 'Slow processing';
    if (bottleneckCount > 5) return 'Multiple bottlenecks';
    return 'Healthy';
  }

  factory FundHealthMetrics.fromJson(Map<String, dynamic> json) {
    return FundHealthMetrics(
      utilizationRate: (json['utilization_rate'] as num).toDouble(),
      averageTransferDays: (json['average_transfer_days'] as num).toDouble(),
      bottleneckCount: json['bottleneck_count'] as int,
      delayedTransactions: json['delayed_transactions'] as int,
      forecastedSpend: (json['forecasted_spend'] as num).toDouble(),
      actualSpend: (json['actual_spend'] as num).toDouble(),
      variance: (json['variance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'utilization_rate': utilizationRate,
      'average_transfer_days': averageTransferDays,
      'bottleneck_count': bottleneckCount,
      'delayed_transactions': delayedTransactions,
      'forecasted_spend': forecastedSpend,
      'actual_spend': actualSpend,
      'variance': variance,
    };
  }
}