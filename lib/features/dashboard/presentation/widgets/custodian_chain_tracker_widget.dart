import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

/// Custodian Chain Tracker Widget
/// 
/// End-to-end tracking of fund custody across all stakeholders
/// from Centre → State → District → Agency → Project → Beneficiary
class CustodianChainTrackerWidget extends ConsumerStatefulWidget {
  final String? projectId;
  
  const CustodianChainTrackerWidget({
    super.key,
    this.projectId,
  });

  @override
  ConsumerState<CustodianChainTrackerWidget> createState() => _CustodianChainTrackerWidgetState();
}

class _CustodianChainTrackerWidgetState extends ConsumerState<CustodianChainTrackerWidget> {
  String? _selectedChainId;
  
  // Mock custodian chains - replace with Supabase data
  final List<CustodianChain> _chains = [
    CustodianChain(
      id: 'chain_001',
      projectId: 'PRJ001',
      projectName: 'Delhi Adarsh Gram Phase 1',
      totalAmount: 125000000,
      currentCustodian: 'Delhi Development Authority',
      custodianType: CustodianType.agency,
      status: ChainStatus.active,
      transfers: [
        CustodyTransfer(
          id: 'txf_001',
          fromCustodian: 'Ministry of Rural Development',
          toCustodian: 'Delhi State Treasury',
          custodianType: CustodianType.centre,
          amount: 125000000,
          transferDate: DateTime.now().subtract(const Duration(days: 45)),
          documentRef: 'MRD/2024/FT/001',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 2),
        ),
        CustodyTransfer(
          id: 'txf_002',
          fromCustodian: 'Delhi State Treasury',
          toCustodian: 'Delhi District Collector',
          custodianType: CustodianType.state,
          amount: 125000000,
          transferDate: DateTime.now().subtract(const Duration(days: 42)),
          documentRef: 'DST/2024/DC/045',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 3),
        ),
        CustodyTransfer(
          id: 'txf_003',
          fromCustodian: 'Delhi District Collector',
          toCustodian: 'Delhi Development Authority',
          custodianType: CustodianType.district,
          amount: 125000000,
          transferDate: DateTime.now().subtract(const Duration(days: 38)),
          documentRef: 'DDC/2024/AGY/089',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 4),
        ),
        CustodyTransfer(
          id: 'txf_004',
          fromCustodian: 'Delhi Development Authority',
          toCustodian: 'Construction Contractor XYZ',
          custodianType: CustodianType.agency,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 30)),
          documentRef: 'DDA/2024/PRJ/023',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 5),
        ),
        CustodyTransfer(
          id: 'txf_005',
          fromCustodian: 'Construction Contractor XYZ',
          toCustodian: 'Project Beneficiaries',
          custodianType: CustodianType.project,
          amount: 62500000,
          transferDate: DateTime.now().subtract(const Duration(days: 20)),
          documentRef: 'CCX/2024/BEN/078',
          verificationStatus: VerificationStatus.pending,
          duration: const Duration(days: 8),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      updatedAt: DateTime.now(),
    ),
    CustodianChain(
      id: 'chain_002',
      projectId: 'PRJ002',
      projectName: 'Mumbai Housing Infrastructure',
      totalAmount: 250000000,
      currentCustodian: 'Mumbai District Collector',
      custodianType: CustodianType.district,
      status: ChainStatus.active,
      transfers: [
        CustodyTransfer(
          id: 'txf_006',
          fromCustodian: 'Ministry of Housing',
          toCustodian: 'Maharashtra State Treasury',
          custodianType: CustodianType.centre,
          amount: 250000000,
          transferDate: DateTime.now().subtract(const Duration(days: 30)),
          documentRef: 'MOH/2024/FT/089',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 1),
        ),
        CustodyTransfer(
          id: 'txf_007',
          fromCustodian: 'Maharashtra State Treasury',
          toCustodian: 'Mumbai District Collector',
          custodianType: CustodianType.state,
          amount: 250000000,
          transferDate: DateTime.now().subtract(const Duration(days: 25)),
          documentRef: 'MST/2024/DC/156',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 5),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      updatedAt: DateTime.now(),
    ),
    CustodianChain(
      id: 'chain_003',
      projectId: 'PRJ003',
      projectName: 'Karnataka Rural Development',
      totalAmount: 87500000,
      currentCustodian: 'Project Beneficiaries',
      custodianType: CustodianType.beneficiary,
      status: ChainStatus.completed,
      transfers: [
        CustodyTransfer(
          id: 'txf_008',
          fromCustodian: 'Ministry of Rural Development',
          toCustodian: 'Karnataka State Treasury',
          custodianType: CustodianType.centre,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 120)),
          documentRef: 'MRD/2024/FT/045',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 2),
        ),
        CustodyTransfer(
          id: 'txf_009',
          fromCustodian: 'Karnataka State Treasury',
          toCustodian: 'Bangalore District Collector',
          custodianType: CustodianType.state,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 115)),
          documentRef: 'KST/2024/DC/098',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 5),
        ),
        CustodyTransfer(
          id: 'txf_010',
          fromCustodian: 'Bangalore District Collector',
          toCustodian: 'Karnataka Rural Development Authority',
          custodianType: CustodianType.district,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 108)),
          documentRef: 'BDC/2024/AGY/234',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 7),
        ),
        CustodyTransfer(
          id: 'txf_011',
          fromCustodian: 'Karnataka Rural Development Authority',
          toCustodian: 'Implementing Agency ABC',
          custodianType: CustodianType.agency,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 95)),
          documentRef: 'KRDA/2024/PRJ/067',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 13),
        ),
        CustodyTransfer(
          id: 'txf_012',
          fromCustodian: 'Implementing Agency ABC',
          toCustodian: 'Project Beneficiaries',
          custodianType: CustodianType.project,
          amount: 87500000,
          transferDate: DateTime.now().subtract(const Duration(days: 60)),
          documentRef: 'IAB/2024/BEN/123',
          verificationStatus: VerificationStatus.verified,
          duration: const Duration(days: 35),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 125)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildStats(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildChainsList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _selectedChainId != null
                  ? _buildChainDetails(_chains.firstWhere((c) => c.id == _selectedChainId))
                  : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custodian Chain Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track fund custody across Centre → State → District → Agency → Project → Beneficiary',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export functionality coming soon')),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final activeChains = _chains.where((c) => c.status == ChainStatus.active).length;
    final completedChains = _chains.where((c) => c.status == ChainStatus.completed).length;
    final totalTransfers = _chains.fold<int>(0, (sum, c) => sum + c.transfers.length);
    final avgDuration = _chains.isEmpty ? 0 : _chains.fold<int>(0, (sum, c) => 
      sum + c.transfers.fold<int>(0, (s, t) => s + t.duration.inDays)) ~/ totalTransfers;

    return Row(
      children: [
        _buildStatCard('Active Chains', activeChains.toString(), Icons.sync, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Completed', completedChains.toString(), Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('Total Transfers', totalTransfers.toString(), Icons.swap_horiz, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard('Avg Duration', '$avgDuration days', Icons.schedule, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Custody Chains',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _chains.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chain = _chains[index];
                final isSelected = _selectedChainId == chain.id;
                
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? AppTheme.primaryIndigo.withOpacity(0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryIndigo : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedChainId = chain.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chain.projectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(chain.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusLabel(chain.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getStatusColor(chain.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.currency_rupee, size: 14, color: Colors.grey[600]),
                              Text(
                                ' ${_formatCurrency(chain.totalAmount)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey[600]),
                              Expanded(
                                child: Text(
                                  ' ${chain.currentCustodian}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 14, color: Colors.grey[600]),
                              Text(
                                ' ${chain.transfers.length} transfers',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainDetails(CustodianChain chain) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chain.projectName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chain ID: ${chain.id}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(chain.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusLabel(chain.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(chain.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInfoItem('Total Amount', _formatCurrency(chain.totalAmount), Icons.currency_rupee),
                const SizedBox(width: 24),
                _buildInfoItem('Current Custodian', chain.currentCustodian, Icons.account_balance_wallet),
                const SizedBox(width: 24),
                _buildInfoItem('Transfers', '${chain.transfers.length}', Icons.swap_horiz),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Custody Transfer Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chain.transfers.length,
              itemBuilder: (context, index) {
                final transfer = chain.transfers[index];
                final isLast = index == chain.transfers.length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCustodianColor(transfer.custodianType),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 100,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${transfer.fromCustodian} → ${transfer.toCustodian}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _getVerificationIcon(transfer.verificationStatus),
                                    size: 18,
                                    color: _getVerificationColor(transfer.verificationStatus),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTransferDetail('Amount', _formatCurrency(transfer.amount)),
                              _buildTransferDetail('Document', transfer.documentRef),
                              _buildTransferDetail('Date', DateFormat('dd MMM yyyy').format(transfer.transferDate)),
                              _buildTransferDetail('Duration', '${transfer.duration.inDays} days'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getCustodianColor(transfer.custodianType).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getCustodianLabel(transfer.custodianType),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getCustodianColor(transfer.custodianType),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getVerificationColor(transfer.verificationStatus).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getVerificationLabel(transfer.verificationStatus),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getVerificationColor(transfer.verificationStatus),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a custody chain to view details',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryIndigo),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransferDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _getStatusLabel(ChainStatus status) {
    switch (status) {
      case ChainStatus.active:
        return 'Active';
      case ChainStatus.completed:
        return 'Completed';
      case ChainStatus.paused:
        return 'Paused';
    }
  }

  Color _getStatusColor(ChainStatus status) {
    switch (status) {
      case ChainStatus.active:
        return Colors.blue;
      case ChainStatus.completed:
        return Colors.green;
      case ChainStatus.paused:
        return Colors.orange;
    }
  }

  String _getCustodianLabel(CustodianType type) {
    switch (type) {
      case CustodianType.centre:
        return 'Centre';
      case CustodianType.state:
        return 'State';
      case CustodianType.district:
        return 'District';
      case CustodianType.agency:
        return 'Agency';
      case CustodianType.project:
        return 'Project';
      case CustodianType.beneficiary:
        return 'Beneficiary';
    }
  }

  Color _getCustodianColor(CustodianType type) {
    switch (type) {
      case CustodianType.centre:
        return AppTheme.overwatchColor;
      case CustodianType.state:
        return AppTheme.stateOfficerColor;
      case CustodianType.district:
        return Colors.teal;
      case CustodianType.agency:
        return AppTheme.agencyUserColor;
      case CustodianType.project:
        return Colors.purple;
      case CustodianType.beneficiary:
        return Colors.green;
    }
  }

  String _getVerificationLabel(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.failed:
        return 'Failed';
    }
  }

  Color _getVerificationColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.failed:
        return Colors.red;
    }
  }

  IconData _getVerificationIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.failed:
        return Icons.error;
    }
  }
}

// Models

enum ChainStatus {
  active,
  completed,
  paused,
}

enum CustodianType {
  centre,
  state,
  district,
  agency,
  project,
  beneficiary,
}

enum VerificationStatus {
  verified,
  pending,
  failed,
}

class CustodianChain {
  final String id;
  final String projectId;
  final String projectName;
  final double totalAmount;
  final String currentCustodian;
  final CustodianType custodianType;
  final ChainStatus status;
  final List<CustodyTransfer> transfers;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustodianChain({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.totalAmount,
    required this.currentCustodian,
    required this.custodianType,
    required this.status,
    required this.transfers,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CustodyTransfer {
  final String id;
  final String fromCustodian;
  final String toCustodian;
  final CustodianType custodianType;
  final double amount;
  final DateTime transferDate;
  final String documentRef;
  final VerificationStatus verificationStatus;
  final Duration duration;

  CustodyTransfer({
    required this.id,
    required this.fromCustodian,
    required this.toCustodian,
    required this.custodianType,
    required this.amount,
    required this.transferDate,
    required this.documentRef,
    required this.verificationStatus,
    required this.duration,
  });
}