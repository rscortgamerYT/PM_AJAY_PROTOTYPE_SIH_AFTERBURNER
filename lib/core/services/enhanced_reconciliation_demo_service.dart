import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/reconciliation_models.dart';

/// Enhanced demo service for reconciliation with realistic state government scenarios
class EnhancedReconciliationDemoService {
  static const String _logTag = 'EnhancedReconciliationDemo';
  
  // State-specific data for realistic demo
  static const List<String> _states = [
    'AP', 'AR', 'AS', 'BR', 'CG', 'GA', 'GJ', 'HR', 'HP', 'JH',
    'KA', 'KL', 'MP', 'MH', 'MN', 'ML', 'MZ', 'NL', 'OD', 'PB',
    'RJ', 'SK', 'TN', 'TS', 'TR', 'UP', 'UK', 'WB', 'AN', 'CH',
    'DH', 'DD', 'DL', 'JK', 'LA', 'LD', 'PY'
  ];
  
  static const List<String> _projectTypes = [
    'Rural Development', 'Healthcare Infrastructure', 'Education Modernization',
    'Water Supply', 'Road Construction', 'Digital Governance', 'Skill Development',
    'Agricultural Support', 'Urban Development', 'Renewable Energy',
    'Social Welfare', 'Industrial Development'
  ];
  
  static const List<String> _agencies = [
    'Public Works Department', 'Health & Family Welfare', 'Education Department',
    'Rural Development Agency', 'Urban Development Authority', 'IT Department',
    'Agriculture Department', 'Social Welfare Department', 'Transport Department',
    'Energy Department', 'Water Resources Department', 'Industries Department'
  ];
  
  static const List<String> _bankNames = [
    'State Bank of India', 'Punjab National Bank', 'Bank of Baroda',
    'Union Bank of India', 'Indian Bank', 'Central Bank of India',
    'Bank of India', 'Canara Bank', 'Indian Overseas Bank', 'UCO Bank'
  ];
  
  /// Generate comprehensive reconciliation demo data
  static Future<List<ReconciliationEntry>> generateEnhancedDemoData() async {
    debugPrint('$_logTag: Generating enhanced demo reconciliation data...');
    
    final random = Random();
    final List<ReconciliationEntry> reconciliations = [];
    final DateTime baseDate = DateTime.now().subtract(const Duration(days: 30));
    
    // Generate matched records (70% of total)
    for (int i = 0; i < 35; i++) {
      final pfmsRecord = _generatePFMSRecord(i, baseDate, random);
      final bankRecord = _generateMatchingBankRecord(pfmsRecord, random);
      
      final reconciliation = ReconciliationEntry(
        reconciliationId: 'REC_${DateTime.now().millisecondsSinceEpoch}_$i',
        pfmsRecord: pfmsRecord,
        bankRecord: bankRecord,
        status: ReconciliationStatus.matched,
        reconciliationDate: DateTime.now().subtract(Duration(hours: random.nextInt(48))),
        discrepancies: [],
        amountDifference: 0.0,
        dateDifference: 0,
        matchedBy: random.nextBool() ? 'UTR' : 'Amount+Date',
        confidenceScore: 95 + random.nextDouble() * 5,
        metadata: {
          'auto_matched': true,
          'verification_status': 'verified',
          'last_updated': DateTime.now().toIso8601String(),
        },
      );
      
      reconciliations.add(reconciliation);
    }
    
    // Generate mismatched records (20% of total)
    for (int i = 35; i < 45; i++) {
      final pfmsRecord = _generatePFMSRecord(i, baseDate, random);
      final bankRecord = _generateMismatchedBankRecord(pfmsRecord, random);
      
      final List<String> discrepancies = [];
      final amountDiff = (bankRecord.amount - pfmsRecord.amount).abs();
      final dateDiff = bankRecord.transactionDate.difference(pfmsRecord.transactionDate).inDays.abs();
      
      if (amountDiff > 0.01) {
        discrepancies.add('Amount mismatch: ₹${amountDiff.toStringAsFixed(2)}');
      }
      if (dateDiff > 0) {
        discrepancies.add('Date difference: $dateDiff days');
      }
      if (!bankRecord.description.contains(pfmsRecord.projectCode)) {
        discrepancies.add('Project code not found in bank description');
      }
      
      final reconciliation = ReconciliationEntry(
        reconciliationId: 'REC_${DateTime.now().millisecondsSinceEpoch}_$i',
        pfmsRecord: pfmsRecord,
        bankRecord: bankRecord,
        status: ReconciliationStatus.mismatched,
        reconciliationDate: DateTime.now().subtract(Duration(hours: random.nextInt(72))),
        discrepancies: discrepancies,
        amountDifference: amountDiff,
        dateDifference: dateDiff,
        matchedBy: 'Amount+Date',
        confidenceScore: 30 + random.nextDouble() * 40,
        metadata: {
          'requires_review': true,
          'escalation_level': random.nextInt(3) + 1,
        },
      );
      
      reconciliations.add(reconciliation);
    }
    
    // Generate orphan PFMS records (5% of total)
    for (int i = 45; i < 48; i++) {
      final pfmsRecord = _generatePFMSRecord(i, baseDate, random);
      
      final reconciliation = ReconciliationEntry(
        reconciliationId: 'REC_${DateTime.now().millisecondsSinceEpoch}_$i',
        pfmsRecord: pfmsRecord,
        bankRecord: null,
        status: ReconciliationStatus.pending,
        reconciliationDate: DateTime.now().subtract(Duration(hours: random.nextInt(96))),
        discrepancies: ['Missing bank record - Transaction may be pending'],
        amountDifference: null,
        dateDifference: null,
        matchedBy: null,
        confidenceScore: 0,
        metadata: {
          'orphan_type': 'pfms_only',
          'follow_up_required': true,
          'days_pending': random.nextInt(7) + 1,
        },
      );
      
      reconciliations.add(reconciliation);
    }
    
    // Generate orphan Bank records (3% of total)
    for (int i = 48; i < 50; i++) {
      final bankRecord = _generateOrphanBankRecord(i, baseDate, random);
      
      final reconciliation = ReconciliationEntry(
        reconciliationId: 'REC_${DateTime.now().millisecondsSinceEpoch}_$i',
        pfmsRecord: null,
        bankRecord: bankRecord,
        status: ReconciliationStatus.investigating,
        reconciliationDate: DateTime.now().subtract(Duration(hours: random.nextInt(120))),
        discrepancies: ['Missing PFMS record - Possible unauthorized transaction'],
        amountDifference: null,
        dateDifference: null,
        matchedBy: null,
        confidenceScore: 0,
        metadata: {
          'orphan_type': 'bank_only',
          'security_review': true,
          'alert_level': 'high',
        },
      );
      
      reconciliations.add(reconciliation);
    }
    
    // Generate disputed records (2% of total)
    for (int i = 50; i < 52; i++) {
      final pfmsRecord = _generatePFMSRecord(i, baseDate, random);
      final bankRecord = _generateMismatchedBankRecord(pfmsRecord, random);
      
      final dispute = DisputeEntry(
        disputeId: 'DISP_${DateTime.now().millisecondsSinceEpoch}_$i',
        raisedDate: DateTime.now().subtract(Duration(days: random.nextInt(5) + 1)),
        raisedBy: 'State Finance Officer',
        disputeType: 'Amount Discrepancy',
        description: 'Significant amount difference requires manual verification',
        status: 'In Progress',
        assignedTo: 'Senior Reconciliation Analyst',
        targetResolutionDate: DateTime.now().add(const Duration(days: 3)),
        comments: [
          DisputeComment(
            commentId: 'COM_${i}_1',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            author: 'System Admin',
            comment: 'Dispute raised due to amount variance exceeding threshold',
          ),
        ],
      );
      
      final reconciliation = ReconciliationEntry(
        reconciliationId: 'REC_${DateTime.now().millisecondsSinceEpoch}_$i',
        pfmsRecord: pfmsRecord,
        bankRecord: bankRecord,
        status: ReconciliationStatus.disputed,
        reconciliationDate: DateTime.now().subtract(Duration(hours: random.nextInt(48))),
        discrepancies: ['Amount variance exceeds acceptable threshold'],
        amountDifference: (bankRecord.amount - pfmsRecord.amount).abs(),
        dateDifference: 0,
        matchedBy: 'Amount+Date',
        confidenceScore: 15 + random.nextDouble() * 25,
        disputes: [dispute],
        metadata: {
          'dispute_count': 1,
          'priority': 'high',
          'sla_deadline': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        },
      );
      
      reconciliations.add(reconciliation);
    }
    
    debugPrint('$_logTag: Generated ${reconciliations.length} reconciliation records');
    return reconciliations;
  }
  
  static PFMSRecord _generatePFMSRecord(int index, DateTime baseDate, Random random) {
    final stateCode = _states[random.nextInt(_states.length)];
    final projectType = _projectTypes[random.nextInt(_projectTypes.length)];
    final agency = _agencies[random.nextInt(_agencies.length)];
    
    final amount = _generateRealisticAmount(random);
    final transactionDate = baseDate.add(Duration(days: random.nextInt(30)));
    
    return PFMSRecord(
      pfmsId: 'PFMS_${stateCode}_${DateTime.now().millisecondsSinceEpoch}_$index',
      transactionId: 'TXN_${stateCode}_${random.nextInt(999999).toString().padLeft(6, '0')}',
      amount: amount,
      transactionDate: transactionDate,
      fromAccount: '12345${random.nextInt(99999).toString().padLeft(5, '0')}',
      toAccount: '67890${random.nextInt(99999).toString().padLeft(5, '0')}',
      purpose: '$projectType - $agency Implementation',
      sanctionNumber: 'SANC_${stateCode}_${random.nextInt(99999).toString().padLeft(5, '0')}',
      projectCode: '${stateCode}_${projectType.replaceAll(' ', '').substring(0, 3).toUpperCase()}_${random.nextInt(999).toString().padLeft(3, '0')}',
      agencyCode: 'AG_${stateCode}_${random.nextInt(99).toString().padLeft(2, '0')}',
      stateCode: stateCode,
      utrNumber: random.nextBool() ? 'UTR${random.nextInt(999999999).toString().padLeft(9, '0')}${random.nextInt(999).toString().padLeft(3, '0')}' : null,
      metadata: {
        'project_type': projectType,
        'agency_name': agency,
        'fiscal_year': '2024-25',
        'scheme_code': 'SCH_${random.nextInt(9999)}',
        'beneficiary_count': random.nextInt(10000) + 100,
      },
    );
  }
  
  static BankRecord _generateMatchingBankRecord(PFMSRecord pfmsRecord, Random random) {
    // Perfect match or slight variation
    final amountVariation = random.nextBool() ? 0.0 : (random.nextDouble() - 0.5) * 0.02; // ±1 paisa
    final dateVariation = random.nextBool() ? 0 : random.nextInt(2); // 0-1 day difference
    
    final bankName = _bankNames[random.nextInt(_bankNames.length)];
    
    return BankRecord(
      bankTransactionId: 'BANK_${pfmsRecord.stateCode}_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999)}',
      accountNumber: pfmsRecord.toAccount,
      amount: pfmsRecord.amount + amountVariation,
      valueDate: pfmsRecord.transactionDate.add(Duration(days: dateVariation)),
      transactionDate: pfmsRecord.transactionDate.add(Duration(days: dateVariation)),
      description: 'Govt Transfer - ${pfmsRecord.projectCode} - ${pfmsRecord.sanctionNumber}',
      transactionType: 'Credit',
      runningBalance: pfmsRecord.amount + (random.nextDouble() * 10000000),
      utrNumber: pfmsRecord.utrNumber,
      counterPartyAccount: pfmsRecord.fromAccount,
      ifscCode: '${bankName.substring(0, 4).toUpperCase().replaceAll(' ', '')}0${random.nextInt(999999).toString().padLeft(6, '0')}',
      metadata: {
        'bank_name': bankName,
        'branch_code': 'BR_${random.nextInt(9999).toString().padLeft(4, '0')}',
        'processing_date': DateTime.now().toIso8601String(),
        'verified': true,
      },
    );
  }
  
  static BankRecord _generateMismatchedBankRecord(PFMSRecord pfmsRecord, Random random) {
    // Intentional mismatches for demo
    final amountVariation = (random.nextDouble() * 10000) + 100; // Significant difference
    final dateVariation = random.nextInt(7) + 1; // 1-7 days difference
    
    final bankName = _bankNames[random.nextInt(_bankNames.length)];
    
    return BankRecord(
      bankTransactionId: 'BANK_${pfmsRecord.stateCode}_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999)}',
      accountNumber: pfmsRecord.toAccount,
      amount: pfmsRecord.amount + (random.nextBool() ? amountVariation : -amountVariation),
      valueDate: pfmsRecord.transactionDate.add(Duration(days: dateVariation)),
      transactionDate: pfmsRecord.transactionDate.add(Duration(days: dateVariation)),
      description: random.nextBool() 
        ? 'Govt Transfer - ${pfmsRecord.projectCode} - Different Sanction'
        : 'Government Payment - Partial ${pfmsRecord.sanctionNumber}',
      transactionType: 'Credit',
      runningBalance: pfmsRecord.amount + (random.nextDouble() * 5000000),
      utrNumber: random.nextBool() ? pfmsRecord.utrNumber : 'UTR${random.nextInt(999999999)}',
      counterPartyAccount: pfmsRecord.fromAccount,
      ifscCode: '${bankName.substring(0, 4).toUpperCase().replaceAll(' ', '')}0${random.nextInt(999999).toString().padLeft(6, '0')}',
      metadata: {
        'bank_name': bankName,
        'branch_code': 'BR_${random.nextInt(9999).toString().padLeft(4, '0')}',
        'processing_date': DateTime.now().toIso8601String(),
        'verified': false,
        'requires_manual_review': true,
      },
    );
  }
  
  static BankRecord _generateOrphanBankRecord(int index, DateTime baseDate, Random random) {
    final stateCode = _states[random.nextInt(_states.length)];
    final amount = _generateRealisticAmount(random);
    final transactionDate = baseDate.add(Duration(days: random.nextInt(30)));
    final bankName = _bankNames[random.nextInt(_bankNames.length)];
    
    return BankRecord(
      bankTransactionId: 'BANK_ORPHAN_${stateCode}_${DateTime.now().millisecondsSinceEpoch}_$index',
      accountNumber: '99999${random.nextInt(99999).toString().padLeft(5, '0')}',
      amount: amount,
      valueDate: transactionDate,
      transactionDate: transactionDate,
      description: 'Unidentified Government Credit - Investigation Required',
      transactionType: 'Credit',
      runningBalance: amount + (random.nextDouble() * 8000000),
      utrNumber: 'UTR${random.nextInt(999999999)}',
      counterPartyAccount: 'UNKNOWN_ACCOUNT',
      ifscCode: '${bankName.substring(0, 4).toUpperCase().replaceAll(' ', '')}0${random.nextInt(999999).toString().padLeft(6, '0')}',
      metadata: {
        'bank_name': bankName,
        'investigation_status': 'pending',
        'alert_raised': true,
        'suspicious_activity': false,
      },
    );
  }
  
  static double _generateRealisticAmount(Random random) {
    final amountTypes = [
      () => (random.nextDouble() * 50000) + 10000, // Small projects: 10K-60K
      () => (random.nextDouble() * 500000) + 100000, // Medium projects: 100K-600K
      () => (random.nextDouble() * 5000000) + 1000000, // Large projects: 1M-6M
      () => (random.nextDouble() * 50000000) + 10000000, // Major projects: 10M-60M
    ];
    
    final amountType = amountTypes[random.nextInt(amountTypes.length)];
    return double.parse(amountType().toStringAsFixed(2));
  }
  
  /// Generate summary with realistic state government metrics
  static ReconciliationSummary generateEnhancedSummary(List<ReconciliationEntry> reconciliations) {
    final totalRecords = reconciliations.length;
    final matchedRecords = reconciliations.where((r) => r.status == ReconciliationStatus.matched).length;
    final mismatchedRecords = reconciliations.where((r) => r.status == ReconciliationStatus.mismatched).length;
    final pendingRecords = reconciliations.where((r) => r.status == ReconciliationStatus.pending).length;
    final disputedRecords = reconciliations.where((r) => r.status == ReconciliationStatus.disputed).length;
    
    final totalAmount = reconciliations.fold(0.0, (sum, r) => sum + r.displayAmount);
    final matchedAmount = reconciliations
        .where((r) => r.status == ReconciliationStatus.matched)
        .fold(0.0, (sum, r) => sum + r.displayAmount);
    final mismatchedAmount = reconciliations
        .where((r) => r.status == ReconciliationStatus.mismatched)
        .fold(0.0, (sum, r) => sum + r.displayAmount);
    final pendingAmount = reconciliations
        .where((r) => r.status == ReconciliationStatus.pending)
        .fold(0.0, (sum, r) => sum + r.displayAmount);
    
    final averageConfidenceScore = reconciliations.isNotEmpty
        ? reconciliations.fold(0.0, (sum, r) => sum + r.confidenceScore) / reconciliations.length
        : 0.0;
    
    // Enhanced discrepancy breakdown for state government context
    final discrepancyBreakdown = <String, int>{};
    for (final reconciliation in reconciliations) {
      for (final discrepancy in reconciliation.discrepancies) {
        var key = discrepancy.split(':')[0];
        // Normalize common discrepancy types
        if (key.contains('Amount')) key = 'Amount Mismatch';
        if (key.contains('Date')) key = 'Date Variance';
        if (key.contains('Missing')) {
          key = discrepancy.contains('bank') ? 'Missing Bank Record' : 'Missing PFMS Record';
        }
        if (key.contains('Project')) key = 'Project Code Mismatch';
        
        discrepancyBreakdown[key] = (discrepancyBreakdown[key] ?? 0) + 1;
      }
    }
    
    return ReconciliationSummary(
      totalRecords: totalRecords,
      matchedRecords: matchedRecords,
      mismatchedRecords: mismatchedRecords,
      pendingRecords: pendingRecords,
      disputedRecords: disputedRecords,
      totalAmount: totalAmount,
      matchedAmount: matchedAmount,
      mismatchedAmount: mismatchedAmount,
      pendingAmount: pendingAmount,
      averageConfidenceScore: averageConfidenceScore,
      reportDate: DateTime.now(),
      discrepancyBreakdown: discrepancyBreakdown,
    );
  }
}