import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

/// Audit Log Widget
/// 
/// Displays comprehensive audit trail for all communication actions
class AuditLogWidget extends ConsumerStatefulWidget {
  const AuditLogWidget({super.key});

  @override
  ConsumerState<AuditLogWidget> createState() => _AuditLogWidgetState();
}

class _AuditLogWidgetState extends ConsumerState<AuditLogWidget> {
  String? _selectedModule;
  String? _selectedAction;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Audit Log',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _exportLogs,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module Filter
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedModule,
                      decoration: const InputDecoration(
                        labelText: 'Module',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Modules')),
                        DropdownMenuItem(value: 'chat', child: Text('Chat')),
                        DropdownMenuItem(value: 'tickets', child: Text('Tickets')),
                        DropdownMenuItem(value: 'tags', child: Text('Tags')),
                      ],
                      onChanged: (value) => setState(() => _selectedModule = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedAction,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Actions')),
                        DropdownMenuItem(value: 'create', child: Text('Create')),
                        DropdownMenuItem(value: 'read', child: Text('Read')),
                        DropdownMenuItem(value: 'update', child: Text('Update')),
                        DropdownMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                      onChanged: (value) => setState(() => _selectedAction = value),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date Range Filter
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDate != null
                            ? 'From: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Start Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _endDate != null
                            ? 'To: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'End Date',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Audit Log List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getMockAuditLogs().length,
            itemBuilder: (context, index) {
              final log = _getMockAuditLogs()[index];
              return _buildAuditLogCard(log);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogCard(Map<String, dynamic> log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActionColor(log['action']).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getActionIcon(log['action']),
            color: _getActionColor(log['action']),
          ),
        ),
        title: Text(
          '${log['action']} in ${log['module']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('User: ${log['userId']}'),
            Text('Details: ${log['details']}'),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(log['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGray,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export Entry'),
            ),
          ],
          onSelected: (value) {
            if (value == 'details') {
              _showLogDetails(log);
            }
          },
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Colors.green;
      case 'read':
        return Colors.blue;
      case 'update':
        return Colors.orange;
      case 'delete':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Icons.add_circle;
      case 'read':
        return Icons.visibility;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _getMockAuditLogs() {
    return [
      {
        'action': 'Create',
        'module': 'Tickets',
        'userId': 'user-123',
        'details': 'Created ticket #1234',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      },
      {
        'action': 'Update',
        'module': 'Chat',
        'userId': 'user-456',
        'details': 'Sent message in channel #general',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'action': 'Create',
        'module': 'Tags',
        'userId': 'user-789',
        'details': 'Created tag "urgent"',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'action': 'Update',
        'module': 'Tickets',
        'userId': 'user-123',
        'details': 'Updated ticket status to resolved',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      },
    ];
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Action', log['action']),
            _buildDetailRow('Module', log['module']),
            _buildDetailRow('User ID', log['userId']),
            _buildDetailRow('Details', log['details']),
            _buildDetailRow('Timestamp', _formatTimestamp(log['timestamp'])),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting audit logs...'),
      ),
    );
  }
}