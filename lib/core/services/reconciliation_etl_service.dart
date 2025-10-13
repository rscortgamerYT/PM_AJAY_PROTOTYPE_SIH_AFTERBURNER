import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/reconciliation_models.dart';

/// Service for automated ETL processing of PFMS and Bank data
class ReconciliationETLService {
  static const String _logTag = 'ReconciliationETL';
  
  /// Process PFMS CSV data
  static Future<List<PFMSRecord>> processPFMSData(String csvContent) async {
    try {
      final List<PFMSRecord> records = [];
      final lines = csvContent.split('\n');
      
      if (lines.isEmpty) return records;
      
      // Skip header row
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final values = _parseCSVLine(line);
        if (values.length >= 10) {
          try {
            final record = PFMSRecord(
              pfmsId: values[0],
              transactionId: values[1],
              amount: double.parse(values[2]),
              transactionDate: DateTime.parse(values[3]),
              fromAccount: values[4],
              toAccount: values[5],
              purpose: values[6],
              sanctionNumber: values[7],
              projectCode: values[8],
              agencyCode: values[9],
              stateCode: values.length > 10 ? values[10] : '',
              utrNumber: values.length > 11 ? values[11] : null,
            );
            records.add(record);
          } catch (e) {
            debugPrint('$_logTag: Error parsing PFMS record at line $i: $e');
          }
        }
      }
      
      return records;
    } catch (e) {
      debugPrint('$_logTag: Error processing PFMS data: $e');
      return [];
    }
  }
  
  /// Process Bank CSV data
  static Future<List<BankRecord>> processBankData(String csvContent) async {
    try {
      final List<BankRecord> records = [];
      final lines = csvContent.split('\n');
      
      if (lines.isEmpty) return records;
      
      // Skip header row
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final values = _parseCSVLine(line);
        if (values.length >= 8) {
          try {
            final record = BankRecord(
              bankTransactionId: values[0],
              accountNumber: values[1],
              amount: double.parse(values[2]),
              valueDate: DateTime.parse(values[3]),
              transactionDate: DateTime.parse(values[4]),
              description: values[5],
              transactionType: values[6],
              runningBalance: double.parse(values[7]),
              utrNumber: values.length > 8 ? values[8] : null,
              chequeNumber: values.length > 9 ? values[9] : null,
              counterPartyAccount: values.length > 10 ? values[10] : null,
              ifscCode: values.length > 11 ? values[11] : null,
            );
            records.add(record);
          } catch (e) {
            debugPrint('$_logTag: Error parsing Bank record at line $i: $e');
          }
        }
      }
      
      return records;
    } catch (e) {
      debugPrint('$_logTag: Error processing Bank data: $e');
      return [];
    }
  }
  
  /// Perform automated reconciliation between PFMS and Bank records
  static Future<List<ReconciliationEntry>> performReconciliation(
    List<PFMSRecord> pfmsRecords,
    List<BankRecord> bankRecords,
  ) async {
    final List<ReconciliationEntry> reconciliations = [];
    final Set<String> matchedBankIds = <String>{};
    final Set<String> matchedPFMSIds = <String>{};
    
    // First pass: Perfect matches by UTR number
    for (final pfms in pfmsRecords) {
      if (pfms.utrNumber != null && pfms.utrNumber!.isNotEmpty) {
        final matchingBank = bankRecords.firstWhere(
          (bank) => bank.utrNumber == pfms.utrNumber,
          orElse: () => BankRecord(
            bankTransactionId: '',
            accountNumber: '',
            amount: 0,
            valueDate: DateTime.now(),
            transactionDate: DateTime.now(),
            description: '',
            transactionType: '',
            runningBalance: 0,
          ),
        );
        
        if (matchingBank.bankTransactionId.isNotEmpty) {
          final reconciliation = _createReconciliationEntry(
            pfms,
            matchingBank,
            matchedBy: 'UTR',
          );
          reconciliations.add(reconciliation);
          matchedBankIds.add(matchingBank.bankTransactionId);
          matchedPFMSIds.add(pfms.pfmsId);
        }
      }
    }
    
    // Second pass: Amount and date matching
    for (final pfms in pfmsRecords) {
      if (matchedPFMSIds.contains(pfms.pfmsId)) continue;
      
      final potentialMatches = bankRecords.where((bank) => 
        !matchedBankIds.contains(bank.bankTransactionId) &&
        (bank.amount - pfms.amount).abs() <= 0.01 && // Allow 1 paisa difference
        bank.transactionDate.difference(pfms.transactionDate).inDays.abs() <= 3
      ).toList();
      
      if (potentialMatches.isNotEmpty) {
        // Take the closest date match
        potentialMatches.sort((a, b) => 
          a.transactionDate.difference(pfms.transactionDate).inDays.abs().compareTo(
            b.transactionDate.difference(pfms.transactionDate).inDays.abs()
          )
        );
        
        final matchingBank = potentialMatches.first;
        final reconciliation = _createReconciliationEntry(
          pfms,
          matchingBank,
          matchedBy: 'Amount+Date',
        );
        reconciliations.add(reconciliation);
        matchedBankIds.add(matchingBank.bankTransactionId);
        matchedPFMSIds.add(pfms.pfmsId);
      }
    }
    
    // Third pass: Create orphan records for unmatched PFMS entries
    for (final pfms in pfmsRecords) {
      if (!matchedPFMSIds.contains(pfms.pfmsId)) {
        final reconciliation = ReconciliationEntry(
          reconciliationId: _generateReconciliationId(),
          pfmsRecord: pfms,
          bankRecord: null,
          status: ReconciliationStatus.mismatched,
          reconciliationDate: DateTime.now(),
          discrepancies: ['Missing bank record'],
          confidenceScore: 0,
        );
        reconciliations.add(reconciliation);
      }
    }
    
    // Fourth pass: Create orphan records for unmatched Bank entries
    for (final bank in bankRecords) {
      if (!matchedBankIds.contains(bank.bankTransactionId)) {
        final reconciliation = ReconciliationEntry(
          reconciliationId: _generateReconciliationId(),
          pfmsRecord: null,
          bankRecord: bank,
          status: ReconciliationStatus.mismatched,
          reconciliationDate: DateTime.now(),
          discrepancies: ['Missing PFMS record'],
          confidenceScore: 0,
        );
        reconciliations.add(reconciliation);
      }
    }
    
    return reconciliations;
  }
  
  /// Create a reconciliation entry with discrepancy analysis
  static ReconciliationEntry _createReconciliationEntry(
    PFMSRecord pfms,
    BankRecord bank,
    {required String matchedBy}
  ) {
    final List<String> discrepancies = [];
    double confidenceScore = 100;
    
    // Check amount discrepancy
    final amountDiff = (bank.amount - pfms.amount).abs();
    if (amountDiff > 0.01) {
      discrepancies.add('Amount mismatch: ₹${amountDiff.toStringAsFixed(2)}');
      confidenceScore -= 30;
    }
    
    // Check date discrepancy
    final dateDiff = bank.transactionDate.difference(pfms.transactionDate).inDays.abs();
    if (dateDiff > 0) {
      discrepancies.add('Date difference: $dateDiff days');
      confidenceScore -= dateDiff * 5;
    }
    
    // Check account matching
    if (!bank.description.contains(pfms.projectCode) && 
        !bank.description.contains(pfms.sanctionNumber)) {
      discrepancies.add('Project code not found in bank description');
      confidenceScore -= 10;
    }
    
    confidenceScore = max(0, confidenceScore);
    
    return ReconciliationEntry(
      reconciliationId: _generateReconciliationId(),
      pfmsRecord: pfms,
      bankRecord: bank,
      status: discrepancies.isEmpty 
        ? ReconciliationStatus.matched 
        : ReconciliationStatus.mismatched,
      reconciliationDate: DateTime.now(),
      discrepancies: discrepancies,
      amountDifference: amountDiff,
      dateDifference: dateDiff,
      matchedBy: matchedBy,
      confidenceScore: confidenceScore,
    );
  }
  
  /// Generate summary statistics
  static ReconciliationSummary generateSummary(List<ReconciliationEntry> reconciliations) {
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
    
    // Breakdown discrepancies
    final discrepancyBreakdown = <String, int>{};
    for (final reconciliation in reconciliations) {
      for (final discrepancy in reconciliation.discrepancies) {
        final key = discrepancy.split(':')[0]; // Get the discrepancy type
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
  
  /// Helper method to parse CSV line with comma separation
  static List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    String current = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    if (current.isNotEmpty) {
      result.add(current.trim());
    }
    
    return result;
  }
  
  /// Generate unique reconciliation ID
  static String _generateReconciliationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'REC_${timestamp}_$random';
  }
  
  /// Simulate daily ETL job (for demo purposes)
  static Future<List<ReconciliationEntry>> simulateDailyReconciliation() async {
    // Simulate fetching data from PFMS and Bank APIs
    await Future.delayed(const Duration(seconds: 2));
    
    final pfmsData = await _generateMockPFMSData();
    final bankData = await _generateMockBankData();
    
    return await performReconciliation(pfmsData, bankData);
  }
  
  /// Generate mock PFMS data for demo
  static Future<List<PFMSRecord>> _generateMockPFMSData() async {
    final random = Random();
    final List<PFMSRecord> records = [];
    
    for (int i = 0; i < 50; i++) {
      final amount = (random.nextDouble() * 1000000) + 10000; // 10K to 1M
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      
      records.add(PFMSRecord(
        pfmsId: 'PFMS_${DateTime.now().millisecondsSinceEpoch}_$i',
        transactionId: 'TXN_${random.nextInt(999999)}',
        amount: amount,
        transactionDate: date,
        fromAccount: '1234567890',
        toAccount: '0987654321',
        purpose: 'Project Implementation - Phase ${i % 3 + 1}',
        sanctionNumber: 'SANC_${random.nextInt(99999)}',
        projectCode: 'PROJ_${random.nextInt(999)}',
        agencyCode: 'AG_${random.nextInt(99)}',
        stateCode: 'ST_${random.nextInt(35)}',
        utrNumber: random.nextBool() ? 'UTR${random.nextInt(9999999999)}' : null,
      ));
    }
    
    return records;
  }
  
  /// Generate mock Bank data for demo
  static Future<List<BankRecord>> _generateMockBankData() async {
    final random = Random();
    final List<BankRecord> records = [];
    
    for (int i = 0; i < 45; i++) { // Intentionally fewer to create mismatches
      final amount = (random.nextDouble() * 1000000) + 10000;
      final date = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      
      records.add(BankRecord(
        bankTransactionId: 'BANK_${DateTime.now().millisecondsSinceEpoch}_$i',
        accountNumber: '0987654321',
        amount: amount,
        valueDate: date,
        transactionDate: date,
        description: 'Government Transfer - PROJ_${random.nextInt(999)}',
        transactionType: 'Credit',
        runningBalance: amount + (random.nextDouble() * 10000000),
        utrNumber: random.nextBool() ? 'UTR${random.nextInt(9999999999)}' : null,
        counterPartyAccount: '1234567890',
        ifscCode: 'SBIN0001234',
      ));
    }
    
    return records;
  }
}