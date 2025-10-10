import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Open Data Explorer Widget
/// 
/// Query builder interface for exploring public datasets with downloadable
/// results in CSV, JSON, and Excel formats.
class OpenDataExplorerWidget extends StatefulWidget {
  final String userId;
  
  const OpenDataExplorerWidget({
    super.key,
    required this.userId,
  });

  @override
  State<OpenDataExplorerWidget> createState() => _OpenDataExplorerWidgetState();
}

class _OpenDataExplorerWidgetState extends State<OpenDataExplorerWidget> {
  String? _selectedDataset;
  final List<String> _selectedFields = [];
  final Map<String, String> _filters = {};
  String _sortBy = 'date';
  String _sortOrder = 'desc';
  int _limit = 100;
  
  bool _isQuerying = false;
  List<Map<String, dynamic>> _queryResults = [];

  final List<Dataset> _availableDatasets = [
    Dataset(
      id: 'projects',
      name: 'Projects Database',
      description: 'All PM-AJAY projects with status, budget, and completion data',
      recordCount: 1247,
      lastUpdated: DateTime(2025, 10, 10),
      fields: [
        DataField('project_id', 'Project ID', DataType.text),
        DataField('project_name', 'Project Name', DataType.text),
        DataField('district', 'District', DataType.text),
        DataField('status', 'Status', DataType.category),
        DataField('budget', 'Budget (₹)', DataType.number),
        DataField('completion_date', 'Completion Date', DataType.date),
        DataField('beneficiaries', 'Beneficiaries', DataType.number),
      ],
    ),
    Dataset(
      id: 'fund_flow',
      name: 'Fund Flow Records',
      description: 'Transaction history of fund disbursements across all levels',
      recordCount: 5632,
      lastUpdated: DateTime(2025, 10, 9),
      fields: [
        DataField('transaction_id', 'Transaction ID', DataType.text),
        DataField('from_entity', 'From Entity', DataType.text),
        DataField('to_entity', 'To Entity', DataType.text),
        DataField('amount', 'Amount (₹)', DataType.number),
        DataField('transaction_date', 'Date', DataType.date),
        DataField('purpose', 'Purpose', DataType.text),
        DataField('status', 'Status', DataType.category),
      ],
    ),
    Dataset(
      id: 'beneficiaries',
      name: 'Beneficiary Data',
      description: 'Information about project beneficiaries and impact metrics',
      recordCount: 23456,
      lastUpdated: DateTime(2025, 10, 8),
      fields: [
        DataField('beneficiary_id', 'Beneficiary ID', DataType.text),
        DataField('district', 'District', DataType.text),
        DataField('village', 'Village', DataType.text),
        DataField('service_type', 'Service Type', DataType.category),
        DataField('enrollment_date', 'Enrollment Date', DataType.date),
        DataField('satisfaction_score', 'Satisfaction Score', DataType.number),
      ],
    ),
    Dataset(
      id: 'agencies',
      name: 'Agency Performance',
      description: 'Performance metrics and ratings for implementing agencies',
      recordCount: 145,
      lastUpdated: DateTime(2025, 10, 10),
      fields: [
        DataField('agency_id', 'Agency ID', DataType.text),
        DataField('agency_name', 'Agency Name', DataType.text),
        DataField('district', 'District', DataType.text),
        DataField('projects_completed', 'Projects Completed', DataType.number),
        DataField('average_rating', 'Average Rating', DataType.number),
        DataField('compliance_score', 'Compliance Score', DataType.number),
      ],
    ),
  ];

  Dataset? get _currentDataset {
    if (_selectedDataset == null) return null;
    return _availableDatasets.firstWhere((d) => d.id == _selectedDataset);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildQueryBuilder(),
              ),
              Expanded(
                flex: 3,
                child: _buildResultsPanel(),
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
          colors: [AppTheme.publicColor, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Open Data Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Query and download public datasets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalDatasets = _availableDatasets.length;
    final totalRecords = _availableDatasets.fold(0, (sum, d) => sum + d.recordCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                totalDatasets.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Datasets',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Text(
                '${(totalRecords / 1000).toStringAsFixed(1)}K',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Records',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueryBuilder() {
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Query Builder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dataset Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dataset, color: AppTheme.publicColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Select Dataset',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDataset,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose a dataset...',
                      ),
                      items: _availableDatasets.map((dataset) {
                        return DropdownMenuItem(
                          value: dataset.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataset.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${dataset.recordCount} records',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDataset = value;
                          _selectedFields.clear();
                          _filters.clear();
                          _queryResults.clear();
                        });
                      },
                    ),
                    if (_currentDataset != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentDataset!.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: ${_formatDate(_currentDataset!.lastUpdated)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            if (_currentDataset != null) ...[
              const SizedBox(height: 16),
              
              // Field Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.view_column, color: AppTheme.publicColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Fields',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentDataset!.fields.map((field) {
                          final isSelected = _selectedFields.contains(field.id);
                          return FilterChip(
                            label: Text(field.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFields.add(field.id);
                                } else {
                                  _selectedFields.remove(field.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filters
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_list, color: AppTheme.publicColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Filters (Optional)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Add filters to refine your query',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Query Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: AppTheme.publicColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Query Options',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                        ),
                        items: _currentDataset!.fields.map((field) {
                          return DropdownMenuItem(
                            value: field.id,
                            child: Text(field.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'asc', label: Text('Ascending')),
                          ButtonSegment(value: 'desc', label: Text('Descending')),
                        ],
                        selected: {_sortOrder},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _sortOrder = newSelection.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _limit.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Limit Results',
                          border: OutlineInputBorder(),
                          suffixText: 'records',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            _limit = parsed;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Run Query Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedFields.isEmpty || _isQuerying
                      ? null
                      : _runQuery,
                  icon: _isQuerying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isQuerying ? 'Running Query...' : 'Run Query'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.publicColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPanel() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart),
                const SizedBox(width: 8),
                const Text(
                  'Query Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_queryResults.isNotEmpty) ...[
                  Text(
                    '${_queryResults.length} records',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  _buildDownloadButton(),
                ],
              ],
            ),
          ),
          Expanded(
            child: _buildResultsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download),
      tooltip: 'Download Results',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.file_copy),
              SizedBox(width: 8),
              Text('Download as CSV'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'json',
          child: Row(
            children: [
              Icon(Icons.code),
              SizedBox(width: 8),
              Text('Download as JSON'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_rows),
              SizedBox(width: 8),
              Text('Download as Excel'),
            ],
          ),
        ),
      ],
      onSelected: (format) => _downloadResults(format),
    );
  }

  Widget _buildResultsTable() {
    if (_queryResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedDataset == null
                  ? 'Select a dataset to begin'
                  : _selectedFields.isEmpty
                      ? 'Select fields to query'
                      : 'Run query to see results',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: _selectedFields.map((fieldId) {
            final field = _currentDataset!.fields.firstWhere((f) => f.id == fieldId);
            return DataColumn(
              label: Text(
                field.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          rows: _queryResults.map((row) {
            return DataRow(
              cells: _selectedFields.map((fieldId) {
                return DataCell(Text(row[fieldId]?.toString() ?? 'N/A'));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _runQuery() async {
    setState(() => _isQuerying = true);

    // Simulate query execution
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock results
    final mockResults = List.generate(_limit.clamp(0, 50), (index) {
      final result = <String, dynamic>{};
      for (final fieldId in _selectedFields) {
        final field = _currentDataset!.fields.firstWhere((f) => f.id == fieldId);
        result[fieldId] = _generateMockValue(field.type, index);
      }
      return result;
    });

    setState(() {
      _queryResults = mockResults;
      _isQuerying = false;
    });
  }

  dynamic _generateMockValue(DataType type, int index) {
    switch (type) {
      case DataType.text:
        return 'Value ${index + 1}';
      case DataType.number:
        return (index + 1) * 100;
      case DataType.date:
        return _formatDate(DateTime.now().subtract(Duration(days: index)));
      case DataType.category:
        return ['Active', 'Completed', 'Pending'][index % 3];
    }
  }

  void _downloadResults(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download, color: AppTheme.successGreen),
            const SizedBox(width: 12),
            const Text('Download Ready'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your data is ready to download in ${format.toUpperCase()} format.'),
            const SizedBox(height: 16),
            Text(
              'Filename: ${_selectedDataset}_${DateTime.now().millisecondsSinceEpoch}.$format',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Records: ${_queryResults.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download started: ${_queryResults.length} records'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data Models
enum DataType { text, number, date, category }

class Dataset {
  final String id;
  final String name;
  final String description;
  final int recordCount;
  final DateTime lastUpdated;
  final List<DataField> fields;

  Dataset({
    required this.id,
    required this.name,
    required this.description,
    required this.recordCount,
    required this.lastUpdated,
    required this.fields,
  });
}

class DataField {
  final String id;
  final String name;
  final DataType type;

  DataField(this.id, this.name, this.type);
}