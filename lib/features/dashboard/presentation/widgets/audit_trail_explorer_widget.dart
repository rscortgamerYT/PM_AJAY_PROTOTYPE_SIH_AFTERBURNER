import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Audit Trail Explorer Widget
/// 
/// Blockchain-inspired immutable action logs with
/// advanced filtering, search, and export capabilities.
class AuditTrailExplorerWidget extends StatefulWidget {
  final String userId;
  
  const AuditTrailExplorerWidget({
    super.key,
    required this.userId,
  });

  @override
  State<AuditTrailExplorerWidget> createState() => 
      _AuditTrailExplorerWidgetState();
}

class _AuditTrailExplorerWidgetState 
    extends State<AuditTrailExplorerWidget> {
  
  String _searchQuery = '';
  String _selectedActionType = 'all';
  String _selectedUser = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<AuditLogEntry> _mockLogs = [
    AuditLogEntry(
      id: 'log_001',
      timestamp: DateTime(2025, 10, 10, 14, 30),
      userId: 'user_001',
      userName: 'John Doe',
      userRole: 'State Officer',
      actionType: AuditActionType.approval,
      actionDescription: 'Approved project milestone: Site Survey',
      entityType: 'Project',
      entityId: 'project_001',
      entityName: 'Water Supply - Sector A',
      ipAddress: '192.168.1.1',
      deviceInfo: 'Chrome 120 on Windows 11',
      changesDetail: {
        'status': {'old': 'pending', 'new': 'approved'},
        'approvedBy': {'old': null, 'new': 'user_001'},
      },
      hashPrevious: '0x1a2b3c4d5e6f',
      hashCurrent: '0x7g8h9i0j1k2l',
    ),
    AuditLogEntry(
      id: 'log_002',
      timestamp: DateTime(2025, 10, 10, 13, 15),
      userId: 'user_002',
      userName: 'Jane Smith',
      userRole: 'Agency User',
      actionType: AuditActionType.submission,
      actionDescription: 'Submitted evidence for milestone completion',
      entityType: 'Milestone',
      entityId: 'milestone_002',
      entityName: 'Design Approval',
      ipAddress: '192.168.1.2',
      deviceInfo: 'Safari 17 on iOS 17',
      changesDetail: {
        'evidenceCount': {'old': '0', 'new': '3'},
        'status': {'old': 'active', 'new': 'in_review'},
      },
      hashPrevious: '0x7g8h9i0j1k2l',
      hashCurrent: '0x3m4n5o6p7q8r',
    ),
    AuditLogEntry(
      id: 'log_003',
      timestamp: DateTime(2025, 10, 10, 12, 00),
      userId: 'user_003',
      userName: 'Admin User',
      userRole: 'Centre Admin',
      actionType: AuditActionType.fundTransfer,
      actionDescription: 'Released funds to State: Maharashtra',
      entityType: 'Fund',
      entityId: 'fund_001',
      entityName: 'Q1 Fund Release',
      ipAddress: '192.168.1.3',
      deviceInfo: 'Firefox 121 on Ubuntu 22.04',
      changesDetail: {
        'amount': {'old': '0', 'new': '5000000'},
        'status': {'old': 'pending', 'new': 'released'},
      },
      hashPrevious: '0x3m4n5o6p7q8r',
      hashCurrent: '0x9s0t1u2v3w4x',
    ),
    AuditLogEntry(
      id: 'log_004',
      timestamp: DateTime(2025, 10, 10, 11, 30),
      userId: 'user_004',
      userName: 'Overwatch Monitor',
      userRole: 'Overwatch',
      actionType: AuditActionType.rejection,
      actionDescription: 'Rejected milestone due to insufficient evidence',
      entityType: 'Milestone',
      entityId: 'milestone_003',
      entityName: 'Material Procurement',
      ipAddress: '192.168.1.4',
      deviceInfo: 'Edge 120 on Windows 10',
      changesDetail: {
        'status': {'old': 'in_review', 'new': 'rejected'},
        'rejectionReason': {'old': null, 'new': 'Insufficient documentation'},
      },
      hashPrevious: '0x9s0t1u2v3w4x',
      hashCurrent: '0x5y6z7a8b9c0d',
    ),
    AuditLogEntry(
      id: 'log_005',
      timestamp: DateTime(2025, 10, 10, 10, 15),
      userId: 'user_002',
      userName: 'Jane Smith',
      userRole: 'Agency User',
      actionType: AuditActionType.update,
      actionDescription: 'Updated project timeline',
      entityType: 'Project',
      entityId: 'project_001',
      entityName: 'Water Supply - Sector A',
      ipAddress: '192.168.1.2',
      deviceInfo: 'Safari 17 on iOS 17',
      changesDetail: {
        'completionDate': {'old': '2025-06-30', 'new': '2025-07-15'},
      },
      hashPrevious: '0x5y6z7a8b9c0d',
      hashCurrent: '0x1e2f3g4h5i6j',
    ),
  ];

  List<AuditLogEntry> get _filteredLogs {
    var filtered = _mockLogs.where((log) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!log.actionDescription.toLowerCase().contains(query) &&
            !log.userName.toLowerCase().contains(query) &&
            !log.entityName.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Action type filter
      if (_selectedActionType != 'all' && 
          log.actionType.name != _selectedActionType) {
        return false;
      }
      
      // User filter
      if (_selectedUser != 'all' && log.userId != _selectedUser) {
        return false;
      }
      
      // Date range filter
      if (_startDate != null && log.timestamp.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && log.timestamp.isAfter(_endDate!)) {
        return false;
      }
      
      return true;
    });
    
    return filtered.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Color _getActionTypeColor(AuditActionType type) {
    switch (type) {
      case AuditActionType.approval:
        return AppTheme.successGreen;
      case AuditActionType.rejection:
        return AppTheme.errorRed;
      case AuditActionType.submission:
        return AppTheme.secondaryBlue;
      case AuditActionType.update:
        return AppTheme.warningOrange;
      case AuditActionType.fundTransfer:
        return AppTheme.accentTeal;
      case AuditActionType.deletion:
        return AppTheme.errorRed;
    }
  }

  IconData _getActionTypeIcon(AuditActionType type) {
    switch (type) {
      case AuditActionType.approval:
        return Icons.check_circle;
      case AuditActionType.rejection:
        return Icons.cancel;
      case AuditActionType.submission:
        return Icons.upload;
      case AuditActionType.update:
        return Icons.edit;
      case AuditActionType.fundTransfer:
        return Icons.payments;
      case AuditActionType.deletion:
        return Icons.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _buildLogsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.overwatchColor, Colors.pink.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audit Trail Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Blockchain-inspired immutable action logs',
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
                _mockLogs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total Logs',
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
                _filteredLogs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Filtered',
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search logs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedActionType,
                  decoration: const InputDecoration(
                    labelText: 'Action Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Types')),
                    ...AuditActionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type.name,
                        child: Text(type.name.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedActionType = value);
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUser,
                  decoration: const InputDecoration(
                    labelText: 'User',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Users')),
                    ..._mockLogs.map((log) => log.userId).toSet().map((userId) {
                      final user = _mockLogs.firstWhere((l) => l.userId == userId);
                      return DropdownMenuItem(
                        value: userId,
                        child: Text(user.userName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedUser = value);
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              IconButton.outlined(
                onPressed: () {},
                icon: const Icon(Icons.download),
                tooltip: 'Export Logs',
              ),
              
              IconButton.outlined(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedActionType = 'all';
                    _selectedUser = 'all';
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Clear Filters',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    if (_filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No logs found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        return _buildLogCard(_filteredLogs[index], index);
      },
    );
  }

  Widget _buildLogCard(AuditLogEntry log, int index) {
    final actionColor = _getActionTypeColor(log.actionType);
    final actionIcon = _getActionTypeIcon(log.actionType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: actionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(actionIcon, color: actionColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.actionDescription,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.actionType.name.toUpperCase(),
                style: TextStyle(
                  color: actionColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${log.userName} (${log.userRole})'),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(_formatDateTime(log.timestamp)),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entity Info
                _buildInfoRow('Entity', '${log.entityType}: ${log.entityName}'),
                const Divider(),
                
                // User Info
                _buildInfoRow('User ID', log.userId),
                _buildInfoRow('IP Address', log.ipAddress),
                _buildInfoRow('Device', log.deviceInfo),
                const Divider(),
                
                // Blockchain Hashes
                const Text(
                  'Blockchain Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHashRow('Previous Hash', log.hashPrevious),
                _buildHashRow('Current Hash', log.hashCurrent),
                const Divider(),
                
                // Changes Detail
                if (log.changesDetail.isNotEmpty) ...[
                  const Text(
                    'Changes Detail',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...log.changesDetail.entries.map((entry) {
                    return _buildChangeRow(
                      entry.key,
                      entry.value['old']?.toString() ?? 'null',
                      entry.value['new']?.toString() ?? 'null',
                    );
                  }),
                ],
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.verified, size: 16),
                        label: const Text('Verify Chain'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('View Entity'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String hash) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                hash,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String field, String oldValue, String newValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$field:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    oldValue,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.errorRed,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    newValue,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Audit Log Entry Model
class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userRole;
  final AuditActionType actionType;
  final String actionDescription;
  final String entityType;
  final String entityId;
  final String entityName;
  final String ipAddress;
  final String deviceInfo;
  final Map<String, Map<String, dynamic>> changesDetail;
  final String hashPrevious;
  final String hashCurrent;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.actionType,
    required this.actionDescription,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    required this.ipAddress,
    required this.deviceInfo,
    required this.changesDetail,
    required this.hashPrevious,
    required this.hashCurrent,
  });
}

/// Audit Action Type Enum
enum AuditActionType {
  approval,
  rejection,
  submission,
  update,
  fundTransfer,
  deletion,
}