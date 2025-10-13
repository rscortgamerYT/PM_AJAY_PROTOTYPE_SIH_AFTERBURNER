import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/blockchain_models.dart';

/// Blockchain service for managing immutable audit trails, document hashing, and smart contracts
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // Mock Ethereum Goerli testnet configuration
  static const String _goerliRpcUrl = 'https://goerli.infura.io/v3/YOUR_PROJECT_ID';
  static const String _auditContractAddress = '0x742d35Cc6634C0532925a3b8D23d';
  static const String _documentRegistryAddress = '0x5aAeb6053F3E2DdC8C53C94f';
  static const String _releaseContractAddress = '0x14723A09ACff6D2A60DcdF7';

  // In-memory cache for demo purposes
  final List<BlockchainTransaction> _transactions = [];
  final List<DocumentHashRecord> _documentHashes = [];
  final List<SmartContractRelease> _smartReleases = [];

  /// Initialize blockchain service with mock data
  Future<void> initialize() async {
    await _generateMockData();
  }

  /// Submit transaction hash to blockchain audit trail
  Future<BlockchainTransaction> anchorTransactionHash({
    required String transactionId,
    required Map<String, dynamic> transactionData,
    required String dataType,
  }) async {
    try {
      // Compute SHA-256 hash of transaction data
      final dataString = jsonEncode(transactionData);
      final dataHash = sha256.convert(utf8.encode(dataString)).toString();

      // Simulate blockchain submission
      await Future.delayed(const Duration(milliseconds: 500));
      
      final blockchainTx = BlockchainTransaction(
        id: 'btx_${DateTime.now().millisecondsSinceEpoch}',
        transactionHash: _generateMockTxHash(),
        blockHash: _generateMockBlockHash(),
        blockNumber: '${18500000 + _transactions.length}',
        contractAddress: _auditContractAddress,
        timestamp: DateTime.now(),
        dataHash: dataHash,
        metadata: {
          'transaction_id': transactionId,
          'data_type': dataType,
          'gas_used': '21000',
          'gas_price': '20',
        },
        status: 'confirmed',
      );

      _transactions.add(blockchainTx);
      return blockchainTx;
    } catch (e) {
      throw Exception('Failed to anchor transaction hash: $e');
    }
  }

  /// Register document hash on blockchain
  Future<DocumentHashRecord> registerDocumentHash({
    required String documentId,
    required String fileName,
    required List<int> fileBytes,
    required String uploaderUserId,
  }) async {
    try {
      // Compute file hash
      final fileHash = sha256.convert(fileBytes).toString();
      
      // Simulate IPFS upload
      final ipfsCid = _generateMockIpfsCid();
      
      // Submit hash to blockchain
      await Future.delayed(const Duration(milliseconds: 800));
      
      final hashRecord = DocumentHashRecord(
        id: 'dhr_${DateTime.now().millisecondsSinceEpoch}',
        documentId: documentId,
        fileName: fileName,
        fileHash: fileHash,
        blockchainHash: _generateMockTxHash(),
        ipfsCid: ipfsCid,
        uploaderUserId: uploaderUserId,
        uploadTimestamp: DateTime.now(),
        verificationStatus: 'verified',
        metadata: {
          'file_size': fileBytes.length,
          'contract_address': _documentRegistryAddress,
          'block_number': '${18500000 + _documentHashes.length}',
        },
      );

      _documentHashes.add(hashRecord);
      return hashRecord;
    } catch (e) {
      throw Exception('Failed to register document hash: $e');
    }
  }

  /// Create smart contract release trigger
  Future<SmartContractRelease> createSmartContractRelease({
    required String projectId,
    required String milestoneId,
    required double releaseAmount,
    required Map<String, dynamic> triggerConditions,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final release = SmartContractRelease(
        id: 'scr_${DateTime.now().millisecondsSinceEpoch}',
        contractAddress: _releaseContractAddress,
        projectId: projectId,
        milestoneId: milestoneId,
        releaseAmount: releaseAmount,
        triggerConditions: triggerConditions,
        oracleStatus: 'active',
        releaseStatus: 'pending',
        createdAt: DateTime.now(),
        metadata: {
          'chainlink_job_id': 'b7d2a8f4c3e1d9f2e8a5c7b9',
          'oracle_address': '0x514910771AF9Ca656af840dff83E8264EcF986CA',
          'gas_limit': '150000',
        },
      );

      _smartReleases.add(release);
      return release;
    } catch (e) {
      throw Exception('Failed to create smart contract release: $e');
    }
  }

  /// Verify document integrity
  Future<bool> verifyDocumentIntegrity({
    required String documentId,
    required List<int> currentFileBytes,
  }) async {
    try {
      final record = _documentHashes.firstWhere(
        (doc) => doc.documentId == documentId,
        orElse: () => throw Exception('Document not found in registry'),
      );

      final currentHash = sha256.convert(currentFileBytes).toString();
      return currentHash == record.fileHash;
    } catch (e) {
      return false;
    }
  }

  /// Get audit trail statistics
  Future<AuditTrailStats> getAuditTrailStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final statusCounts = <String, int>{};
    for (final tx in _transactions) {
      statusCounts[tx.status] = (statusCounts[tx.status] ?? 0) + 1;
    }

    return AuditTrailStats(
      totalTransactionsAnchored: _transactions.length,
      lastBlockHash: _transactions.isNotEmpty ? _transactions.last.blockHash : '0x0',
      lastAnchorTimestamp: _transactions.isNotEmpty ? _transactions.last.timestamp : DateTime.now(),
      integrityPercentage: _calculateIntegrityPercentage(),
      networkStatus: 'connected',
      statusCounts: statusCounts,
    );
  }

  /// Get document hash records
  Future<List<DocumentHashRecord>> getDocumentHashRecords() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_documentHashes);
  }

  /// Get smart contract releases
  Future<List<SmartContractRelease>> getSmartContractReleases() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_smartReleases);
  }

  /// Get blockchain transaction by ID
  Future<BlockchainTransaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((tx) => tx.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Generate blockchain explorer URL
  String getExplorerUrl(String transactionHash) {
    return 'https://goerli.etherscan.io/tx/$transactionHash';
  }

  /// Mock data generation for demo purposes
  Future<void> _generateMockData() async {
    // Generate some audit trail transactions
    for (int i = 0; i < 15; i++) {
      final tx = BlockchainTransaction(
        id: 'btx_mock_$i',
        transactionHash: _generateMockTxHash(),
        blockHash: _generateMockBlockHash(),
        blockNumber: '${18500000 + i}',
        contractAddress: _auditContractAddress,
        timestamp: DateTime.now().subtract(Duration(hours: i * 2)),
        dataHash: _generateMockHash(),
        metadata: {
          'transaction_id': 'pfms_tx_${1000 + i}',
          'data_type': 'fund_transfer',
          'gas_used': '21000',
          'gas_price': '${15 + (i % 10)}',
        },
        status: i % 10 == 0 ? 'pending' : 'confirmed',
      );
      _transactions.add(tx);
    }

    // Generate document hash records
    for (int i = 0; i < 8; i++) {
      final doc = DocumentHashRecord(
        id: 'dhr_mock_$i',
        documentId: 'doc_${100 + i}',
        fileName: 'evidence_${i + 1}.pdf',
        fileHash: _generateMockHash(),
        blockchainHash: _generateMockTxHash(),
        ipfsCid: _generateMockIpfsCid(),
        uploaderUserId: 'user_${i % 3 + 1}',
        uploadTimestamp: DateTime.now().subtract(Duration(days: i)),
        verificationStatus: i % 7 == 0 ? 'pending' : 'verified',
        metadata: {
          'file_size': 1024 * (50 + i * 10),
          'contract_address': _documentRegistryAddress,
          'block_number': '${18500020 + i}',
        },
      );
      _documentHashes.add(doc);
    }

    // Generate smart contract releases
    for (int i = 0; i < 5; i++) {
      final release = SmartContractRelease(
        id: 'scr_mock_$i',
        contractAddress: _releaseContractAddress,
        projectId: 'proj_${i + 1}',
        milestoneId: 'milestone_${i + 1}',
        releaseAmount: 50.0 + (i * 25.0),
        triggerConditions: {
          'geo_verification': i % 2 == 0,
          'document_verification': true,
          'milestone_completion': i < 3,
        },
        oracleStatus: i == 4 ? 'inactive' : 'active',
        releaseStatus: i < 2 ? 'released' : i < 4 ? 'triggered' : 'pending',
        createdAt: DateTime.now().subtract(Duration(days: i * 5)),
        triggeredAt: i < 4 ? DateTime.now().subtract(Duration(days: i * 3)) : null,
        releasedAt: i < 2 ? DateTime.now().subtract(Duration(days: i * 2)) : null,
        metadata: {
          'chainlink_job_id': 'job_${i + 1}',
          'oracle_address': '0x514910771AF9Ca656af840dff83E8264EcF986CA',
          'gas_limit': '150000',
        },
      );
      _smartReleases.add(release);
    }
  }

  String _generateMockTxHash() {
    final random = Random();
    const chars = '0123456789abcdef';
    return '0x${List.generate(64, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  String _generateMockBlockHash() {
    final random = Random();
    const chars = '0123456789abcdef';
    return '0x${List.generate(64, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  String _generateMockHash() {
    final random = Random();
    const chars = '0123456789abcdef';
    return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateMockIpfsCid() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'Qm${List.generate(44, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  double _calculateIntegrityPercentage() {
    if (_transactions.isEmpty) return 100.0;
    final confirmed = _transactions.where((tx) => tx.status == 'confirmed').length;
    return (confirmed / _transactions.length) * 100.0;
  }
}