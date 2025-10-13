import 'package:flutter/material.dart';

/// Represents the status of a reconciliation record
enum ReconciliationStatus {
  matched,
  mismatched,
  pending,
  disputed,
  resolved,
  investigating,
}

/// Extension for reconciliation status properties
extension ReconciliationStatusExtension on ReconciliationStatus {
  Color get color {
    switch (this) {
      case ReconciliationStatus.matched:
        return const Color(0xFF4CAF50); // Green
      case ReconciliationStatus.mismatched:
        return const Color(0xFFF44336); // Red
      case ReconciliationStatus.pending:
        return const Color(0xFFFFC107); // Amber
      case ReconciliationStatus.disputed:
        return const Color(0xFFFF5722); // Deep Orange
      case ReconciliationStatus.resolved:
        return const Color(0xFF2196F3); // Blue
      case ReconciliationStatus.investigating:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData get icon {
    switch (this) {
      case ReconciliationStatus.matched:
        return Icons.check_circle;
      case ReconciliationStatus.mismatched:
        return Icons.error;
      case ReconciliationStatus.pending:
        return Icons.pending;
      case ReconciliationStatus.disputed:
        return Icons.flag;
      case ReconciliationStatus.resolved:
        return Icons.check_circle_outline;
      case ReconciliationStatus.investigating:
        return Icons.search;
    }
  }

  String get displayName {
    switch (this) {
      case ReconciliationStatus.matched:
        return 'Matched';
      case ReconciliationStatus.mismatched:
        return 'Mismatched';
      case ReconciliationStatus.pending:
        return 'Pending';
      case ReconciliationStatus.disputed:
        return 'Disputed';
      case ReconciliationStatus.resolved:
        return 'Resolved';
      case ReconciliationStatus.investigating:
        return 'Investigating';
    }
  }
}

/// PFMS (Public Financial Management System) transaction record
class PFMSRecord {
  final String pfmsId;
  final String transactionId;
  final double amount;
  final DateTime transactionDate;
  final String fromAccount;
  final String toAccount;
  final String purpose;
  final String sanctionNumber;
  final String projectCode;
  final String agencyCode;
  final String stateCode;
  final String? utrNumber;
  final Map<String, dynamic>? metadata;

  PFMSRecord({
    required this.pfmsId,
    required this.transactionId,
    required this.amount,
    required this.transactionDate,
    required this.fromAccount,
    required this.toAccount,
    required this.purpose,
    required this.sanctionNumber,
    required this.projectCode,
    required this.agencyCode,
    required this.stateCode,
    this.utrNumber,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'pfmsId': pfmsId,
      'transactionId': transactionId,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'purpose': purpose,
      'sanctionNumber': sanctionNumber,
      'projectCode': projectCode,
      'agencyCode': agencyCode,
      'stateCode': stateCode,
      'utrNumber': utrNumber,
      'metadata': metadata,
    };
  }

  factory PFMSRecord.fromJson(Map<String, dynamic> json) {
    return PFMSRecord(
      pfmsId: json['pfmsId'],
      transactionId: json['transactionId'],
      amount: json['amount'].toDouble(),
      transactionDate: DateTime.parse(json['transactionDate']),
      fromAccount: json['fromAccount'],
      toAccount: json['toAccount'],
      purpose: json['purpose'],
      sanctionNumber: json['sanctionNumber'],
      projectCode: json['projectCode'],
      agencyCode: json['agencyCode'],
      stateCode: json['stateCode'],
      utrNumber: json['utrNumber'],
      metadata: json['metadata'],
    );
  }
}

/// Bank statement transaction record
class BankRecord {
  final String bankTransactionId;
  final String accountNumber;
  final double amount;
  final DateTime valueDate;
  final DateTime transactionDate;
  final String description;
  final String? utrNumber;
  final String? chequeNumber;
  final String transactionType; // Credit/Debit
  final double runningBalance;
  final String? counterPartyAccount;
  final String? ifscCode;
  final Map<String, dynamic>? metadata;

  BankRecord({
    required this.bankTransactionId,
    required this.accountNumber,
    required this.amount,
    required this.valueDate,
    required this.transactionDate,
    required this.description,
    this.utrNumber,
    this.chequeNumber,
    required this.transactionType,
    required this.runningBalance,
    this.counterPartyAccount,
    this.ifscCode,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'bankTransactionId': bankTransactionId,
      'accountNumber': accountNumber,
      'amount': amount,
      'valueDate': valueDate.toIso8601String(),
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'utrNumber': utrNumber,
      'chequeNumber': chequeNumber,
      'transactionType': transactionType,
      'runningBalance': runningBalance,
      'counterPartyAccount': counterPartyAccount,
      'ifscCode': ifscCode,
      'metadata': metadata,
    };
  }

  factory BankRecord.fromJson(Map<String, dynamic> json) {
    return BankRecord(
      bankTransactionId: json['bankTransactionId'],
      accountNumber: json['accountNumber'],
      amount: json['amount'].toDouble(),
      valueDate: DateTime.parse(json['valueDate']),
      transactionDate: DateTime.parse(json['transactionDate']),
      description: json['description'],
      utrNumber: json['utrNumber'],
      chequeNumber: json['chequeNumber'],
      transactionType: json['transactionType'],
      runningBalance: json['runningBalance'].toDouble(),
      counterPartyAccount: json['counterPartyAccount'],
      ifscCode: json['ifscCode'],
      metadata: json['metadata'],
    );
  }
}

/// Reconciliation entry combining PFMS and Bank records
class ReconciliationEntry {
  final String reconciliationId;
  final PFMSRecord? pfmsRecord;
  final BankRecord? bankRecord;
  final ReconciliationStatus status;
  final DateTime reconciliationDate;
  final List<String> discrepancies;
  final double? amountDifference;
  final int? dateDifference; // Days difference
  final String? matchedBy; // UTR, Amount, Date, etc.
  final double confidenceScore; // 0-100
  final List<DisputeEntry> disputes;
  final DateTime? resolvedDate;
  final String? resolvedBy;
  final String? resolutionNotes;
  final Map<String, dynamic>? metadata;

  ReconciliationEntry({
    required this.reconciliationId,
    this.pfmsRecord,
    this.bankRecord,
    required this.status,
    required this.reconciliationDate,
    this.discrepancies = const [],
    this.amountDifference,
    this.dateDifference,
    this.matchedBy,
    this.confidenceScore = 0,
    this.disputes = const [],
    this.resolvedDate,
    this.resolvedBy,
    this.resolutionNotes,
    this.metadata,
  });

  bool get hasDiscrepancies => discrepancies.isNotEmpty;
  bool get isPerfectMatch => status == ReconciliationStatus.matched && confidenceScore >= 95;
  bool get isOrphanPFMS => pfmsRecord != null && bankRecord == null;
  bool get isOrphanBank => bankRecord == null && pfmsRecord != null;

  double get displayAmount => pfmsRecord?.amount ?? bankRecord?.amount ?? 0.0;
  DateTime get displayDate => pfmsRecord?.transactionDate ?? bankRecord?.transactionDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'reconciliationId': reconciliationId,
      'pfmsRecord': pfmsRecord?.toJson(),
      'bankRecord': bankRecord?.toJson(),
      'status': status.name,
      'reconciliationDate': reconciliationDate.toIso8601String(),
      'discrepancies': discrepancies,
      'amountDifference': amountDifference,
      'dateDifference': dateDifference,
      'matchedBy': matchedBy,
      'confidenceScore': confidenceScore,
      'disputes': disputes.map((d) => d.toJson()).toList(),
      'resolvedDate': resolvedDate?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
      'metadata': metadata,
    };
  }
}

/// Dispute workflow entry
class DisputeEntry {
  final String disputeId;
  final DateTime raisedDate;
  final String raisedBy;
  final String disputeType; // Amount, Date, Missing Record, etc.
  final String description;
  final List<String> attachments;
  final String status; // Open, In Progress, Resolved, Closed
  final String? assignedTo;
  final DateTime? targetResolutionDate;
  final List<DisputeComment> comments;
  final String? resolution;
  final DateTime? resolvedDate;

  DisputeEntry({
    required this.disputeId,
    required this.raisedDate,
    required this.raisedBy,
    required this.disputeType,
    required this.description,
    this.attachments = const [],
    this.status = 'Open',
    this.assignedTo,
    this.targetResolutionDate,
    this.comments = const [],
    this.resolution,
    this.resolvedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'disputeId': disputeId,
      'raisedDate': raisedDate.toIso8601String(),
      'raisedBy': raisedBy,
      'disputeType': disputeType,
      'description': description,
      'attachments': attachments,
      'status': status,
      'assignedTo': assignedTo,
      'targetResolutionDate': targetResolutionDate?.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'resolution': resolution,
      'resolvedDate': resolvedDate?.toIso8601String(),
    };
  }
}

/// Comment on a dispute
class DisputeComment {
  final String commentId;
  final DateTime timestamp;
  final String author;
  final String comment;
  final List<String> attachments;

  DisputeComment({
    required this.commentId,
    required this.timestamp,
    required this.author,
    required this.comment,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'timestamp': timestamp.toIso8601String(),
      'author': author,
      'comment': comment,
      'attachments': attachments,
    };
  }
}

/// Summary statistics for reconciliation
class ReconciliationSummary {
  final int totalRecords;
  final int matchedRecords;
  final int mismatchedRecords;
  final int pendingRecords;
  final int disputedRecords;
  final double totalAmount;
  final double matchedAmount;
  final double mismatchedAmount;
  final double pendingAmount;
  final double averageConfidenceScore;
  final DateTime reportDate;
  final Map<String, int> discrepancyBreakdown;

  ReconciliationSummary({
    required this.totalRecords,
    required this.matchedRecords,
    required this.mismatchedRecords,
    required this.pendingRecords,
    required this.disputedRecords,
    required this.totalAmount,
    required this.matchedAmount,
    required this.mismatchedAmount,
    required this.pendingAmount,
    required this.averageConfidenceScore,
    required this.reportDate,
    required this.discrepancyBreakdown,
  });

  double get matchPercentage => totalRecords > 0 ? (matchedRecords / totalRecords) * 100 : 0;
  double get amountMatchPercentage => totalAmount > 0 ? (matchedAmount / totalAmount) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'totalRecords': totalRecords,
      'matchedRecords': matchedRecords,
      'mismatchedRecords': mismatchedRecords,
      'pendingRecords': pendingRecords,
      'disputedRecords': disputedRecords,
      'totalAmount': totalAmount,
      'matchedAmount': matchedAmount,
      'mismatchedAmount': mismatchedAmount,
      'pendingAmount': pendingAmount,
      'averageConfidenceScore': averageConfidenceScore,
      'reportDate': reportDate.toIso8601String(),
      'discrepancyBreakdown': discrepancyBreakdown,
    };
  }
}