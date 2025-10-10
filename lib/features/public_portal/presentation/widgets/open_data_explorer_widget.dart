import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// Open Data Explorer Widget
/// 
/// Provides SQL-like querying and visualization tools for public datasets
class OpenDataExplorerWidget extends ConsumerStatefulWidget {
  const OpenDataExplorerWidget({super.key});

  @override
  ConsumerState<OpenDataExplorerWidget> createState() => _OpenDataExplorerWidgetState();
}

class _OpenDataExplorerWidgetState extends ConsumerState<OpenDataExplorerWidget> {
  final TextEditingController _queryController = TextEditingController();
  
  String _selectedDataset = 'projects';
  String _selectedVisualization = 'table';
  List<Map<String, dynamic>> _queryResults = [];
  bool _isQuerying = false;
  String _errorMessage = '';
  
  final List<DatasetInfo> _availableDatasets = [
    DatasetInfo(
      id: 'projects',
      name: 'PM-AJAY Projects',
      description: 'All projects under PM-AJAY scheme',
      recordCount: 1234,
      fields: ['id', 'name', 'status', 'component', 'budget', 'beneficiaries', 'location'],
    ),
    DatasetInfo(
      id: 'agencies',
      name: 'Implementing Agencies',
      description: 'State and district level agencies',
      recordCount: 456,
      fields: ['id', 'name', 'type', 'state', 'performance_rating', 'capacity_score'],
    ),
    DatasetInfo(
      id: 'funds',
      name: 'Fund Allocations',
      description: 'Budget allocations and expenditure',
      recordCount: 789,
      fields: ['id', 'project_id', 'allocated_amount', 'disbursed_amount', 'utilization_rate', 'date'],
    ),
    DatasetInfo(
      id: 'beneficiaries',
      name: 'Beneficiaries Data',
      description: 'People benefited from PM-AJAY projects',
      recordCount: 50000,
      fields: ['id', 'project_id', 'age', 'gender', 'category', 'benefits_received'],
    ),
  ];

  final List<String> _visualizationTypes = [
    'table',
    'bar_chart',
    'line_chart',
    'pie_chart',
    'map',
  ];

  final List<QueryTemplate> _queryTemplates = [
    QueryTemplate(
      name: 'All Active Projects',
      query: "SELECT * FROM projects WHERE status = 'in_progress' LIMIT 100",
      dataset: 'projects',
    ),
    QueryTemplate(
      name: 'Budget by Component',
      query: "SELECT component, SUM(budget) as total_budget FROM projects GROUP BY component",
      dataset: 'projects',
    ),
    QueryTemplate(
      name: 'Top Performing Agencies',
      query: "SELECT name, performance_rating FROM agencies ORDER BY performance_rating DESC LIMIT 10",
      dataset: 'agencies',
    ),
    QueryTemplate(
      name: 'Fund Utilization Analysis',
      query: "SELECT project_id, (disbursed_amount / allocated_amount * 100) as utilization FROM funds",
      dataset: 'funds',
    ),
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accentTeal, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Open Data Explorer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Query and visualize PM-AJAY public datasets with SQL-like syntax',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: _buildSidebar(),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Query Builder Section
                      _buildQueryBuilder(),
                      
                      const SizedBox(height: 24),

                      // Results Section
                      if (_queryResults.isNotEmpty) ...[
                        _buildResultsSection(),
                      ],

                      if (_errorMessage.isNotEmpty) ...[
                        _buildErrorSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datasets Section
          const Text(
            'Available Datasets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Column(
            children: _availableDatasets.map((dataset) {
              return _buildDatasetCard(dataset);
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Query Templates Section
          const Text(
            'Query Templates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Column(
            children: _queryTemplates.map((template) {
              return _buildTemplateCard(template);
            }).toList(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Export Options
          const Text(
            'Export Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: _queryResults.isNotEmpty ? _exportToCSV : null,
            icon: const Icon(Icons.file_download),
            label: const Text('Export as CSV'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: _queryResults.isNotEmpty ? _exportToJSON : null,
            icon: const Icon(Icons.code),
            label: const Text('Export as JSON'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetCard(DatasetInfo dataset) {
    final isSelected = _selectedDataset == dataset.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppTheme.accentTeal.withOpacity(0.1) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedDataset = dataset.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dataset,
                    size: 20,
                    color: isSelected ? AppTheme.accentTeal : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dataset.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.accentTeal : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dataset.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dataset.recordCount} records',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(QueryTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _selectedDataset = template.dataset;
            _queryController.text = template.query;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                template.query,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueryBuilder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Query Builder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: _showQueryHelp,
                      tooltip: 'Query Help',
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _clearQuery,
                      tooltip: 'Clear Query',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dataset Selector
            DropdownButtonFormField<String>(
              value: _selectedDataset,
              decoration: InputDecoration(
                labelText: 'Select Dataset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _availableDatasets.map((dataset) {
                return DropdownMenuItem(
                  value: dataset.id,
                  child: Text(dataset.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDataset = value!);
              },
            ),

            const SizedBox(height: 16),

            // Query Input
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'SQL Query',
                hintText: 'SELECT * FROM ${_selectedDataset} LIMIT 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Enter SQL-like query to retrieve data',
              ),
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace'),
            ),

            const SizedBox(height: 16),

            // Visualization Type Selector
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedVisualization,
                    decoration: InputDecoration(
                      labelText: 'Visualization Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _visualizationTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getVisualizationIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(_formatVisualizationType(type)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedVisualization = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isQuerying ? null : _executeQuery,
                  icon: _isQuerying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isQuerying ? 'Querying...' : 'Execute Query'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Field Reference
            ExpansionTile(
              title: const Text('Available Fields'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getDatasetFields().map((field) {
                      return Chip(
                        label: Text(
                          field,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        avatar: const Icon(Icons.label, size: 16),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Results (${_queryResults.length} records)',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _exportToCSV,
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _selectedVisualization == 'table'
                            ? Icons.bar_chart
                            : Icons.table_chart,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedVisualization = 
                              _selectedVisualization == 'table' ? 'bar_chart' : 'table';
                        });
                      },
                      tooltip: 'Toggle View',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_selectedVisualization == 'table')
              _buildTableView()
            else
              _buildChartView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView() {
    if (_queryResults.isEmpty) return const SizedBox.shrink();

    final columns = _queryResults.first.keys.toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) {
          return DataColumn(
            label: Text(
              col,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        rows: _queryResults.take(50).map((row) {
          return DataRow(
            cells: columns.map((col) {
              return DataCell(
                Text(row[col]?.toString() ?? 'N/A'),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartView() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getVisualizationIcon(_selectedVisualization),
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chart visualization for ${_formatVisualizationType(_selectedVisualization)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Integration with charting library required',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Card(
      color: AppTheme.errorRed.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorRed),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Query Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_errorMessage),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _errorMessage = ''),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getDatasetFields() {
    final dataset = _availableDatasets.firstWhere(
      (d) => d.id == _selectedDataset,
      orElse: () => _availableDatasets.first,
    );
    return dataset.fields;
  }

  IconData _getVisualizationIcon(String type) {
    switch (type) {
      case 'table':
        return Icons.table_chart;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'line_chart':
        return Icons.show_chart;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'map':
        return Icons.map;
      default:
        return Icons.dashboard;
    }
  }

  String _formatVisualizationType(String type) {
    return type.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _executeQuery() async {
    if (_queryController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a query';
      });
      return;
    }

    setState(() {
      _isQuerying = true;
      _errorMessage = '';
    });

    try {
      // Simulate query execution
      await Future.delayed(const Duration(seconds: 2));

      // Mock results
      final mockResults = List.generate(20, (index) {
        return {
          'id': index + 1,
          'name': 'Project ${index + 1}',
          'status': index % 3 == 0 ? 'completed' : 'in_progress',
          'budget': (100 + index * 10).toDouble(),
          'beneficiaries': 100 + index * 5,
        };
      });

      setState(() {
        _queryResults = mockResults;
        _isQuerying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error executing query: $e';
        _isQuerying = false;
      });
    }
  }

  void _clearQuery() {
    setState(() {
      _queryController.clear();
      _queryResults.clear();
      _errorMessage = '';
    });
  }

  void _showQueryHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Query Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Supported SQL Operations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQueryExample('SELECT', 'SELECT * FROM projects'),
              _buildQueryExample('WHERE', 'WHERE status = \'completed\''),
              _buildQueryExample('GROUP BY', 'GROUP BY component'),
              _buildQueryExample('ORDER BY', 'ORDER BY budget DESC'),
              _buildQueryExample('LIMIT', 'LIMIT 100'),
              const SizedBox(height: 16),
              const Text(
                'Example Queries:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...['SELECT * FROM projects LIMIT 50',
                  'SELECT component, COUNT(*) FROM projects GROUP BY component',
                  'SELECT * FROM agencies WHERE performance_rating > 0.8',
              ].map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  example,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryExample(String operation, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              operation,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              example,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
    // In production, generate and download CSV
  }

  void _exportToJSON() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to JSON...')),
    );
    // In production, generate and download JSON
  }
}

/// Dataset Information model
class DatasetInfo {
  final String id;
  final String name;
  final String description;
  final int recordCount;
  final List<String> fields;

  DatasetInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.recordCount,
    required this.fields,
  });
}

/// Query Template model
class QueryTemplate {
  final String name;
  final String query;
  final String dataset;

  QueryTemplate({
    required this.name,
    required this.query,
    required this.dataset,
  });
}