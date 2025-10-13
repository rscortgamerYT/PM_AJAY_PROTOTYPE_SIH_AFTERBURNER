import 'package:flutter/material.dart';
import '../../../core/models/blockchain_models.dart';
import '../../../core/services/blockchain_service.dart';

/// Smart Contract Release Triggers Widget for automated fund disbursals
class SmartContractReleaseWidget extends StatefulWidget {
  final String? dashboardType; // 'overwatch', 'state', 'centre', 'public'
  final bool showCreateInterface;
  
  const SmartContractReleaseWidget({
    super.key,
    this.dashboardType = 'centre',
    this.showCreateInterface = true,
  });

  @override
  State<SmartContractReleaseWidget> createState() => _SmartContractReleaseWidgetState();
}

class _SmartContractReleaseWidgetState extends State<SmartContractReleaseWidget> {
  final BlockchainService _blockchainService = BlockchainService();
  List<SmartContractRelease> _releases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReleases();
  }

  Future<void> _loadReleases() async {
    try {
      setState(() => _isLoading = true);
      await _blockchainService.initialize();
      final releases = await _blockchainService.getSmartContractReleases();
      setState(() {
        _releases = releases;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.showCreateInterface) _buildCreateInterface(),
          Expanded(child: _buildReleasesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final nextAutoRelease = _releases.where((r) => r.releaseStatus == 'pending').isNotEmpty 
        ? _releases.where((r) => r.releaseStatus == 'pending').first 
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Contract Releases',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Automated fund disbursals',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (nextAutoRelease != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Auto-Release Enabled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (nextAutoRelease != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[300], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next Auto-Release: ₹${nextAutoRelease.releaseAmount.toStringAsFixed(1)}L for ${nextAutoRelease.projectId}',
                      style: TextStyle(
                        color: Colors.orange[200],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getOracleStatusColor(nextAutoRelease.oracleStatus),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nextAutoRelease.oracleStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateInterface() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Auto-Release Trigger',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add_circle, size: 16),
                  label: const Text('New Release'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showOracleStatus,
                  icon: const Icon(Icons.sensors, size: 16),
                  label: const Text('Oracle Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReleasesList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 12),
            Text(
              'Loading smart contracts...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load contracts',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadReleases,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_releases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, color: Colors.grey[400], size: 48),
            const SizedBox(height: 12),
            Text(
              'No smart contracts configured',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _releases.length,
      itemBuilder: (context, index) {
        final release = _releases[index];
        return _buildReleaseCard(release);
      },
    );
  }

  Widget _buildReleaseCard(SmartContractRelease release) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReleaseHeader(release),
            const SizedBox(height: 12),
            _buildTriggerConditions(release),
            const SizedBox(height: 12),
            _buildOracleStatus(release),
            const SizedBox(height: 12),
            _buildReleaseTimeline(release),
            const SizedBox(height: 12),
            _buildActionButtons(release),
          ],
        ),
      ),
    );
  }

  Widget _buildReleaseHeader(SmartContractRelease release) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Project: ${release.projectId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getReleaseStatusColor(release.releaseStatus),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      release.releaseStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Milestone: ${release.milestoneId}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${release.releaseAmount.toStringAsFixed(1)}L',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Release Amount',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTriggerConditions(SmartContractRelease release) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trigger Conditions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...release.triggerConditions.entries.map((entry) {
            final isCompleted = entry.value == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatConditionName(entry.key),
                      style: TextStyle(
                        color: isCompleted ? Colors.green[300] : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOracleStatus(SmartContractRelease release) {
    final isActive = release.oracleStatus == 'active';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[900]?.withOpacity(0.3) : Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _getOracleStatusColor(release.oracleStatus)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sensors,
            color: _getOracleStatusColor(release.oracleStatus),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oracle Status: ${release.oracleStatus.toUpperCase()}',
                  style: TextStyle(
                    color: _getOracleStatusColor(release.oracleStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Chainlink Job ID: ${release.metadata['chainlink_job_id']}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getOracleStatusColor(release.oracleStatus),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseTimeline(SmartContractRelease release) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTimelineItem(
              'Created',
              _formatTimestamp(release.createdAt),
              true,
              Colors.blue,
            ),
            _buildTimelineConnector(release.triggeredAt != null),
            _buildTimelineItem(
              'Triggered',
              release.triggeredAt != null ? _formatTimestamp(release.triggeredAt!) : 'Pending',
              release.triggeredAt != null,
              Colors.orange,
            ),
            _buildTimelineConnector(release.releasedAt != null),
            _buildTimelineItem(
              'Released',
              release.releasedAt != null ? _formatTimestamp(release.releasedAt!) : 'Pending',
              release.releasedAt != null,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String label, String time, bool isCompleted, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isCompleted ? color : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isCompleted) {
    return Container(
      height: 2,
      width: 20,
      color: isCompleted ? Colors.green : Colors.grey[600],
      margin: const EdgeInsets.only(bottom: 30),
    );
  }

  Widget _buildActionButtons(SmartContractRelease release) {
    return Row(
      children: [
        if (release.releaseStatus == 'pending')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _triggerRelease(release),
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Trigger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        if (release.releaseStatus == 'pending') const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewContract(release),
            icon: const Icon(Icons.code, size: 16),
            label: const Text('Contract'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create Smart Contract Release', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure automated fund release conditions:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Project ID',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Release Amount (₹L)',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text(
              'Trigger Conditions:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Geo-verification', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Document verification', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: (value) {},
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
              _simulateContractCreation();
            },
            child: const Text('Deploy Contract'),
          ),
        ],
      ),
    );
  }

  void _showOracleStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Oracle Network Status', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[600]!),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors, color: Colors.blue, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chainlink Oracles',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Network: Goerli Testnet', style: TextStyle(color: Colors.grey)),
                      Text('Latency: 2.3s', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
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

  void _simulateContractCreation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.black87,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text('Deploying smart contract...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Smart contract deployed successfully'),
        backgroundColor: Colors.purple,
      ),
    );

    _loadReleases();
  }

  void _triggerRelease(SmartContractRelease release) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Triggering release for ${release.projectId}...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _viewContract(SmartContractRelease release) {
    final url = 'https://goerli.etherscan.io/address/${release.contractAddress}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would open contract: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getReleaseStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'triggered':
        return Colors.blue;
      case 'released':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOracleStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'updating':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatConditionName(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}