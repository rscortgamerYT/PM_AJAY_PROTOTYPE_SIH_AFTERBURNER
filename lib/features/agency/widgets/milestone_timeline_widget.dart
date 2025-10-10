import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../core/models/milestone_model.dart';

class MilestoneTimelineWidget extends StatefulWidget {
  final String projectId;
  final List<ProjectMilestone> milestones;
  final Function(ProjectMilestone)? onMilestoneSubmit;
  final Function(ProjectMilestone)? onMilestoneUpdate;

  const MilestoneTimelineWidget({
    Key? key,
    required this.projectId,
    required this.milestones,
    this.onMilestoneSubmit,
    this.onMilestoneUpdate,
  }) : super(key: key);

  @override
  State<MilestoneTimelineWidget> createState() => _MilestoneTimelineWidgetState();
}

class _MilestoneTimelineWidgetState extends State<MilestoneTimelineWidget> {
  DateTime? _viewStartDate;
  DateTime? _viewEndDate;
  double _zoom = 1.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _calculateViewDates();
  }

  void _calculateViewDates() {
    if (widget.milestones.isEmpty) {
      _viewStartDate = DateTime.now();
      _viewEndDate = DateTime.now().add(const Duration(days: 365));
      return;
    }

    final dates = widget.milestones.expand((m) => [
      m.plannedStartDate,
      m.plannedEndDate,
    ]).toList()..sort();

    _viewStartDate = dates.first.subtract(const Duration(days: 30));
    _viewEndDate = dates.last.add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildZoomControls(),
          const Divider(height: 1),
          Expanded(child: _buildGanttChart()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Project Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildStatusSummary(),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    final notStarted = widget.milestones.where((m) => m.status == MilestoneStatus.notStarted).length;
    final inProgress = widget.milestones.where((m) => m.status == MilestoneStatus.inProgress).length;
    final approved = widget.milestones.where((m) => m.status == MilestoneStatus.approved).length;
    final delayed = widget.milestones.where((m) => m.isDelayed).length;

    return Row(
      children: [
        _buildStatusChip('Not Started', notStarted, Colors.grey),
        const SizedBox(width: 8),
        _buildStatusChip('In Progress', inProgress, Colors.blue),
        const SizedBox(width: 8),
        _buildStatusChip('Approved', approved, Colors.green),
        const SizedBox(width: 8),
        if (delayed > 0)
          _buildStatusChip('Delayed', delayed, Colors.red),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildZoomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => setState(() => _zoom = (_zoom / 1.2).clamp(0.5, 3.0)),
            tooltip: 'Zoom Out',
          ),
          Text('${(_zoom * 100).toInt()}%'),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => setState(() => _zoom = (_zoom * 1.2).clamp(0.5, 3.0)),
            tooltip: 'Zoom In',
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            icon: const Icon(Icons.today),
            label: const Text('Today'),
            onPressed: () {
              final today = DateTime.now();
              if (_viewStartDate != null && _viewEndDate != null) {
                final totalDays = _viewEndDate!.difference(_viewStartDate!).inDays;
                final todayPosition = today.difference(_viewStartDate!).inDays;
                final scrollPosition = (todayPosition / totalDays) * _scrollController.position.maxScrollExtent;
                _scrollController.animateTo(
                  scrollPosition,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Milestone'),
            onPressed: _showAddMilestoneDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildGanttChart() {
    if (widget.milestones.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No milestones yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        _buildMilestoneList(),
        const VerticalDivider(width: 1),
        Expanded(child: _buildTimeline()),
      ],
    );
  }

  Widget _buildMilestoneList() {
    return SizedBox(
      width: 250,
      child: ListView.builder(
        itemCount: widget.milestones.length,
        itemBuilder: (context, index) {
          final milestone = widget.milestones[index];
          return _buildMilestoneListItem(milestone);
        },
      ),
    );
  }

  Widget _buildMilestoneListItem(ProjectMilestone milestone) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildStatusIndicator(milestone),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  milestone.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  milestone.type.displayName,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (milestone.isSlaBreach)
            const Icon(Icons.warning, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ProjectMilestone milestone) {
    Color color;
    IconData icon;
    switch (milestone.status) {
      case MilestoneStatus.notStarted:
        color = Colors.grey;
        icon = Icons.radio_button_unchecked;
        break;
      case MilestoneStatus.inProgress:
        color = Colors.blue;
        icon = Icons.play_circle_outline;
        break;
      case MilestoneStatus.submitted:
        color = Colors.orange;
        icon = Icons.upload;
        break;
      case MilestoneStatus.underReview:
        color = Colors.purple;
        icon = Icons.rate_review;
        break;
      case MilestoneStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case MilestoneStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case MilestoneStatus.delayed:
        color = Colors.red;
        icon = Icons.warning;
        break;
    }
    return Icon(icon, color: color, size: 24);
  }

  Widget _buildTimeline() {
    if (_viewStartDate == null || _viewEndDate == null) return const SizedBox();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _calculateTimelineWidth(),
        child: Column(
          children: [
            _buildTimelineHeader(),
            const Divider(height: 1),
            Expanded(child: _buildTimelineBars()),
          ],
        ),
      ),
    );
  }

  double _calculateTimelineWidth() {
    final days = _viewEndDate!.difference(_viewStartDate!).inDays;
    return days * 30.0 * _zoom;
  }

  Widget _buildTimelineHeader() {
    final totalDays = _viewEndDate!.difference(_viewStartDate!).inDays;
    final months = <DateTime>[];
    
    var currentDate = DateTime(_viewStartDate!.year, _viewStartDate!.month, 1);
    while (currentDate.isBefore(_viewEndDate!)) {
      months.add(currentDate);
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: months.map((month) {
          final monthEnd = DateTime(month.year, month.month + 1, 0);
          final monthDays = monthEnd.day;
          final width = monthDays * 30.0 * _zoom;
          
          return Container(
            width: width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              DateFormat('MMM yyyy').format(month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineBars() {
    return Stack(
      children: [
        _buildTodayMarker(),
        ListView.builder(
          itemCount: widget.milestones.length,
          itemBuilder: (context, index) {
            final milestone = widget.milestones[index];
            return _buildMilestoneBar(milestone);
          },
        ),
      ],
    );
  }

  Widget _buildTodayMarker() {
    final today = DateTime.now();
    if (today.isBefore(_viewStartDate!) || today.isAfter(_viewEndDate!)) {
      return const SizedBox();
    }

    final daysFromStart = today.difference(_viewStartDate!).inDays;
    final left = daysFromStart * 30.0 * _zoom;

    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
      ),
    );
  }

  Widget _buildMilestoneBar(ProjectMilestone milestone) {
    final startDays = milestone.plannedStartDate.difference(_viewStartDate!).inDays;
    final duration = milestone.plannedEndDate.difference(milestone.plannedStartDate).inDays;
    
    final left = startDays * 30.0 * _zoom;
    final width = duration * 30.0 * _zoom;

    Color barColor;
    switch (milestone.status) {
      case MilestoneStatus.approved:
        barColor = Colors.green;
        break;
      case MilestoneStatus.rejected:
        barColor = Colors.red;
        break;
      case MilestoneStatus.underReview:
        barColor = Colors.purple;
        break;
      case MilestoneStatus.submitted:
        barColor = Colors.orange;
        break;
      case MilestoneStatus.inProgress:
        barColor = Colors.blue;
        break;
      case MilestoneStatus.delayed:
        barColor = Colors.red;
        break;
      default:
        barColor = Colors.grey;
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: left,
            child: GestureDetector(
              onTap: () => _showMilestoneDetails(milestone),
              child: Container(
                width: width,
                height: 30,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.2),
                  border: Border.all(color: barColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: (milestone.completionPercentage * 100).toInt(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.6),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 100 - (milestone.completionPercentage * 100).toInt(),
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (milestone.dependencies.isNotEmpty)
            ...milestone.dependencies.map((depId) {
              final dependency = widget.milestones.firstWhere(
                (m) => m.id == depId,
                orElse: () => milestone,
              );
              if (dependency == milestone) return const SizedBox();
              return _buildDependencyArrow(milestone, dependency);
            }),
        ],
      ),
    );
  }

  Widget _buildDependencyArrow(ProjectMilestone from, ProjectMilestone to) {
    final fromDays = from.plannedStartDate.difference(_viewStartDate!).inDays;
    final toDays = to.plannedEndDate.difference(_viewStartDate!).inDays;
    
    final fromLeft = fromDays * 30.0 * _zoom;
    final toLeft = toDays * 30.0 * _zoom;

    return CustomPaint(
      painter: _ArrowPainter(
        start: Offset(toLeft, 15),
        end: Offset(fromLeft, 15),
        color: Colors.grey,
      ),
    );
  }

  void _showMilestoneDetails(ProjectMilestone milestone) {
    showDialog(
      context: context,
      builder: (context) => _MilestoneDetailsDialog(
        milestone: milestone,
        onSubmit: () {
          Navigator.pop(context);
          _showSubmitMilestoneDialog(milestone);
        },
        onUpdate: () {
          Navigator.pop(context);
          widget.onMilestoneUpdate?.call(milestone);
        },
      ),
    );
  }

  void _showAddMilestoneDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMilestoneDialog(
        projectId: widget.projectId,
        onMilestoneCreated: (milestone) {
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  void _showSubmitMilestoneDialog(ProjectMilestone milestone) {
    showDialog(
      context: context,
      builder: (context) => _SubmitMilestoneDialog(
        milestone: milestone,
        onSubmit: (updatedMilestone) {
          Navigator.pop(context);
          widget.onMilestoneSubmit?.call(updatedMilestone);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _ArrowPainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    final arrowSize = 8.0;
    final angle = (end - start).direction;
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * (math.cos(angle) + 0.5 * math.sin(angle)),
        end.dy - arrowSize * (math.sin(angle) - 0.5 * math.cos(angle)),
      )
      ..lineTo(
        end.dx - arrowSize * (math.cos(angle) - 0.5 * math.sin(angle)),
        end.dy - arrowSize * (math.sin(angle) + 0.5 * math.cos(angle)),
      )
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MilestoneDetailsDialog extends StatelessWidget {
  final ProjectMilestone milestone;
  final VoidCallback onSubmit;
  final VoidCallback onUpdate;

  const _MilestoneDetailsDialog({
    required this.milestone,
    required this.onSubmit,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(milestone.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Type', milestone.type.displayName),
            _buildInfoRow('Status', milestone.status.value.toUpperCase()),
            _buildInfoRow(
              'Planned',
              '${DateFormat('MMM dd, yyyy').format(milestone.plannedStartDate)} - ${DateFormat('MMM dd, yyyy').format(milestone.plannedEndDate)}',
            ),
            _buildInfoRow('Completion', '${(milestone.completionPercentage * 100).toInt()}%'),
            if (milestone.isDelayed)
              _buildInfoRow('Delay', 'DELAYED', color: Colors.red),
            if (milestone.isSlaBreach)
              _buildInfoRow('SLA Status', 'BREACH', color: Colors.red),
            const Divider(),
            Text(milestone.description),
            if (milestone.evidence.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...milestone.evidence.map((e) => ListTile(
                leading: Icon(_getEvidenceIcon(e.type)),
                title: Text(e.url.split('/').last),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(e.capturedAt)),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (milestone.status == MilestoneStatus.inProgress)
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Submit'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEvidenceIcon(String type) {
    switch (type) {
      case 'photo':
        return Icons.photo;
      case 'document':
        return Icons.description;
      case 'report':
        return Icons.assessment;
      default:
        return Icons.attachment;
    }
  }
}

class _AddMilestoneDialog extends StatefulWidget {
  final String projectId;
  final Function(ProjectMilestone) onMilestoneCreated;

  const _AddMilestoneDialog({
    required this.projectId,
    required this.onMilestoneCreated,
  });

  @override
  State<_AddMilestoneDialog> createState() => _AddMilestoneDialogState();
}

class _AddMilestoneDialogState extends State<_AddMilestoneDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  MilestoneType _type = MilestoneType.construction;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Milestone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MilestoneType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: MilestoneType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
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
          onPressed: _createMilestone,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createMilestone() {
    final milestone = ProjectMilestone(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId,
      agencyId: 'current_agency_id', // TODO: Get from auth
      name: _nameController.text,
      description: _descriptionController.text,
      type: _type,
      status: MilestoneStatus.notStarted,
      plannedStartDate: _startDate,
      plannedEndDate: _endDate,
    );

    widget.onMilestoneCreated(milestone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _SubmitMilestoneDialog extends StatefulWidget {
  final ProjectMilestone milestone;
  final Function(ProjectMilestone) onSubmit;

  const _SubmitMilestoneDialog({
    required this.milestone,
    required this.onSubmit,
  });

  @override
  State<_SubmitMilestoneDialog> createState() => _SubmitMilestoneDialogState();
}

class _SubmitMilestoneDialogState extends State<_SubmitMilestoneDialog> {
  final List<MilestoneEvidence> _evidence = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Milestone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload evidence to submit this milestone:'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            onPressed: _capturePhoto,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
            onPressed: _uploadDocument,
          ),
          if (_evidence.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._evidence.map((e) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(e.url.split('/').last),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _evidence.isNotEmpty ? _submitMilestone : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _capturePhoto() {
    // TODO: Implement camera capture with geo-validation
  }

  void _uploadDocument() {
    // TODO: Implement document upload
  }

  void _submitMilestone() {
    final updatedMilestone = widget.milestone.copyWith(
      status: MilestoneStatus.submitted,
      submittedBy: 'current_user_id', // TODO: Get from auth
      submittedAt: DateTime.now(),
      evidence: _evidence,
    );

    widget.onSubmit(updatedMilestone);
  }
}