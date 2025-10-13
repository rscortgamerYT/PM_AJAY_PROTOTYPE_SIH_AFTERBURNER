import 'package:flutter/material.dart';
import '../services/watermark_service.dart';
import '../../dashboard/models/evidence_models.dart';

/// Tamper-Evident Evidence Widget for Claims Tab
class TamperEvidentEvidenceWidget extends StatefulWidget {
  final String projectId;
  final String uploaderName;
  final Function(Evidence)? onEvidenceUploaded;

  const TamperEvidentEvidenceWidget({
    super.key,
    required this.projectId,
    required this.uploaderName,
    this.onEvidenceUploaded,
  });

  @override
  State<TamperEvidentEvidenceWidget> createState() => _TamperEvidentEvidenceWidgetState();
}

class _TamperEvidentEvidenceWidgetState extends State<TamperEvidentEvidenceWidget> {
  final List<WatermarkedEvidence> _watermarkedEvidence = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadMockEvidence();
  }

  void _loadMockEvidence() {
    // Mock watermarked evidence data
    final mockEvidence = [
      WatermarkedEvidence(
        id: 'WM001',
        fileName: 'foundation_work_progress.jpg',
        originalSize: '2.4 MB',
        watermarkedSize: '2.5 MB',
        projectId: widget.projectId,
        uploaderName: widget.uploaderName,
        uploadTimestamp: DateTime.now().subtract(const Duration(days: 2)),
        watermarkPosition: WatermarkPosition.bottomRight,
        isExifLocked: true,
        verificationStatus: WatermarkVerificationStatus.verified,
        thumbnailUrl: 'assets/images/foundation_thumb.jpg',
      ),
      WatermarkedEvidence(
        id: 'WM002',
        fileName: 'material_delivery_receipt.pdf',
        originalSize: '1.1 MB',
        watermarkedSize: '1.2 MB',
        projectId: widget.projectId,
        uploaderName: 'Site Engineer',
        uploadTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        watermarkPosition: WatermarkPosition.bottomLeft,
        isExifLocked: true,
        verificationStatus: WatermarkVerificationStatus.verified,
        thumbnailUrl: 'assets/images/receipt_thumb.jpg',
      ),
      WatermarkedEvidence(
        id: 'WM003',
        fileName: 'quality_inspection_photos.zip',
        originalSize: '15.8 MB',
        watermarkedSize: '16.2 MB',
        projectId: widget.projectId,
        uploaderName: 'Quality Inspector',
        uploadTimestamp: DateTime.now().subtract(const Duration(hours: 6)),
        watermarkPosition: WatermarkPosition.topRight,
        isExifLocked: true,
        verificationStatus: WatermarkVerificationStatus.pending,
        thumbnailUrl: 'assets/images/inspection_thumb.jpg',
      ),
    ];

    setState(() {
      _watermarkedEvidence.addAll(mockEvidence);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildUploadSection(),
          const SizedBox(height: 24),
          _buildEvidenceList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.verified_user,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tamper-Evident Evidence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Watermarked files with EXIF lock protection',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final verifiedCount = _watermarkedEvidence
        .where((e) => e.verificationStatus == WatermarkVerificationStatus.verified)
        .length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Text(
        '$verifiedCount/${_watermarkedEvidence.length} Verified',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Upload Evidence',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_isProcessing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Files will be automatically watermarked with project ID, timestamp, and uploader information. EXIF metadata will be locked to prevent tampering.',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateFileUpload,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Upload Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateDocumentUpload,
                  icon: const Icon(Icons.description),
                  label: const Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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

  Widget _buildEvidenceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watermarked Evidence (${_watermarkedEvidence.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_watermarkedEvidence.isEmpty)
          _buildEmptyState()
        else
          ...(_watermarkedEvidence.map((evidence) => _buildEvidenceCard(evidence))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            color: Colors.grey.shade600,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No watermarked evidence yet',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload files to create tamper-evident evidence',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(WatermarkedEvidence evidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          _buildThumbnail(evidence),
          const SizedBox(width: 16),
          Expanded(
            child: _buildEvidenceDetails(evidence),
          ),
          _buildEvidenceActions(evidence),
        ],
      ),
    );
  }

  Widget _buildThumbnail(WatermarkedEvidence evidence) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getFileTypeIcon(evidence.fileName),
              color: Colors.blue,
              size: 28,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceDetails(WatermarkedEvidence evidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                evidence.fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildVerificationBadge(evidence.verificationStatus),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Uploaded by ${evidence.uploaderName}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatTimestamp(evidence.uploadTimestamp),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildFeatureBadge('Watermarked', Colors.blue),
            const SizedBox(width: 6),
            if (evidence.isExifLocked)
              _buildFeatureBadge('EXIF Lock', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildEvidenceActions(WatermarkedEvidence evidence) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: Colors.grey.shade800,
      onSelected: (action) => _handleEvidenceAction(action, evidence),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'preview',
          child: ListTile(
            leading: Icon(Icons.visibility, color: Colors.blue),
            title: Text('View Watermark', style: TextStyle(color: Colors.white)),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'verify',
          child: ListTile(
            leading: Icon(Icons.verified_user, color: Colors.green),
            title: Text('Verify Integrity', style: TextStyle(color: Colors.white)),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'exif',
          child: ListTile(
            leading: Icon(Icons.info, color: Colors.orange),
            title: Text('View EXIF Data', style: TextStyle(color: Colors.white)),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: ListTile(
            leading: Icon(Icons.download, color: Colors.grey),
            title: Text('Download', style: TextStyle(color: Colors.white)),
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(WatermarkVerificationStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case WatermarkVerificationStatus.verified:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Verified';
        break;
      case WatermarkVerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        text = 'Pending';
        break;
      case WatermarkVerificationStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _simulateFileUpload() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate upload process
    await Future.delayed(const Duration(seconds: 2));

    final newEvidence = WatermarkedEvidence(
      id: 'WM${DateTime.now().millisecondsSinceEpoch}',
      fileName: 'new_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg',
      originalSize: '2.1 MB',
      watermarkedSize: '2.2 MB',
      projectId: widget.projectId,
      uploaderName: widget.uploaderName,
      uploadTimestamp: DateTime.now(),
      watermarkPosition: WatermarkPosition.bottomRight,
      isExifLocked: true,
      verificationStatus: WatermarkVerificationStatus.pending,
      thumbnailUrl: '',
    );

    setState(() {
      _watermarkedEvidence.insert(0, newEvidence);
      _isProcessing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evidence uploaded and watermarked successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _simulateDocumentUpload() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    final newEvidence = WatermarkedEvidence(
      id: 'WM${DateTime.now().millisecondsSinceEpoch}',
      fileName: 'document_${DateTime.now().millisecondsSinceEpoch}.pdf',
      originalSize: '1.5 MB',
      watermarkedSize: '1.6 MB',
      projectId: widget.projectId,
      uploaderName: widget.uploaderName,
      uploadTimestamp: DateTime.now(),
      watermarkPosition: WatermarkPosition.bottomLeft,
      isExifLocked: true,
      verificationStatus: WatermarkVerificationStatus.pending,
      thumbnailUrl: '',
    );

    setState(() {
      _watermarkedEvidence.insert(0, newEvidence);
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document uploaded and watermarked successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleEvidenceAction(String action, WatermarkedEvidence evidence) {
    switch (action) {
      case 'preview':
        _showWatermarkPreview(evidence);
        break;
      case 'verify':
        _verifyEvidenceIntegrity(evidence);
        break;
      case 'exif':
        _showExifData(evidence);
        break;
      case 'download':
        _downloadEvidence(evidence);
        break;
    }
  }

  void _showWatermarkPreview(WatermarkedEvidence evidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Watermark Preview',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade600),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 64),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PROJECT: ${evidence.projectId}\nUPLOADED: ${evidence.uploaderName}\nDATE: ${_formatTimestamp(evidence.uploadTimestamp)}\nTAMPER-EVIDENT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Watermark applied at ${evidence.watermarkPosition.name} position',
              style: TextStyle(color: Colors.grey.shade400),
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

  void _verifyEvidenceIntegrity(WatermarkedEvidence evidence) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          evidence.verificationStatus == WatermarkVerificationStatus.verified
              ? 'Evidence integrity verified ✓'
              : 'Verifying evidence integrity...',
        ),
        backgroundColor: evidence.verificationStatus == WatermarkVerificationStatus.verified
            ? Colors.green
            : Colors.orange,
      ),
    );
  }

  void _showExifData(WatermarkedEvidence evidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('EXIF Metadata', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExifRow('Project ID', evidence.projectId),
            _buildExifRow('Uploader', evidence.uploaderName),
            _buildExifRow('Timestamp', evidence.uploadTimestamp.toIso8601String()),
            _buildExifRow('EXIF Locked', evidence.isExifLocked ? 'Yes' : 'No'),
            _buildExifRow('Tamper Seal', 'A1B2C3D4E5F6'),
            _buildExifRow('Integrity Hash', 'SHA256:abcdef123456'),
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

  Widget _buildExifRow(String label, String value) {
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
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadEvidence(WatermarkedEvidence evidence) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${evidence.fileName}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

// Supporting models
class WatermarkedEvidence {
  final String id;
  final String fileName;
  final String originalSize;
  final String watermarkedSize;
  final String projectId;
  final String uploaderName;
  final DateTime uploadTimestamp;
  final WatermarkPosition watermarkPosition;
  final bool isExifLocked;
  final WatermarkVerificationStatus verificationStatus;
  final String thumbnailUrl;

  const WatermarkedEvidence({
    required this.id,
    required this.fileName,
    required this.originalSize,
    required this.watermarkedSize,
    required this.projectId,
    required this.uploaderName,
    required this.uploadTimestamp,
    required this.watermarkPosition,
    required this.isExifLocked,
    required this.verificationStatus,
    required this.thumbnailUrl,
  });
}

enum WatermarkVerificationStatus {
  verified,
  pending,
  failed,
}