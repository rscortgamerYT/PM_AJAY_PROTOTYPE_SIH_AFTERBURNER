import 'package:flutter/material.dart';

/// Evidence type classification
enum EvidenceType {
  photo,
  document,
  video,
  invoice,
  receipt,
  report,
  certificate,
  other,
}

extension EvidenceTypeExtension on EvidenceType {
  String get label {
    switch (this) {
      case EvidenceType.photo:
        return 'Photo';
      case EvidenceType.document:
        return 'Document';
      case EvidenceType.video:
        return 'Video';
      case EvidenceType.invoice:
        return 'Invoice';
      case EvidenceType.receipt:
        return 'Receipt';
      case EvidenceType.report:
        return 'Report';
      case EvidenceType.certificate:
        return 'Certificate';
      case EvidenceType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case EvidenceType.photo:
        return Icons.photo;
      case EvidenceType.document:
        return Icons.description;
      case EvidenceType.video:
        return Icons.videocam;
      case EvidenceType.invoice:
        return Icons.receipt_long;
      case EvidenceType.receipt:
        return Icons.receipt;
      case EvidenceType.report:
        return Icons.article;
      case EvidenceType.certificate:
        return Icons.verified;
      case EvidenceType.other:
        return Icons.insert_drive_file;
    }
  }

  Color get color {
    switch (this) {
      case EvidenceType.photo:
        return const Color(0xFF10B981);
      case EvidenceType.document:
        return const Color(0xFF3B82F6);
      case EvidenceType.video:
        return const Color(0xFF8B5CF6);
      case EvidenceType.invoice:
        return const Color(0xFFF59E0B);
      case EvidenceType.receipt:
        return const Color(0xFFEF4444);
      case EvidenceType.report:
        return const Color(0xFF06B6D4);
      case EvidenceType.certificate:
        return const Color(0xFF10B981);
      case EvidenceType.other:
        return const Color(0xFF6B7280);
    }
  }
}

/// Evidence verification status
enum VerificationStatus {
  pending,
  verified,
  rejected,
  flagged,
}

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.flagged:
        return 'Flagged';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.pending:
        return const Color(0xFFF59E0B);
      case VerificationStatus.verified:
        return const Color(0xFF10B981);
      case VerificationStatus.rejected:
        return const Color(0xFFEF4444);
      case VerificationStatus.flagged:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationStatus.pending:
        return Icons.pending;
      case VerificationStatus.verified:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.flagged:
        return Icons.flag;
    }
  }
}

/// Geolocation data
class GeoLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'address': address,
  };
}

/// Blockchain anchor for evidence custody
class BlockchainAnchor {
  final String transactionHash;
  final DateTime timestamp;
  final String blockNumber;
  final String network;

  BlockchainAnchor({
    required this.transactionHash,
    required this.timestamp,
    required this.blockNumber,
    required this.network,
  });

  Map<String, dynamic> toJson() => {
    'transactionHash': transactionHash,
    'timestamp': timestamp.toIso8601String(),
    'blockNumber': blockNumber,
    'network': network,
  };
}

/// Evidence metadata
class EvidenceMetadata {
  final String? cameraModel;
  final String? capturedBy;
  final DateTime? originalTimestamp;
  final Map<String, dynamic>? exifData;
  final String? fileHash;
  final int? fileSize;
  final String? mimeType;

  EvidenceMetadata({
    this.cameraModel,
    this.capturedBy,
    this.originalTimestamp,
    this.exifData,
    this.fileHash,
    this.fileSize,
    this.mimeType,
  });

  Map<String, dynamic> toJson() => {
    'cameraModel': cameraModel,
    'capturedBy': capturedBy,
    'originalTimestamp': originalTimestamp?.toIso8601String(),
    'exifData': exifData,
    'fileHash': fileHash,
    'fileSize': fileSize,
    'mimeType': mimeType,
  };
}

/// Comprehensive evidence model
class Evidence {
  final String id;
  final EvidenceType type;
  final String projectId;
  final String projectName;
  final String fileName;
  final String? fileUrl;
  final DateTime uploadedAt;
  final String uploadedBy;
  final VerificationStatus status;
  final double qualityScore;
  final GeoLocation? location;
  final EvidenceMetadata metadata;
  final List<String> tags;
  final String? description;
  final List<String> relatedEvidenceIds;
  final BlockchainAnchor? blockchainAnchor;
  final List<String> suspiciousFlags;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final List<Map<String, dynamic>> versions;

  Evidence({
    required this.id,
    required this.type,
    required this.projectId,
    required this.projectName,
    required this.fileName,
    this.fileUrl,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.status,
    required this.qualityScore,
    this.location,
    required this.metadata,
    this.tags = const [],
    this.description,
    this.relatedEvidenceIds = const [],
    this.blockchainAnchor,
    this.suspiciousFlags = const [],
    this.verifiedAt,
    this.verifiedBy,
    this.versions = const [],
  });

  bool get hasIssues => suspiciousFlags.isNotEmpty || status == VerificationStatus.flagged;
  bool get isVerified => status == VerificationStatus.verified;
  bool get hasLocation => location != null;
  bool get isBlockchainAnchored => blockchainAnchor != null;

  Evidence copyWith({
    String? id,
    EvidenceType? type,
    String? projectId,
    String? projectName,
    String? fileName,
    String? fileUrl,
    DateTime? uploadedAt,
    String? uploadedBy,
    VerificationStatus? status,
    double? qualityScore,
    GeoLocation? location,
    EvidenceMetadata? metadata,
    List<String>? tags,
    String? description,
    List<String>? relatedEvidenceIds,
    BlockchainAnchor? blockchainAnchor,
    List<String>? suspiciousFlags,
    DateTime? verifiedAt,
    String? verifiedBy,
    List<Map<String, dynamic>>? versions,
  }) {
    return Evidence(
      id: id ?? this.id,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
      qualityScore: qualityScore ?? this.qualityScore,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      relatedEvidenceIds: relatedEvidenceIds ?? this.relatedEvidenceIds,
      blockchainAnchor: blockchainAnchor ?? this.blockchainAnchor,
      suspiciousFlags: suspiciousFlags ?? this.suspiciousFlags,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      versions: versions ?? this.versions,
    );
  }
}

/// Evidence version for tracking modifications
class EvidenceVersion {
  final String versionId;
  final DateTime timestamp;
  final String modifiedBy;
  final String changeDescription;
  final String fileHash;

  EvidenceVersion({
    required this.versionId,
    required this.timestamp,
    required this.modifiedBy,
    required this.changeDescription,
    required this.fileHash,
  });
}

/// Evidence correlation between multiple pieces of evidence
class EvidenceCorrelation {
  final String id;
  final String evidenceId1;
  final String evidenceId2;
  final double similarityScore;
  final CorrelationType type;
  final List<String> suspiciousFlags;
  final DateTime detectedAt;

  EvidenceCorrelation({
    required this.id,
    required this.evidenceId1,
    required this.evidenceId2,
    required this.similarityScore,
    required this.type,
    required this.suspiciousFlags,
    required this.detectedAt,
  });
}

/// Correlation type
enum CorrelationType {
  duplicate,
  similar,
  relatedLocation,
  relatedTime,
  suspiciousPattern,
}

extension CorrelationTypeExtension on CorrelationType {
  String get label {
    switch (this) {
      case CorrelationType.duplicate:
        return 'Duplicate';
      case CorrelationType.similar:
        return 'Similar';
      case CorrelationType.relatedLocation:
        return 'Same Location';
      case CorrelationType.relatedTime:
        return 'Same Time';
      case CorrelationType.suspiciousPattern:
        return 'Suspicious Pattern';
    }
  }

  Color get color {
    switch (this) {
      case CorrelationType.duplicate:
        return const Color(0xFFEF4444);
      case CorrelationType.similar:
        return const Color(0xFFF59E0B);
      case CorrelationType.relatedLocation:
        return const Color(0xFF3B82F6);
      case CorrelationType.relatedTime:
        return const Color(0xFF8B5CF6);
      case CorrelationType.suspiciousPattern:
        return const Color(0xFFEF4444);
    }
  }
}

/// Evidence analytics summary
class EvidenceAnalytics {
  final int totalEvidence;
  final int pendingVerification;
  final int verifiedEvidence;
  final int flaggedEvidence;
  final double averageQualityScore;
  final Map<EvidenceType, int> evidenceByType;
  final Map<String, int> evidenceByProject;
  final List<EvidenceCorrelation> suspiciousCorrelations;
  final int duplicateDetections;
  final double coverageScore;

  EvidenceAnalytics({
    required this.totalEvidence,
    required this.pendingVerification,
    required this.verifiedEvidence,
    required this.flaggedEvidence,
    required this.averageQualityScore,
    required this.evidenceByType,
    required this.evidenceByProject,
    required this.suspiciousCorrelations,
    required this.duplicateDetections,
    required this.coverageScore,
  });
}