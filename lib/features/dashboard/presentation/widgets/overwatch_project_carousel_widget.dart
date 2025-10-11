import 'package:flutter/material.dart';
import '../../models/overwatch_project_model.dart';
import '../../../../core/theme/app_design_system.dart';

class OverwatchProjectCarouselWidget extends StatefulWidget {
  final List<OverwatchProject> projects;
  final Function(OverwatchProject)? onProjectSelect;

  const OverwatchProjectCarouselWidget({
    super.key,
    required this.projects,
    this.onProjectSelect,
  });

  @override
  State<OverwatchProjectCarouselWidget> createState() =>
      _OverwatchProjectCarouselWidgetState();
}

class _OverwatchProjectCarouselWidgetState
    extends State<OverwatchProjectCarouselWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollButtons());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!mounted) return;
    setState(() {
      _canScrollLeft = _scrollController.hasClients && _scrollController.offset > 0;
      _canScrollRight = _scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 320,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 320,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Projects Overview',
                    style: AppDesignSystem.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'View all projects',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.vibrantTeal,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppDesignSystem.vibrantTeal,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (_canScrollLeft)
                    IconButton(
                      onPressed: _scrollLeft,
                      icon: const Icon(Icons.chevron_left),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDesignSystem.radiusSmall,
                          side: BorderSide(
                            color: AppDesignSystem.neutral300,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (_canScrollRight)
                    IconButton(
                      onPressed: _scrollRight,
                      icon: const Icon(Icons.chevron_right),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDesignSystem.radiusSmall,
                          side: BorderSide(
                            color: AppDesignSystem.neutral300,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildProjectCard(widget.projects[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(OverwatchProject project) {
    return GestureDetector(
      onTap: () => widget.onProjectSelect?.call(project),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppDesignSystem.radiusMedium,
          border: Border.all(
            color: AppDesignSystem.neutral300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusIndicator(project.status),
                _buildRiskIndicator(project.riskLevel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: AppDesignSystem.neutral600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppDesignSystem.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.location ?? project.state,
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppDesignSystem.neutral600,
                ),
                const SizedBox(width: 6),
                Text(
                  project.timeline ?? 'N/A',
                  style: AppDesignSystem.labelSmall.copyWith(
                    color: AppDesignSystem.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: AppDesignSystem.neutral600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    project.responsiblePerson?.name ?? 'N/A',
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: AppDesignSystem.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                    Text(
                      '${project.progress.toStringAsFixed(0)}%',
                      style: AppDesignSystem.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.progress / 100,
                    minHeight: 8,
                    backgroundColor: AppDesignSystem.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      project.progress > 75
                          ? AppDesignSystem.success
                          : project.progress > 50
                              ? AppDesignSystem.info
                              : project.progress > 25
                                  ? AppDesignSystem.warning
                                  : AppDesignSystem.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allocated',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                    Text(
                      '₹${(project.allocatedFunds / 100000).toStringAsFixed(1)}L',
                      style: AppDesignSystem.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Utilized',
                      style: AppDesignSystem.labelSmall.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                    Text(
                      '₹${(project.utilizedFunds / 100000).toStringAsFixed(1)}L',
                      style: AppDesignSystem.labelMedium.copyWith(
                        color: AppDesignSystem.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (project.lastUpdate != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last updated: ${_formatTimeAgo(project.lastUpdate!)}',
                style: AppDesignSystem.labelSmall.copyWith(
                  color: AppDesignSystem.neutral500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(OverwatchProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppDesignSystem.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(RiskLevel riskLevel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 4,
          height: index == 0 ? 8 : index == 1 ? 12 : 16,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < riskLevel.barCount
                ? riskLevel.color
                : AppDesignSystem.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}