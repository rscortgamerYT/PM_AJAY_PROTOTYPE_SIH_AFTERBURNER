/// Blockchain integration models for government fund tracking
class BlockchainTransaction {
  final String id;
  final String transactionHash;
  final String blockHash;
  final String blockNumber;
  final String contractAddress;
  final DateTime timestamp;
  final String dataHash;
  final Map<String, dynamic> metadata;
  final String status;

  BlockchainTransaction({
    required this.id,
    required this.transactionHash,
    required this.blockHash,
    required this.blockNumber,
    required this.contractAddress,
    required this.timestamp,
    required this.dataHash,
    required this.metadata,
    required this.status,
  });

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      id: json['id'],
      transactionHash: json['transaction_hash'],
      blockHash: json['block_hash'],
      blockNumber: json['block_number'],
      contractAddress: json['contract_address'],
      timestamp: DateTime.parse(json['timestamp']),
      dataHash: json['data_hash'],
      metadata: json['metadata'] ?? {},
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_hash': transactionHash,
      'block_hash': blockHash,
      'block_number': blockNumber,
      'contract_address': contractAddress,
      'timestamp': timestamp.toIso8601String(),
      'data_hash': dataHash,
      'metadata': metadata,
      'status': status,
    };
  }
}

class DocumentHashRecord {
  final String id;
  final String documentId;
  final String fileName;
  final String fileHash;
  final String blockchainHash;
  final String ipfsCid;
  final String uploaderUserId;
  final DateTime uploadTimestamp;
  final String verificationStatus;
  final Map<String, dynamic> metadata;

  DocumentHashRecord({
    required this.id,
    required this.documentId,
    required this.fileName,
    required this.fileHash,
    required this.blockchainHash,
    required this.ipfsCid,
    required this.uploaderUserId,
    required this.uploadTimestamp,
    required this.verificationStatus,
    required this.metadata,
  });

  factory DocumentHashRecord.fromJson(Map<String, dynamic> json) {
    return DocumentHashRecord(
      id: json['id'],
      documentId: json['document_id'],
      fileName: json['file_name'],
      fileHash: json['file_hash'],
      blockchainHash: json['blockchain_hash'],
      ipfsCid: json['ipfs_cid'],
      uploaderUserId: json['uploader_user_id'],
      uploadTimestamp: DateTime.parse(json['upload_timestamp']),
      verificationStatus: json['verification_status'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'file_name': fileName,
      'file_hash': fileHash,
      'blockchain_hash': blockchainHash,
      'ipfs_cid': ipfsCid,
      'uploader_user_id': uploaderUserId,
      'upload_timestamp': uploadTimestamp.toIso8601String(),
      'verification_status': verificationStatus,
      'metadata': metadata,
    };
  }
}

class SmartContractRelease {
  final String id;
  final String contractAddress;
  final String projectId;
  final String milestoneId;
  final double releaseAmount;
  final Map<String, dynamic> triggerConditions;
  final String oracleStatus;
  final String releaseStatus;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final DateTime? releasedAt;
  final Map<String, dynamic> metadata;

  SmartContractRelease({
    required this.id,
    required this.contractAddress,
    required this.projectId,
    required this.milestoneId,
    required this.releaseAmount,
    required this.triggerConditions,
    required this.oracleStatus,
    required this.releaseStatus,
    required this.createdAt,
    this.triggeredAt,
    this.releasedAt,
    required this.metadata,
  });

  factory SmartContractRelease.fromJson(Map<String, dynamic> json) {
    return SmartContractRelease(
      id: json['id'],
      contractAddress: json['contract_address'],
      projectId: json['project_id'],
      milestoneId: json['milestone_id'],
      releaseAmount: (json['release_amount'] as num).toDouble(),
      triggerConditions: json['trigger_conditions'] ?? {},
      oracleStatus: json['oracle_status'],
      releaseStatus: json['release_status'],
      createdAt: DateTime.parse(json['created_at']),
      triggeredAt: json['triggered_at'] != null ? DateTime.parse(json['triggered_at']) : null,
      releasedAt: json['released_at'] != null ? DateTime.parse(json['released_at']) : null,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_address': contractAddress,
      'project_id': projectId,
      'milestone_id': milestoneId,
      'release_amount': releaseAmount,
      'trigger_conditions': triggerConditions,
      'oracle_status': oracleStatus,
      'release_status': releaseStatus,
      'created_at': createdAt.toIso8601String(),
      'triggered_at': triggeredAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class AuditTrailStats {
  final int totalTransactionsAnchored;
  final String lastBlockHash;
  final DateTime lastAnchorTimestamp;
  final double integrityPercentage;
  final String networkStatus;
  final Map<String, int> statusCounts;

  AuditTrailStats({
    required this.totalTransactionsAnchored,
    required this.lastBlockHash,
    required this.lastAnchorTimestamp,
    required this.integrityPercentage,
    required this.networkStatus,
    required this.statusCounts,
  });

  factory AuditTrailStats.fromJson(Map<String, dynamic> json) {
    return AuditTrailStats(
      totalTransactionsAnchored: json['total_transactions_anchored'],
      lastBlockHash: json['last_block_hash'],
      lastAnchorTimestamp: DateTime.parse(json['last_anchor_timestamp']),
      integrityPercentage: (json['integrity_percentage'] as num).toDouble(),
      networkStatus: json['network_status'],
      statusCounts: Map<String, int>.from(json['status_counts'] ?? {}),
    );
  }
}

enum BlockchainNetworkStatus {
  connected,
  disconnected,
  syncing,
  error
}

enum VerificationStatus {
  verified,
  pending,
  failed,
  notVerified
}

enum ReleaseStatus {
  pending,
  triggered,
  released,
  failed,
  cancelled
}

enum OracleStatus {
  active,
  inactive,
  updating,
  error
}