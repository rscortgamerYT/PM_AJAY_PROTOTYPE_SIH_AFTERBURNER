import 'package:flutter/material.dart';

/// Claim status enum
enum ClaimStatus {
  pending('Pending Review', Colors.orange),
  approved('Approved', Colors.green),
  rejected('Rejected', Colors.red),
  onHold('On Hold', Colors.amber),
  underReview('Under AI Review', Colors.blue);

  final String label;
  final Color color;
  const ClaimStatus(this.label, this.color);
}

/// Fraud risk level
enum FraudRiskLevel {
  low('Low Risk', Colors.green, 0.0, 0.3),
  medium('Medium Risk', Colors.orange, 0.3, 0.6),
  high('High Risk', Colors.red, 0.6, 1.0);

  final String label;
  final Color color;
  final double minScore;
  final double maxScore;
  
  const FraudRiskLevel(this.label, this.color, this.minScore, this.maxScore);

  static FraudRiskLevel fromScore(double score) {
    if (score <= 0.3) return FraudRiskLevel.low;
    if (score <= 0.6) return FraudRiskLevel.medium;
    return FraudRiskLevel.high;
  }
}

/// Document type enum
enum DocumentType {
  workOrder('Work Order'),
  invoice('Invoice'),
  photograph('Photograph'),
  gpsCoordinates('GPS Coordinates'),
  qualityReport('Quality Report'),
  materialBill('Material Bill'),
  labourReport('Labour Report'),
  measurementSheet('Measurement Sheet');

  final String label;
  const DocumentType(this.label);
}

/// AI fraud detection result
class FraudDetectionResult {
  final double fraudScore;
  final FraudRiskLevel riskLevel;
  final List<String> suspiciousIndicators;
  final List<String> verifiedFactors;
  final Map<String, double> analysisScores;
  final String aiConfidence;
  final DateTime analyzedAt;

  FraudDetectionResult({
    required this.fraudScore,
    required this.riskLevel,
    required this.suspiciousIndicators,
    required this.verifiedFactors,
    required this.analysisScores,
    required this.aiConfidence,
    required this.analyzedAt,
  });

  factory FraudDetectionResult.fromJson(Map<String, dynamic> json) {
    return FraudDetectionResult(
      fraudScore: json['fraud_score'] as double,
      riskLevel: FraudRiskLevel.fromScore(json['fraud_score'] as double),
      suspiciousIndicators: List<String>.from(json['suspicious_indicators'] ?? []),
      verifiedFactors: List<String>.from(json['verified_factors'] ?? []),
      analysisScores: Map<String, double>.from(json['analysis_scores'] ?? {}),
      aiConfidence: json['ai_confidence'] as String,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fraud_score': fraudScore,
      'risk_level': riskLevel.label,
      'suspicious_indicators': suspiciousIndicators,
      'verified_factors': verifiedFactors,
      'analysis_scores': analysisScores,
      'ai_confidence': aiConfidence,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }
}

/// Document model
class ClaimDocument {
  final String id;
  final DocumentType type;
  final String fileName;
  final String fileUrl;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final bool isVerified;
  final Map<String, dynamic>? metadata;

  ClaimDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.fileUrl,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.isVerified = false,
    this.metadata,
  });

  factory ClaimDocument.fromJson(Map<String, dynamic> json) {
    return ClaimDocument(
      id: json['id'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.label == json['type'],
        orElse: () => DocumentType.invoice,
      ),
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      isVerified: json['is_verified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.label,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size_bytes': fileSizeBytes,
      'uploaded_at': uploadedAt.toIso8601String(),
      'is_verified': isVerified,
      'metadata': metadata,
    };
  }
}

/// Milestone claim model
class MilestoneClaim {
  final String id;
  final String projectId;
  final String projectName;
  final String companyName;
  final String companyId;
  final String milestoneNumber;
  final String milestoneDescription;
  final double claimedAmount;
  final double approvedAmount;
  final ClaimStatus status;
  final List<ClaimDocument> documents;
  final FraudDetectionResult? fraudAnalysis;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerNotes;
  final String? reviewerId;
  final String submittedBy;
  final Map<String, dynamic> milestoneDetails;

  MilestoneClaim({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.companyName,
    required this.companyId,
    required this.milestoneNumber,
    required this.milestoneDescription,
    required this.claimedAmount,
    this.approvedAmount = 0.0,
    this.status = ClaimStatus.pending,
    required this.documents,
    this.fraudAnalysis,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerNotes,
    this.reviewerId,
    required this.submittedBy,
    required this.milestoneDetails,
  });

  factory MilestoneClaim.fromJson(Map<String, dynamic> json) {
    return MilestoneClaim(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      projectName: json['project_name'] as String,
      companyName: json['company_name'] as String,
      companyId: json['company_id'] as String,
      milestoneNumber: json['milestone_number'] as String,
      milestoneDescription: json['milestone_description'] as String,
      claimedAmount: (json['claimed_amount'] as num).toDouble(),
      approvedAmount: (json['approved_amount'] as num?)?.toDouble() ?? 0.0,
      status: ClaimStatus.values.firstWhere(
        (e) => e.label == json['status'],
        orElse: () => ClaimStatus.pending,
      ),
      documents: (json['documents'] as List)
          .map((doc) => ClaimDocument.fromJson(doc as Map<String, dynamic>))
          .toList(),
      fraudAnalysis: json['fraud_analysis'] != null
          ? FraudDetectionResult.fromJson(json['fraud_analysis'] as Map<String, dynamic>)
          : null,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewerNotes: json['reviewer_notes'] as String?,
      reviewerId: json['reviewer_id'] as String?,
      submittedBy: json['submitted_by'] as String,
      milestoneDetails: json['milestone_details'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_name': projectName,
      'company_name': companyName,
      'company_id': companyId,
      'milestone_number': milestoneNumber,
      'milestone_description': milestoneDescription,
      'claimed_amount': claimedAmount,
      'approved_amount': approvedAmount,
      'status': status.label,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'fraud_analysis': fraudAnalysis?.toJson(),
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewer_notes': reviewerNotes,
      'reviewer_id': reviewerId,
      'submitted_by': submittedBy,
      'milestone_details': milestoneDetails,
    };
  }

  MilestoneClaim copyWith({
    ClaimStatus? status,
    double? approvedAmount,
    DateTime? reviewedAt,
    String? reviewerNotes,
    String? reviewerId,
    FraudDetectionResult? fraudAnalysis,
  }) {
    return MilestoneClaim(
      id: id,
      projectId: projectId,
      projectName: projectName,
      companyName: companyName,
      companyId: companyId,
      milestoneNumber: milestoneNumber,
      milestoneDescription: milestoneDescription,
      claimedAmount: claimedAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      status: status ?? this.status,
      documents: documents,
      fraudAnalysis: fraudAnalysis ?? this.fraudAnalysis,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      reviewerId: reviewerId ?? this.reviewerId,
      submittedBy: submittedBy,
      milestoneDetails: milestoneDetails,
    );
  }
}