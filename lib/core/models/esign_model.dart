import 'package:crypto/crypto.dart';
import 'dart:convert';

enum SignatureType {
  digital('digital'),
  biometric('biometric'),
  otp('otp'),
  aadhaar('aadhaar');

  final String value;
  const SignatureType(this.value);

  static SignatureType fromString(String value) {
    return SignatureType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SignatureType.digital,
    );
  }
}

enum DocumentStatus {
  draft('draft'),
  pending('pending'),
  signed('signed'),
  rejected('rejected'),
  expired('expired');

  final String value;
  const DocumentStatus(this.value);

  static DocumentStatus fromString(String value) {
    return DocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentStatus.draft,
    );
  }
}

class SignatureData {
  final String id;
  final String signerId;
  final String signerName;
  final String signerRole;
  final SignatureType type;
  final String signatureHash;
  final String? biometricData;
  final String? otpVerification;
  final String? aadhaarNumber;
  final DateTime timestamp;
  final String ipAddress;
  final String deviceInfo;
  final Map<String, dynamic> metadata;

  SignatureData({
    required this.id,
    required this.signerId,
    required this.signerName,
    required this.signerRole,
    required this.type,
    required this.signatureHash,
    this.biometricData,
    this.otpVerification,
    this.aadhaarNumber,
    required this.timestamp,
    required this.ipAddress,
    required this.deviceInfo,
    this.metadata = const {},
  });

  factory SignatureData.fromJson(Map<String, dynamic> json) {
    return SignatureData(
      id: json['id'] as String,
      signerId: json['signer_id'] as String,
      signerName: json['signer_name'] as String,
      signerRole: json['signer_role'] as String,
      type: SignatureType.fromString(json['type'] as String),
      signatureHash: json['signature_hash'] as String,
      biometricData: json['biometric_data'] as String?,
      otpVerification: json['otp_verification'] as String?,
      aadhaarNumber: json['aadhaar_number'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ip_address'] as String,
      deviceInfo: json['device_info'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signer_id': signerId,
      'signer_name': signerName,
      'signer_role': signerRole,
      'type': type.value,
      'signature_hash': signatureHash,
      'biometric_data': biometricData,
      'otp_verification': otpVerification,
      'aadhaar_number': aadhaarNumber,
      'timestamp': timestamp.toIso8601String(),
      'ip_address': ipAddress,
      'device_info': deviceInfo,
      'metadata': metadata,
    };
  }

  bool verifySignature(String documentHash) {
    final combined = '$documentHash:$signerId:${timestamp.toIso8601String()}';
    final expectedHash = sha256.convert(utf8.encode(combined)).toString();
    return signatureHash == expectedHash;
  }
}

class SigningWorkflow {
  final String id;
  final List<String> signerIds;
  final List<String> signerRoles;
  final bool sequential;
  final int currentStep;
  final Map<String, bool> completedSigners;

  SigningWorkflow({
    required this.id,
    required this.signerIds,
    required this.signerRoles,
    this.sequential = true,
    this.currentStep = 0,
    this.completedSigners = const {},
  });

  factory SigningWorkflow.fromJson(Map<String, dynamic> json) {
    return SigningWorkflow(
      id: json['id'] as String,
      signerIds: List<String>.from(json['signer_ids'] as List),
      signerRoles: List<String>.from(json['signer_roles'] as List),
      sequential: json['sequential'] as bool? ?? true,
      currentStep: json['current_step'] as int? ?? 0,
      completedSigners: Map<String, bool>.from(json['completed_signers'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signer_ids': signerIds,
      'signer_roles': signerRoles,
      'sequential': sequential,
      'current_step': currentStep,
      'completed_signers': completedSigners,
    };
  }

  bool canSign(String userId) {
    if (sequential) {
      if (currentStep >= signerIds.length) return false;
      return signerIds[currentStep] == userId;
    } else {
      return signerIds.contains(userId) && !(completedSigners[userId] ?? false);
    }
  }

  bool get isComplete {
    return completedSigners.length == signerIds.length;
  }

  SigningWorkflow markSignerComplete(String userId) {
    final newCompleted = Map<String, bool>.from(completedSigners);
    newCompleted[userId] = true;
    return SigningWorkflow(
      id: id,
      signerIds: signerIds,
      signerRoles: signerRoles,
      sequential: sequential,
      currentStep: sequential ? currentStep + 1 : currentStep,
      completedSigners: newCompleted,
    );
  }
}

class ESignDocument {
  final String id;
  final String title;
  final String description;
  final String documentType;
  final String documentUrl;
  final String documentHash;
  final DocumentStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final SigningWorkflow workflow;
  final List<SignatureData> signatures;
  final List<AuditEntry> auditTrail;
  final Map<String, dynamic> metadata;

  ESignDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.documentType,
    required this.documentUrl,
    required this.documentHash,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.expiresAt,
    required this.workflow,
    this.signatures = const [],
    this.auditTrail = const [],
    this.metadata = const {},
  });

  factory ESignDocument.fromJson(Map<String, dynamic> json) {
    return ESignDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      documentType: json['document_type'] as String,
      documentUrl: json['document_url'] as String,
      documentHash: json['document_hash'] as String,
      status: DocumentStatus.fromString(json['status'] as String),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      workflow: SigningWorkflow.fromJson(json['workflow'] as Map<String, dynamic>),
      signatures: (json['signatures'] as List?)
              ?.map((s) => SignatureData.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      auditTrail: (json['audit_trail'] as List?)
              ?.map((a) => AuditEntry.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'document_type': documentType,
      'document_url': documentUrl,
      'document_hash': documentHash,
      'status': status.value,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'workflow': workflow.toJson(),
      'signatures': signatures.map((s) => s.toJson()).toList(),
      'audit_trail': auditTrail.map((a) => a.toJson()).toList(),
      'metadata': metadata,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isFullySigned {
    return workflow.isComplete && signatures.length == workflow.signerIds.length;
  }

  bool canUserSign(String userId) {
    return workflow.canSign(userId);
  }

  ESignDocument addSignature(SignatureData signature) {
    final newSignatures = [...signatures, signature];
    final newWorkflow = workflow.markSignerComplete(signature.signerId);
    final newStatus = newWorkflow.isComplete 
        ? DocumentStatus.signed 
        : DocumentStatus.pending;

    return copyWith(
      signatures: newSignatures,
      workflow: newWorkflow,
      status: newStatus,
      auditTrail: [
        ...auditTrail,
        AuditEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          action: 'signature_added',
          userId: signature.signerId,
          timestamp: signature.timestamp,
          details: {
            'signer_name': signature.signerName,
            'signature_type': signature.type.value,
          },
        ),
      ],
    );
  }

  String generateDocumentHash() {
    final content = '$title:$documentType:$documentUrl:${createdAt.toIso8601String()}';
    return sha256.convert(utf8.encode(content)).toString();
  }

  bool verifyIntegrity() {
    return documentHash == generateDocumentHash();
  }

  ESignDocument copyWith({
    String? id,
    String? title,
    String? description,
    String? documentType,
    String? documentUrl,
    String? documentHash,
    DocumentStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? expiresAt,
    SigningWorkflow? workflow,
    List<SignatureData>? signatures,
    List<AuditEntry>? auditTrail,
    Map<String, dynamic>? metadata,
  }) {
    return ESignDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      documentHash: documentHash ?? this.documentHash,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      workflow: workflow ?? this.workflow,
      signatures: signatures ?? this.signatures,
      auditTrail: auditTrail ?? this.auditTrail,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AuditEntry {
  final String id;
  final String action;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  AuditEntry({
    required this.id,
    required this.action,
    required this.userId,
    required this.timestamp,
    this.details = const {},
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      action: json['action'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}