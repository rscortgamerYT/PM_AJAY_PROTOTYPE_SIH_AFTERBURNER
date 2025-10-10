import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/fund_transaction_model.dart';

/// Transaction Explorer Table with advanced filtering, search, and pagination
class TransactionExplorerTable extends StatefulWidget {
  final List<FundTransaction> transactions;
  final Function(FundTransaction)? onTransactionTap;
  final Function(List<String>)? onExport;

  const TransactionExplorerTable({
    Key? key,
    required this.transactions,
    this.onTransactionTap,
    this.onExport,
  }) : super(key: key);

  @override
  State<TransactionExplorerTable> createState() => _TransactionExplorerTableState();
}

class _TransactionExplorerTableState extends State<TransactionExplorerTable> {
  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100];

  // Sorting
  int _sortColumnIndex = 0;
  bool _sortAscending = false;

  // Filtering
  String _searchQuery = '';
  FundFlowStage? _selectedStage;
  TransactionStatus? _selectedStatus;
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;

  // Selected rows for bulk actions
  final Set<String> _selectedTransactionIds = {};

  List<FundTransaction> get _filteredTransactions {
    var filtered = widget.transactions.where((tx) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!tx.pfmsId.toLowerCase().contains(query) &&
            !tx.fromEntity.toLowerCase().contains(query) &&
            !tx.toEntity.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Stage filter
      if (_selectedStage != null && tx.stage != _selectedStage) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && tx.status != _selectedStatus) {
        return false;
      }

      // Date range filter
      if (_dateRange != null) {
        if (tx.transactionDate.isBefore(_dateRange!.start) ||
            tx.transactionDate.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      // Amount range filter
      if (_minAmount != null && tx.amount < _minAmount!) {
        return false;
      }
      if (_maxAmount != null && tx.amount > _maxAmount!) {
        return false;
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int compare = 0;
      switch (_sortColumnIndex) {
        case 0: // Date
          compare = a.transactionDate.compareTo(b.transactionDate);
          break;
        case 1: // PFMS ID
          compare = a.pfmsId.compareTo(b.pfmsId);
          break;
        case 2: // Stage
          compare = a.stage.label.compareTo(b.stage.label);
          break;
        case 3: // Source
          compare = a.fromEntity.compareTo(b.fromEntity);
          break;
        case 4: // Destination
          compare = a.toEntity.compareTo(b.toEntity);
          break;
        case 5: // Amount
          compare = a.amount.compareTo(b.amount);
          break;
        case 6: // Status
          compare = a.status.label.compareTo(b.status.label);
          break;
      }
      return _sortAscending ? compare : -compare;
    });

    return filtered;
  }

  List<FundTransaction> get _paginatedTransactions {
    final filtered = _filteredTransactions;
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFiltersSection(),
        const SizedBox(height: 16),
        _buildTableActionsBar(),
        const SizedBox(height: 8),
        Expanded(
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: _buildDataTable(),
                    ),
                  ),
                ),
                _buildPaginationControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Search field
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'PFMS ID, Source, Destination...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                // Stage filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<FundFlowStage>(
                    decoration: const InputDecoration(
                      labelText: 'Stage',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _selectedStage,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Stages'),
                      ),
                      ...FundFlowStage.values.map((stage) {
                        return DropdownMenuItem(
                          value: stage,
                          child: Text(stage.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStage = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                // Status filter
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<TransactionStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _selectedStatus,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...TransactionStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                // Date range picker
                SizedBox(
                  width: 250,
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat('dd/MM/yy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yy').format(_dateRange!.end)}',
                    ),
                  ),
                ),
                // Amount range
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Amount (₹)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minAmount = double.tryParse(value);
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Amount (₹)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxAmount = double.tryParse(value);
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableActionsBar() {
    final selectedCount = _selectedTransactionIds.length;
    final totalFiltered = _filteredTransactions.length;

    return Row(
      children: [
        Text(
          'Showing ${_paginatedTransactions.length} of $totalFiltered transactions',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (selectedCount > 0) ...[
          const SizedBox(width: 16),
          Chip(
            label: Text('$selectedCount selected'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              setState(() {
                _selectedTransactionIds.clear();
              });
            },
          ),
        ],
        const Spacer(),
        if (selectedCount > 0) ...[
          OutlinedButton.icon(
            onPressed: _exportSelected,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export Selected'),
          ),
          const SizedBox(width: 8),
        ],
        OutlinedButton.icon(
          onPressed: _exportAll,
          icon: const Icon(Icons.table_chart, size: 16),
          label: const Text('Export All'),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      showCheckboxColumn: true,
      columns: [
        DataColumn(
          label: const Text('Date'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('PFMS ID'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('Stage'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('Source'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('Destination'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('Amount (₹)'),
          numeric: true,
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        DataColumn(
          label: const Text('Status'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          },
        ),
        const DataColumn(
          label: Text('Actions'),
        ),
      ],
      rows: _paginatedTransactions.map((transaction) {
        final isSelected = _selectedTransactionIds.contains(transaction.id);
        return DataRow(
          selected: isSelected,
          onSelectChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedTransactionIds.add(transaction.id);
              } else {
                _selectedTransactionIds.remove(transaction.id);
              }
            });
          },
          cells: [
            DataCell(
              Text(DateFormat('dd/MM/yyyy').format(transaction.transactionDate)),
            ),
            DataCell(
              Text(
                transaction.pfmsId,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            DataCell(
              Chip(
                label: Text(
                  transaction.stage.label,
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getStageColor(transaction.stage),
                padding: EdgeInsets.zero,
              ),
            ),
            DataCell(
              Text(
                transaction.fromEntity,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                transaction.toEntity,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                _formatAmount(transaction.amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Chip(
                label: Text(
                  transaction.status.label,
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getStatusColor(transaction.status),
                padding: EdgeInsets.zero,
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    tooltip: 'View Details',
                    onPressed: () {
                      widget.onTransactionTap?.call(transaction);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt, size: 18),
                    tooltip: 'Download Receipt',
                    onPressed: () => _downloadReceipt(transaction),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_filteredTransactions.length / _rowsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text('Rows per page:'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            items: _rowsPerPageOptions.map((rows) {
              return DropdownMenuItem(
                value: rows,
                child: Text('$rows'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _rowsPerPage = value;
                  _currentPage = 0;
                });
              }
            },
          ),
          const Spacer(),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage = 0;
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage = totalPages - 1;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _currentPage = 0;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStage = null;
      _selectedStatus = null;
      _dateRange = null;
      _minAmount = null;
      _maxAmount = null;
      _currentPage = 0;
    });
  }

  void _exportSelected() {
    final selectedTransactions = _filteredTransactions
        .where((tx) => _selectedTransactionIds.contains(tx.id))
        .map((tx) => tx.id)
        .toList();
    widget.onExport?.call(selectedTransactions);
    _showExportDialog('Selected transactions exported successfully');
  }

  void _exportAll() {
    final allTransactionIds = _filteredTransactions.map((tx) => tx.id).toList();
    widget.onExport?.call(allTransactionIds);
    _showExportDialog('All filtered transactions exported successfully');
  }

  void _showExportDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('Choose export format:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('CSV'),
                  selected: true,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('Excel'),
                  selected: false,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('PDF'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual export logic
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(FundTransaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading receipt for ${transaction.pfmsId}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Implement actual download logic
  }

  Color _getStageColor(FundFlowStage stage) {
    switch (stage) {
      case FundFlowStage.centreAllocation:
        return Colors.blue.shade100;
      case FundFlowStage.stateTransfer:
        return Colors.green.shade100;
      case FundFlowStage.agencyDisbursement:
        return Colors.orange.shade100;
      case FundFlowStage.projectSpend:
        return Colors.purple.shade100;
      case FundFlowStage.beneficiaryPayment:
        return Colors.teal.shade100;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange.shade100;
      case TransactionStatus.processing:
        return Colors.blue.shade100;
      case TransactionStatus.completed:
        return Colors.green.shade100;
      case TransactionStatus.failed:
        return Colors.red.shade100;
      case TransactionStatus.onHold:
        return Colors.grey.shade300;
      case TransactionStatus.cancelled:
        return Colors.red.shade200;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }
}