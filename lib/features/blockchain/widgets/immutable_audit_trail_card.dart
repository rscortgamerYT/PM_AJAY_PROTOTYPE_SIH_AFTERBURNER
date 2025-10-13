import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/blockchain_models.dart';
import '../../../core/services/blockchain_service.dart';

/// Immutable Audit Trail Card for blockchain transaction hashing
class ImmutableAuditTrailCard extends StatefulWidget {
  final String? dashboardType; // 'overwatch', 'state', 'centre', 'public'
  
  const ImmutableAuditTrailCard({
    super.key,
    this.dashboardType = 'overwatch',
  });

  @override
  State<ImmutableAuditTrailCard> createState() => _ImmutableAuditTrailCardState();
}

class _ImmutableAuditTrailCardState extends State<ImmutableAuditTrailCard> {
  final BlockchainService _blockchainService = BlockchainService();
  AuditTrailStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuditTrailStats();
  }

  Future<void> _loadAuditTrailStats() async {
    try {
      setState(() => _isLoading = true);
      await _blockchainService.initialize();
      final stats = await _blockchainService.getAuditTrailStats();
      setState(() {
        _stats = stats;
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
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
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
                  'Blockchain Audit Trail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Immutable transaction verification',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_stats != null) _buildNetworkStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusIndicator() {
    final isConnected = _stats!.networkStatus == 'connected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[900] : Colors.red[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Live' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 12),
            Text(
              'Loading blockchain data...',
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
              'Failed to load audit trail',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadAuditTrailStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildAuditTrailStats();
  }

  Widget _buildAuditTrailStats() {
    if (_stats == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMainStats(),
          const SizedBox(height: 16),
          _buildIntegrityIndicator(),
          const SizedBox(height: 16),
          _buildLastBlockInfo(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Transactions Anchored',
            '${_stats!.totalTransactionsAnchored}',
            Icons.anchor,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Integrity Score',
            '${_stats!.integrityPercentage.toStringAsFixed(1)}%',
            Icons.verified_user,
            _stats!.integrityPercentage >= 95 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrityIndicator() {
    final percentage = _stats!.integrityPercentage;
    final color = percentage >= 95 ? Colors.green : percentage >= 80 ? Colors.orange : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Blockchain Integrity',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[600],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Text(
            percentage >= 95 
                ? 'All transactions secured'
                : percentage >= 80
                    ? 'Some transactions pending'
                    : 'Network issues detected',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastBlockInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Block',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.tag, color: Colors.grey[400], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_stats!.lastBlockHash.substring(0, 20)}...',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(_stats!.lastBlockHash),
                child: const Icon(Icons.copy, color: Colors.blue, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Updated ${_formatTimestamp(_stats!.lastAnchorTimestamp)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _viewOnExplorer(_stats!.lastBlockHash),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View on Explorer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _loadAuditTrailStats,
          icon: const Icon(Icons.refresh, color: Colors.white70),
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewOnExplorer(String blockHash) {
    final url = 'https://goerli.etherscan.io/block/$blockHash';
    // Note: url_launcher would be used in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would open: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
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