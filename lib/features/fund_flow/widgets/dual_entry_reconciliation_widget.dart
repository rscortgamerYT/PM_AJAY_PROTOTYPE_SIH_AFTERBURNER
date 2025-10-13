import 'package:flutter/material.dart';
import '../../../core/models/reconciliation_models.dart';
import '../../../core/services/enhanced_reconciliation_demo_service.dart';

/// Widget for dual-entry reconciliation ledger with side-by-side PFMS and Bank comparison
class DualEntryReconciliationWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onRefresh;
  final bool showDetailsPanel;

  const DualEntryReconciliationWidget({
    super.key,
    this.title = 'Dual-Entry Reconciliation Ledger',
    this.onRefresh,
    this.showDetailsPanel = true,
  });

  @override
  State<DualEntryReconciliationWidget> createState() => _DualEntryReconciliationWidgetState();
}

class _DualEntryReconciliationWidgetState extends State<DualEntryReconciliationWidget> {
  List<ReconciliationEntry> _reconciliations = [];
  ReconciliationSummary? _summary;
  bool _isLoading = false;
  ReconciliationEntry? _selectedEntry;
  String _filterStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReconciliationData();
  }

  Future<void> _loadReconciliationData() async {
    setState(() => _isLoading = true);
    
    try {
      final reconciliations = await EnhancedReconciliationDemoService.generateEnhancedDemoData();
      final summary = EnhancedReconciliationDemoService.generateEnhancedSummary(reconciliations);
      
      setState(() {
        _reconciliations = reconciliations;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reconciliation data: $e')),
        );
      }
    }
  }

  List<ReconciliationEntry> get _filteredReconciliations {
    var filtered = _reconciliations;
    
    // Apply status filter
    if (_filterStatus != 'All') {
      final status = ReconciliationStatus.values.firstWhere(
        (s) => s.displayName == _filterStatus,
        orElse: () => ReconciliationStatus.pending,
      );
      filtered = filtered.where((r) => r.status == status).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final pfmsId = r.pfmsRecord?.pfmsId ?? '';
        final bankId = r.bankRecord?.bankTransactionId ?? '';
        final amount = r.displayAmount.toString();
        return pfmsId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               bankId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               amount.contains(_searchQuery);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.black, // Black background as requested
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_summary != null) _buildSummaryCards(),
          _buildFiltersAndSearch(),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildReconciliationTable(),
          ),
          if (_selectedEntry != null && widget.showDetailsPanel)
            _buildDetailsPanel(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black, // Black header background
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance,
            color: Colors.white, // White icon for black background
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for black background
                  ),
                ),
                Text(
                  'Instant reconciliation of PFMS vs Bank statements',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[300], // Light grey subtitle text
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _loadReconciliationData();
              widget.onRefresh?.call();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black, // Black background for summary section
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard(
            'Total Records',
            _summary!.totalRecords.toString(),
            Icons.list_alt,
            Colors.blue,
          )),
          Expanded(child: _buildSummaryCard(
            'Matched',
            '${_summary!.matchedRecords} (${_summary!.matchPercentage.toStringAsFixed(1)}%)',
            Icons.check_circle,
            Colors.green,
          )),
          Expanded(child: _buildSummaryCard(
            'Mismatched',
            '${_summary!.mismatchedRecords}',
            Icons.error,
            Colors.red,
          )),
          Expanded(child: _buildSummaryCard(
            'Total Amount',
            '₹${(_summary!.totalAmount / 100000).toStringAsFixed(2)}L',
            Icons.currency_rupee,
            Colors.orange,
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900], // Dark grey card background
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70, // Light text for dark background
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by ID or amount...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.grey[800],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Status Filter',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['All', ...ReconciliationStatus.values.map((s) => s.displayName)]
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _filterStatus = value ?? 'All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReconciliationTable() {
    final reconciliations = _filteredReconciliations;
    
    if (reconciliations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No reconciliation records found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: reconciliations.length,
      itemBuilder: (context, index) {
        final entry = reconciliations[index];
        return _buildReconciliationRow(entry);
      },
    );
  }

  Widget _buildReconciliationRow(ReconciliationEntry entry) {
    final isSelected = _selectedEntry?.reconciliationId == entry.reconciliationId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedEntry = isSelected ? null : entry),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // PFMS side
                  Expanded(
                    child: _buildRecordCard(
                      'PFMS',
                      entry.pfmsRecord != null,
                      entry.pfmsRecord?.pfmsId ?? 'N/A',
                      entry.pfmsRecord?.amount.toStringAsFixed(2) ?? '0.00',
                      entry.pfmsRecord?.transactionDate,
                      entry.pfmsRecord?.purpose ?? '',
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Match indicator
                  Icon(
                    entry.status == ReconciliationStatus.matched 
                      ? Icons.check_circle 
                      : Icons.error,
                    color: entry.status.color,
                    size: 20,
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Bank side
                  Expanded(
                    child: _buildRecordCard(
                      'Bank',
                      entry.bankRecord != null,
                      entry.bankRecord?.bankTransactionId ?? 'N/A',
                      entry.bankRecord?.amount.toStringAsFixed(2) ?? '0.00',
                      entry.bankRecord?.transactionDate,
                      entry.bankRecord?.description ?? '',
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Actions
                  if (entry.status == ReconciliationStatus.mismatched)
                    ElevatedButton.icon(
                      onPressed: () => _showDisputeDialog(entry),
                      icon: const Icon(Icons.flag, size: 16),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
              
              if (entry.hasDiscrepancies) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Discrepancies: ${entry.discrepancies.join(', ')}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'Confidence: ${entry.confidenceScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    String type,
    bool hasRecord,
    String id,
    String amount,
    DateTime? date,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: hasRecord ? Colors.grey[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasRecord ? Colors.grey[300]! : Colors.red[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (!hasRecord)
                Icon(Icons.error, color: Colors.red[700], size: 16),
            ],
          ),
          const SizedBox(height: 4),
          if (hasRecord) ...[
            Text(
              id,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            Text(
              '₹$amount',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (date != null)
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 11),
              ),
            Text(
              description,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const Text(
              'Missing Record',
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final entry = _selectedEntry!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reconciliation Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedEntry = null),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Detailed comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.pfmsRecord != null) ...[
                Expanded(
                  child: _buildDetailedRecordView('PFMS Record', entry.pfmsRecord!),
                ),
                const SizedBox(width: 16),
              ],
              if (entry.bankRecord != null)
                Expanded(
                  child: _buildDetailedRecordView('Bank Record', entry.bankRecord!),
                ),
            ],
          ),
          
          if (entry.disputes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Dispute History',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...entry.disputes.map((dispute) => _buildDisputeCard(dispute)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRecordView(String title, dynamic record) {
    final Map<String, String> details = {};
    
    if (record is PFMSRecord) {
      details.addAll({
        'PFMS ID': record.pfmsId,
        'Transaction ID': record.transactionId,
        'Amount': '₹${record.amount.toStringAsFixed(2)}',
        'Date': '${record.transactionDate.day}/${record.transactionDate.month}/${record.transactionDate.year}',
        'From Account': record.fromAccount,
        'To Account': record.toAccount,
        'Purpose': record.purpose,
        'Sanction Number': record.sanctionNumber,
        'Project Code': record.projectCode,
        'UTR Number': record.utrNumber ?? 'N/A',
      });
    } else if (record is BankRecord) {
      details.addAll({
        'Bank Transaction ID': record.bankTransactionId,
        'Account Number': record.accountNumber,
        'Amount': '₹${record.amount.toStringAsFixed(2)}',
        'Value Date': '${record.valueDate.day}/${record.valueDate.month}/${record.valueDate.year}',
        'Transaction Date': '${record.transactionDate.day}/${record.transactionDate.month}/${record.transactionDate.year}',
        'Description': record.description,
        'Type': record.transactionType,
        'UTR Number': record.utrNumber ?? 'N/A',
        'Running Balance': '₹${record.runningBalance.toStringAsFixed(2)}',
      });
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(entry.value),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeCard(DisputeEntry dispute) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dispute.disputeType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(dispute.status),
                  backgroundColor: dispute.status == 'Resolved' 
                    ? Colors.green[100] 
                    : Colors.orange[100],
                ),
              ],
            ),
            Text(dispute.description),
            Text(
              'Raised by: ${dispute.raisedBy} on ${dispute.raisedDate.day}/${dispute.raisedDate.month}/${dispute.raisedDate.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputeDialog(ReconciliationEntry entry) {
    showDialog(
      context: context,
      builder: (context) => DisputeResolutionDialog(
        reconciliationEntry: entry,
        onDispute: (dispute) {
          setState(() {
            entry.disputes.add(dispute);
          });
        },
      ),
    );
  }
}

/// Dialog for dispute resolution workflow
class DisputeResolutionDialog extends StatefulWidget {
  final ReconciliationEntry reconciliationEntry;
  final Function(DisputeEntry) onDispute;

  const DisputeResolutionDialog({
    super.key,
    required this.reconciliationEntry,
    required this.onDispute,
  });

  @override
  State<DisputeResolutionDialog> createState() => _DisputeResolutionDialogState();
}

class _DisputeResolutionDialogState extends State<DisputeResolutionDialog> {
  final _formKey = GlobalKey<FormState>();
  String _disputeType = 'Amount Discrepancy';
  String _description = '';
  String _assignedTo = 'System Admin';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raise Dispute'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _disputeType,
              decoration: const InputDecoration(labelText: 'Dispute Type'),
              items: [
                'Amount Discrepancy',
                'Date Mismatch',
                'Missing Record',
                'Duplicate Entry',
                'Other'
              ].map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) => setState(() => _disputeType = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue in detail...',
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
              onChanged: (value) => _description = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _assignedTo,
              decoration: const InputDecoration(labelText: 'Assign To'),
              items: [
                'System Admin',
                'Finance Officer',
                'Project Manager',
                'State Coordinator'
              ].map((person) => DropdownMenuItem(
                value: person,
                child: Text(person),
              )).toList(),
              onChanged: (value) => setState(() => _assignedTo = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final dispute = DisputeEntry(
                disputeId: 'DSP_${DateTime.now().millisecondsSinceEpoch}',
                raisedDate: DateTime.now(),
                raisedBy: 'Current User', // Should be dynamic
                disputeType: _disputeType,
                description: _description,
                assignedTo: _assignedTo,
                targetResolutionDate: DateTime.now().add(const Duration(days: 3)),
              );
              
              widget.onDispute(dispute);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispute raised successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Raise Dispute'),
        ),
      ],
    );
  }
}