import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/milestone_claim_model.dart';
import '../../../../../core/theme/app_design_system.dart';

/// Milestone claim approval widget with AI fraud detection
class MilestoneClaimApprovalWidget extends StatefulWidget {
  final List<MilestoneClaim> claims;
  final Function(MilestoneClaim, ClaimStatus, String?)? onClaimAction;

  const MilestoneClaimApprovalWidget({
    super.key,
    required this.claims,
    this.onClaimAction,
  });

  @override
  State<MilestoneClaimApprovalWidget> createState() => _MilestoneClaimApprovalWidgetState();
}

class _MilestoneClaimApprovalWidgetState extends State<MilestoneClaimApprovalWidget>
    with SingleTickerProviderStateMixin {
  MilestoneClaim? _selectedClaim;
  late TabController _tabController;
  ClaimStatus _filterStatus = ClaimStatus.pending;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<MilestoneClaim> _getFilteredClaims() {
    return widget.claims.where((claim) => claim.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDesignSystem.radiusLarge,
        border: Border.all(
          color: AppDesignSystem.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildStatusTabs(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildClaimsList(),
                ),
                if (_selectedClaim != null) ...[
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: _buildClaimDetails(_selectedClaim!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppDesignSystem.neutral300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Milestone Claims Approval',
                style: AppDesignSystem.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'AI-Powered Fraud Detection & Verification',
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.neutral600,
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _buildStatCard(
                    'Pending',
                    widget.claims.where((c) => c.status == ClaimStatus.pending).length.toString(),
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Under Review',
                    widget.claims.where((c) => c.status == ClaimStatus.underReview).length.toString(),
                    Colors.blue,
                    Icons.search,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'High Risk',
                    widget.claims
                        .where((c) => c.fraudAnalysis?.riskLevel == FraudRiskLevel.high)
                        .length
                        .toString(),
                    Colors.red,
                    Icons.warning,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppDesignSystem.radiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppDesignSystem.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppDesignSystem.neutral300,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        onTap: (index) {
          setState(() {
            _filterStatus = ClaimStatus.values[index];
            _selectedClaim = null;
          });
        },
        tabs: ClaimStatus.values.map((status) {
          final count = widget.claims.where((c) => c.status == status).length;
          return Tab(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(status.label),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClaimsList() {
    final claims = _getFilteredClaims();

    if (claims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox,
              size: 64,
              color: AppDesignSystem.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_filterStatus.label} Claims',
              style: AppDesignSystem.titleMedium.copyWith(
                color: AppDesignSystem.neutral600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: claims.length,
      itemBuilder: (context, index) {
        final claim = claims[index];
        final isSelected = _selectedClaim?.id == claim.id;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppDesignSystem.deepIndigo.withOpacity(0.1)
                  : Colors.white,
              borderRadius: AppDesignSystem.radiusMedium,
              border: Border.all(
                color: isSelected
                    ? AppDesignSystem.deepIndigo
                    : AppDesignSystem.neutral300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () {
                setState(() {
                  _selectedClaim = claim;
                });
              },
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: claim.fraudAnalysis != null
                      ? claim.fraudAnalysis!.riskLevel.color.withOpacity(0.2)
                      : AppDesignSystem.neutral200,
                  borderRadius: AppDesignSystem.radiusSmall,
                ),
                child: Icon(
                  claim.fraudAnalysis != null
                      ? (claim.fraudAnalysis!.riskLevel == FraudRiskLevel.high
                          ? Icons.warning
                          : claim.fraudAnalysis!.riskLevel == FraudRiskLevel.medium
                              ? Icons.info
                              : Icons.check_circle)
                      : Icons.pending,
                  color: claim.fraudAnalysis?.riskLevel.color ?? AppDesignSystem.neutral600,
                ),
              ),
              title: Text(
                claim.projectName,
                style: AppDesignSystem.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${claim.companyName} • ${claim.milestoneNumber}',
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 14,
                        color: AppDesignSystem.neutral600,
                      ),
                      Text(
                        '${(claim.claimedAmount / 100000).toStringAsFixed(2)}L',
                        style: AppDesignSystem.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (claim.fraudAnalysis != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: claim.fraudAnalysis!.riskLevel.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            claim.fraudAnalysis!.riskLevel.label,
                            style: TextStyle(
                              color: claim.fraudAnalysis!.riskLevel.color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM').format(claim.submittedAt),
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: AppDesignSystem.neutral600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppDesignSystem.neutral400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClaimDetails(MilestoneClaim claim) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClaimHeader(claim),
          const SizedBox(height: 24),
          if (claim.fraudAnalysis != null) ...[
            _buildFraudAnalysis(claim.fraudAnalysis!),
            const SizedBox(height: 24),
          ],
          _buildDocumentsList(claim.documents),
          const SizedBox(height: 24),
          _buildMilestoneDetails(claim.milestoneDetails),
          const SizedBox(height: 24),
          if (claim.status != ClaimStatus.approved &&
              claim.status != ClaimStatus.rejected)
            _buildApprovalActions(claim),
        ],
      ),
    );
  }

  Widget _buildClaimHeader(MilestoneClaim claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                claim.projectName,
                style: AppDesignSystem.headlineSmall,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: claim.status.color.withOpacity(0.2),
                borderRadius: AppDesignSystem.radiusSmall,
              ),
              child: Text(
                claim.status.label,
                style: TextStyle(
                  color: claim.status.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Company', claim.companyName, Icons.business),
        const SizedBox(height: 8),
        _buildInfoRow('Milestone', '${claim.milestoneNumber}: ${claim.milestoneDescription}', Icons.flag),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Claimed Amount',
          '₹${(claim.claimedAmount / 100000).toStringAsFixed(2)} Lakhs',
          Icons.currency_rupee,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Submitted By',
          claim.submittedBy,
          Icons.person,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Submission Date',
          DateFormat('dd MMM yyyy, hh:mm a').format(claim.submittedAt),
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppDesignSystem.neutral600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppDesignSystem.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFraudAnalysis(FraudDetectionResult analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: analysis.riskLevel.color.withOpacity(0.05),
        borderRadius: AppDesignSystem.radiusMedium,
        border: Border.all(
          color: analysis.riskLevel.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: analysis.riskLevel.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  color: analysis.riskLevel.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Fraud Detection Analysis',
                      style: AppDesignSystem.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: ${analysis.aiConfidence}',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: analysis.riskLevel.color,
                  borderRadius: AppDesignSystem.radiusSmall,
                ),
                child: Text(
                  analysis.riskLevel.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFraudScoreBar(analysis.fraudScore),
          const SizedBox(height: 20),
          _buildAnalysisScores(analysis.analysisScores),
          if (analysis.suspiciousIndicators.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildIndicatorsList(
              'Suspicious Indicators',
              analysis.suspiciousIndicators,
              Colors.red,
              Icons.warning,
            ),
          ],
          if (analysis.verifiedFactors.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildIndicatorsList(
              'Verified Factors',
              analysis.verifiedFactors,
              Colors.green,
              Icons.verified,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFraudScoreBar(double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fraud Risk Score',
              style: AppDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(score * 100).toStringAsFixed(1)}%',
              style: AppDesignSystem.titleMedium.copyWith(
                color: FraudRiskLevel.fromScore(score).color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 12,
            backgroundColor: AppDesignSystem.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(
              FraudRiskLevel.fromScore(score).color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisScores(Map<String, double> scores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analysis',
          style: AppDesignSystem.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...scores.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppDesignSystem.bodySmall,
                    ),
                    Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: AppDesignSystem.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: entry.value,
                    minHeight: 6,
                    backgroundColor: AppDesignSystem.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      entry.value >= 0.7
                          ? Colors.green
                          : entry.value >= 0.5
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIndicatorsList(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppDesignSystem.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: AppDesignSystem.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDocumentsList(List<ClaimDocument> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submitted Documents (${documents.length})',
          style: AppDesignSystem.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...documents.map((doc) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: doc.isVerified
                  ? Colors.green.withOpacity(0.05)
                  : AppDesignSystem.neutral100,
              borderRadius: AppDesignSystem.radiusSmall,
              border: Border.all(
                color: doc.isVerified
                    ? Colors.green.withOpacity(0.3)
                    : AppDesignSystem.neutral300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getDocumentIcon(doc.type),
                  color: doc.isVerified ? Colors.green : AppDesignSystem.neutral600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.type.label,
                        style: AppDesignSystem.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        doc.fileName,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (doc.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.download, size: 20),
                  onPressed: () {
                    // Download document
                  },
                  tooltip: 'Download',
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.workOrder:
        return Icons.description;
      case DocumentType.invoice:
        return Icons.receipt;
      case DocumentType.photograph:
        return Icons.photo_library;
      case DocumentType.gpsCoordinates:
        return Icons.location_on;
      case DocumentType.qualityReport:
        return Icons.assessment;
      case DocumentType.materialBill:
        return Icons.shopping_cart;
      case DocumentType.labourReport:
        return Icons.people;
      case DocumentType.measurementSheet:
        return Icons.straighten;
    }
  }

  Widget _buildMilestoneDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestone Details',
          style: AppDesignSystem.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppDesignSystem.neutral100,
            borderRadius: AppDesignSystem.radiusMedium,
          ),
          child: Column(
            children: details.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: AppDesignSystem.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalActions(MilestoneClaim claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviewer Notes',
          style: AppDesignSystem.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter your review notes here...',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: AppDesignSystem.neutral100,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _handleClaimAction(claim, ClaimStatus.approved);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _handleClaimAction(claim, ClaimStatus.onHold);
                },
                icon: const Icon(Icons.pause_circle),
                label: const Text('On Hold'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _handleClaimAction(claim, ClaimStatus.rejected);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleClaimAction(MilestoneClaim claim, ClaimStatus newStatus) {
    if (widget.onClaimAction != null) {
      widget.onClaimAction!(
        claim,
        newStatus,
        _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      setState(() {
        _notesController.clear();
      });
    }
  }
}