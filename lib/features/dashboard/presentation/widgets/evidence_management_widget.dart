import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/evidence_models.dart';
import '../../data/mock_evidence_data.dart';

class EvidenceManagementWidget extends ConsumerStatefulWidget {
  const EvidenceManagementWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<EvidenceManagementWidget> createState() => _EvidenceManagementWidgetState();
}

class _EvidenceManagementWidgetState extends ConsumerState<EvidenceManagementWidget> {
  String _selectedTab = 'overview';
  EvidenceType? _filterType;
  VerificationStatus? _filterStatus;
  String _searchQuery = '';
  Evidence? _selectedEvidence;
  
  late List<Evidence> _evidenceList;
  late Map<String, dynamic> _statistics;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _evidenceList = MockEvidenceData.generateMockEvidence(50);
    _statistics = _calculateStatistics();
  }

  Map<String, dynamic> _calculateStatistics() {
    return {
      'total': _evidenceList.length,
      'verified': _evidenceList.where((e) => e.status == VerificationStatus.verified).length,
      'pending': _evidenceList.where((e) => e.status == VerificationStatus.pending).length,
      'rejected': _evidenceList.where((e) => e.status == VerificationStatus.rejected).length,
      'flagged': _evidenceList.where((e) => e.status == VerificationStatus.flagged).length,
      'avgQuality': _evidenceList.isEmpty ? 0.0 : _evidenceList.map((e) => e.qualityScore).reduce((a, b) => a + b) / _evidenceList.length,
      'withLocation': _evidenceList.where((e) => e.location != null).length,
      'blockchain': _evidenceList.where((e) => e.blockchainAnchor != null).length,
    };
  }

  List<Evidence> get _filteredEvidence {
    return _evidenceList.where((evidence) {
      if (_filterType != null && evidence.type != _filterType) return false;
      if (_filterStatus != null && evidence.status != _filterStatus) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return evidence.fileName.toLowerCase().contains(query) ||
               evidence.projectName.toLowerCase().contains(query) ||
               (evidence.description?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatisticsBar(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.photo_library, size: 32, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evidence Management Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-Powered Evidence Classification & Verification',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showUploadDialog(),
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Evidence'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          _buildStatCard('Total Evidence', _statistics['total'].toString(), Icons.inventory_2, Colors.blue),
          _buildStatCard('Verified', _statistics['verified'].toString(), Icons.verified, Colors.green),
          _buildStatCard('Pending Review', _statistics['pending'].toString(), Icons.pending, Colors.orange),
          _buildStatCard('Flagged', _statistics['flagged'].toString(), Icons.flag, Colors.red),
          _buildStatCard('Avg Quality', '${(_statistics['avgQuality'] * 100).toStringAsFixed(0)}%', Icons.star, Colors.amber),
          _buildStatCard('Blockchain', _statistics['blockchain'].toString(), Icons.lock, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        _buildTab('overview', 'Overview', Icons.dashboard),
        _buildTab('gallery', 'Gallery', Icons.photo_library),
        _buildTab('timeline', 'Timeline', Icons.timeline),
        _buildTab('duplicates', 'Duplicates', Icons.content_copy),
        _buildTab('map', 'Geospatial', Icons.map),
        _buildTab('blockchain', 'Blockchain', Icons.security),
        const Spacer(),
        _buildFilters(),
      ],
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final isSelected = _selectedTab == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Colors.blue[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedTab = id),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search evidence...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<EvidenceType>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 18),
                const SizedBox(width: 8),
                Text(_filterType?.toString().split('.').last ?? 'All Types'),
              ],
            ),
          ),
          onSelected: (type) => setState(() => _filterType = type),
          itemBuilder: (context) => [
            const PopupMenuItem(value: null, child: Text('All Types')),
            ...EvidenceType.values.map((type) => PopupMenuItem(
              value: type,
              child: Text(type.toString().split('.').last),
            )),
          ],
        ),
        const SizedBox(width: 12),
        PopupMenuButton<VerificationStatus>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 18),
                const SizedBox(width: 8),
                Text(_filterStatus?.toString().split('.').last ?? 'All Status'),
              ],
            ),
          ),
          onSelected: (status) => setState(() => _filterStatus = status),
          itemBuilder: (context) => [
            const PopupMenuItem(value: null, child: Text('All Status')),
            ...VerificationStatus.values.map((status) => PopupMenuItem(
              value: status,
              child: Text(status.toString().split('.').last),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'gallery':
        return _buildGalleryView();
      case 'timeline':
        return _buildTimelineView();
      case 'duplicates':
        return _buildDuplicatesView();
      case 'map':
        return _buildMapView();
      case 'blockchain':
        return _buildBlockchainView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    final filteredList = _filteredEvidence;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQualityDistribution(),
          const SizedBox(height: 24),
          _buildRecentEvidence(filteredList),
        ],
      ),
    );
  }

  Widget _buildQualityDistribution() {
    final highQuality = _evidenceList.where((e) => e.qualityScore >= 0.8).length;
    final mediumQuality = _evidenceList.where((e) => e.qualityScore >= 0.5 && e.qualityScore < 0.8).length;
    final lowQuality = _evidenceList.where((e) => e.qualityScore < 0.5).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Score Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: highQuality,
                child: Container(
                  height: 40,
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      '$highQuality High',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: mediumQuality,
                child: Container(
                  height: 40,
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      '$mediumQuality Medium',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: lowQuality,
                child: Container(
                  height: 40,
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      '$lowQuality Low',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEvidence(List<Evidence> evidenceList) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence List (${evidenceList.length} items)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: evidenceList.length,
            itemBuilder: (context, index) => _buildEvidenceCard(evidenceList[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(Evidence evidence) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildEvidenceIcon(evidence.type),
        title: Text(
          evidence.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${evidence.projectName}'),
            Text('Uploaded: ${_formatDate(evidence.uploadedAt)} by ${evidence.uploadedBy}'),
            Row(
              children: [
                _buildStatusChip(evidence.status),
                const SizedBox(width: 8),
                _buildQualityChip(evidence.qualityScore),
                if (evidence.blockchainAnchor != null) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Blockchain', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.purple,
                    labelStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showEvidenceDetails(evidence),
        ),
        onTap: () => _showEvidenceDetails(evidence),
      ),
    );
  }

  Widget _buildEvidenceIcon(EvidenceType type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case EvidenceType.photo:
        icon = Icons.photo;
        color = Colors.blue;
        break;
      case EvidenceType.document:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case EvidenceType.video:
        icon = Icons.videocam;
        color = Colors.red;
        break;
      case EvidenceType.invoice:
        icon = Icons.receipt_long;
        color = Colors.orange;
        break;
      case EvidenceType.receipt:
        icon = Icons.receipt;
        color = Colors.amber;
        break;
      case EvidenceType.report:
        icon = Icons.article;
        color = Colors.blue;
        break;
      case EvidenceType.certificate:
        icon = Icons.verified;
        color = Colors.green;
        break;
      case EvidenceType.other:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
        break;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildStatusChip(VerificationStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case VerificationStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case VerificationStatus.verified:
        color = Colors.green;
        label = 'Verified';
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case VerificationStatus.flagged:
        color = Colors.red[900]!;
        label = 'Flagged';
        break;
    }
    
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildQualityChip(double score) {
    Color color;
    if (score >= 0.8) {
      color = Colors.green;
    } else if (score >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Chip(
      label: Text('Quality: ${(score * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildGalleryView() {
    final filteredList = _filteredEvidence;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) => _buildGalleryCard(filteredList[index]),
    );
  }

  Widget _buildGalleryCard(Evidence evidence) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEvidenceDetails(evidence),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: _buildEvidenceIcon(evidence.type),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evidence.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: _buildQualityChip(evidence.qualityScore)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView() {
    final sortedEvidence = List<Evidence>.from(_filteredEvidence)
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    
    return ListView.builder(
      itemCount: sortedEvidence.length,
      itemBuilder: (context, index) => _buildTimelineItem(sortedEvidence[index], index),
    );
  }

  Widget _buildTimelineItem(Evidence evidence, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, color: Colors.white, size: 12),
              ),
              if (index < _filteredEvidence.length - 1)
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.blue[200],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildEvidenceIcon(evidence.type),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                evidence.fileName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                _formatDate(evidence.uploadedAt),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(evidence.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Project: ${evidence.projectName}'),
                    Text('Uploaded by: ${evidence.uploadedBy}'),
                    if (evidence.description != null) ...[
                      const SizedBox(height: 8),
                      Text(evidence.description!, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicatesView() {
    final duplicateGroups = _findDuplicateGroups();
    
    return ListView.builder(
      itemCount: duplicateGroups.length,
      itemBuilder: (context, index) {
        final group = duplicateGroups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: const Icon(Icons.content_copy, color: Colors.red),
            title: Text('Duplicate Group ${index + 1} (${group.length} items)'),
            subtitle: Text('Similarity: ${(group[0].qualityScore * 100).toStringAsFixed(0)}%'),
            children: group.map((evidence) => _buildEvidenceCard(evidence)).toList(),
          ),
        );
      },
    );
  }

  List<List<Evidence>> _findDuplicateGroups() {
    final groups = <List<Evidence>>[];
    final processed = <String>{};
    
    for (final evidence in _evidenceList) {
      if (processed.contains(evidence.id)) continue;
      
      final duplicates = evidence.relatedEvidenceIds
          .map((id) => _evidenceList.firstWhere((e) => e.id == id, orElse: () => evidence))
          .where((e) => e.id != evidence.id)
          .toList();
      
      if (duplicates.isNotEmpty) {
        duplicates.insert(0, evidence);
        groups.add(duplicates);
        for (final dup in duplicates) {
          processed.add(dup.id);
        }
      }
    }
    
    return groups;
  }

  Widget _buildMapView() {
    final evidenceWithLocation = _evidenceList.where((e) => e.location != null).toList();
    
    return Column(
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Interactive Map View',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${evidenceWithLocation.length} evidence items with location data',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: evidenceWithLocation.length,
            itemBuilder: (context, index) => _buildEvidenceCard(evidenceWithLocation[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockchainView() {
    final blockchainEvidence = _evidenceList.where((e) => e.blockchainAnchor != null).toList();
    
    return ListView.builder(
      itemCount: blockchainEvidence.length,
      itemBuilder: (context, index) {
        final evidence = blockchainEvidence[index];
        final anchor = evidence.blockchainAnchor!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildEvidenceIcon(evidence.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        evidence.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const Chip(
                      label: Text('Blockchain Secured', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.purple,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildBlockchainInfo('Transaction Hash', anchor.transactionHash),
                _buildBlockchainInfo('Block Number', anchor.blockNumber),
                _buildBlockchainInfo('Network', anchor.network),
                _buildBlockchainInfo('Timestamp', _formatDate(anchor.timestamp)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockchainInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(color: Colors.grey[800], fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Evidence'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'File Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Evidence upload functionality to be implemented')),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showEvidenceDetails(Evidence evidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evidence.fileName),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Project', evidence.projectName),
                _buildDetailRow('Type', evidence.type.toString().split('.').last),
                _buildDetailRow('Status', evidence.status.toString().split('.').last),
                _buildDetailRow('Quality Score', '${(evidence.qualityScore * 100).toStringAsFixed(0)}%'),
                _buildDetailRow('Uploaded By', evidence.uploadedBy),
                _buildDetailRow('Uploaded At', _formatDate(evidence.uploadedAt)),
                if (evidence.description != null)
                  _buildDetailRow('Description', evidence.description!),
                if (evidence.location != null) ...[
                  const Divider(height: 24),
                  Text('Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  _buildDetailRow('Latitude', evidence.location!.latitude.toString()),
                  _buildDetailRow('Longitude', evidence.location!.longitude.toString()),
                  if (evidence.location!.address != null)
                    _buildDetailRow('Address', evidence.location!.address!),
                ],
                if (evidence.tags.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: evidence.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ],
              ],
            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}