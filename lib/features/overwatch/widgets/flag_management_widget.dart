import 'package:flutter/material.dart';
import '../../../core/models/flag_model.dart';
import '../../../core/models/project_model.dart';

class FlagManagementWidget extends StatefulWidget {
  final Function(ProjectFlag)? onFlagCreated;
  final Function(ProjectFlag)? onFlagUpdated;

  const FlagManagementWidget({
    Key? key,
    this.onFlagCreated,
    this.onFlagUpdated,
  }) : super(key: key);

  @override
  State<FlagManagementWidget> createState() => _FlagManagementWidgetState();
}

class _FlagManagementWidgetState extends State<FlagManagementWidget> {
  List<ProjectFlag> _flags = [];
  FlagStatus? _filterStatus;
  FlagSeverity? _filterSeverity;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    // TODO: Load flags from Supabase
    setState(() {});
  }

  List<ProjectFlag> get _filteredFlags {
    return _flags.where((flag) {
      final matchesStatus = _filterStatus == null || flag.status == _filterStatus;
      final matchesSeverity = _filterSeverity == null || flag.severity == _filterSeverity;
      final matchesSearch = _searchQuery.isEmpty ||
          flag.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSeverity && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildFilters(),
          const Divider(height: 1),
          Expanded(child: _buildFlagList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.red),
          const SizedBox(width: 8),
          const Text(
            'Flagged Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildStatusChips(),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Row(
      children: [
        _buildCountChip(
          'Open',
          _flags.where((f) => f.status == FlagStatus.open).length,
          Colors.red,
        ),
        const SizedBox(width: 8),
        _buildCountChip(
          'In Progress',
          _flags.where((f) => f.status == FlagStatus.inProgress).length,
          Colors.orange,
        ),
        const SizedBox(width: 8),
        _buildCountChip(
          'Resolved',
          _flags.where((f) => f.status == FlagStatus.resolved).length,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search flags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<FlagStatus?>(
            value: _filterStatus,
            hint: const Text('Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...FlagStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.value.toUpperCase()),
                  )),
            ],
            onChanged: (value) => setState(() => _filterStatus = value),
          ),
          const SizedBox(width: 16),
          DropdownButton<FlagSeverity?>(
            value: _filterSeverity,
            hint: const Text('Severity'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Severities')),
              ...FlagSeverity.values.map((severity) => DropdownMenuItem(
                    value: severity,
                    child: Text(severity.value.toUpperCase()),
                  )),
            ],
            onChanged: (value) => setState(() => _filterSeverity = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagList() {
    if (_filteredFlags.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No flagged projects',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredFlags.length,
      itemBuilder: (context, index) {
        final flag = _filteredFlags[index];
        return _buildFlagCard(flag);
      },
    );
  }

  Widget _buildFlagCard(ProjectFlag flag) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: _buildSeverityIcon(flag.severity),
        title: Text(
          flag.reason.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project ID: ${flag.projectId}'),
            Text('Flagged: ${_formatDate(flag.flaggedAt)}'),
          ],
        ),
        trailing: _buildStatusBadge(flag.status),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(flag.description),
                if (flag.customReason != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Custom Reason:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(flag.customReason!),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Timeline:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTimeline(flag),
                if (flag.attachmentUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Attachments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildAttachments(flag.attachmentUrls),
                ],
                const SizedBox(height: 16),
                _buildActions(flag),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityIcon(FlagSeverity severity) {
    Color color;
    IconData icon;
    switch (severity) {
      case FlagSeverity.critical:
        color = Colors.red;
        icon = Icons.error;
        break;
      case FlagSeverity.high:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case FlagSeverity.medium:
        color = Colors.amber;
        icon = Icons.info;
        break;
      case FlagSeverity.low:
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
    }
    return Icon(icon, color: color);
  }

  Widget _buildStatusBadge(FlagStatus status) {
    Color color;
    String label;
    switch (status) {
      case FlagStatus.open:
        color = Colors.red;
        label = 'OPEN';
        break;
      case FlagStatus.acknowledged:
        color = Colors.blue;
        label = 'ACKNOWLEDGED';
        break;
      case FlagStatus.inProgress:
        color = Colors.orange;
        label = 'IN PROGRESS';
        break;
      case FlagStatus.resolved:
        color = Colors.green;
        label = 'RESOLVED';
        break;
      case FlagStatus.escalated:
        color = Colors.purple;
        label = 'ESCALATED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimeline(ProjectFlag flag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineItem(
          'Flagged',
          flag.flaggedAt,
          flag.flaggedBy,
          Colors.red,
        ),
        if (flag.acknowledgedAt != null)
          _buildTimelineItem(
            'Acknowledged',
            flag.acknowledgedAt!,
            flag.acknowledgedBy!,
            Colors.blue,
          ),
        if (flag.resolvedAt != null)
          _buildTimelineItem(
            'Resolved',
            flag.resolvedAt!,
            flag.resolvedBy!,
            Colors.green,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    DateTime timestamp,
    String userId,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$label: ${_formatDate(timestamp)} by $userId'),
        ],
      ),
    );
  }

  Widget _buildAttachments(List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) {
        return ActionChip(
          avatar: const Icon(Icons.attachment, size: 16),
          label: Text(url.split('/').last),
          onPressed: () {
            // TODO: Open attachment
          },
        );
      }).toList(),
    );
  }

  Widget _buildActions(ProjectFlag flag) {
    return Wrap(
      spacing: 8,
      children: [
        if (flag.status == FlagStatus.open)
          ElevatedButton.icon(
            onPressed: () => _acknowledgeFlag(flag),
            icon: const Icon(Icons.check),
            label: const Text('Acknowledge'),
          ),
        if (flag.status == FlagStatus.acknowledged ||
            flag.status == FlagStatus.inProgress)
          ElevatedButton.icon(
            onPressed: () => _resolveFlag(flag),
            icon: const Icon(Icons.check_circle),
            label: const Text('Resolve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (flag.status != FlagStatus.escalated)
          ElevatedButton.icon(
            onPressed: () => _escalateFlag(flag),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Escalate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        TextButton.icon(
          onPressed: () => _viewProjectDetails(flag),
          icon: const Icon(Icons.open_in_new),
          label: const Text('View Project'),
        ),
      ],
    );
  }

  Future<void> _acknowledgeFlag(ProjectFlag flag) async {
    final updatedFlag = flag.copyWith(
      status: FlagStatus.acknowledged,
      acknowledgedBy: 'current_user_id', // TODO: Get from auth
      acknowledgedAt: DateTime.now(),
    );
    // TODO: Update in Supabase
    widget.onFlagUpdated?.call(updatedFlag);
    _loadFlags();
  }

  Future<void> _resolveFlag(ProjectFlag flag) async {
    final resolution = await showDialog<String>(
      context: context,
      builder: (context) => _ResolutionDialog(),
    );
    if (resolution == null) return;

    final updatedFlag = flag.copyWith(
      status: FlagStatus.resolved,
      resolvedBy: 'current_user_id', // TODO: Get from auth
      resolvedAt: DateTime.now(),
      resolutionNotes: resolution,
    );
    // TODO: Update in Supabase
    widget.onFlagUpdated?.call(updatedFlag);
    _loadFlags();
  }

  Future<void> _escalateFlag(ProjectFlag flag) async {
    final updatedFlag = flag.copyWith(status: FlagStatus.escalated);
    // TODO: Update in Supabase and notify higher authorities
    widget.onFlagUpdated?.call(updatedFlag);
    _loadFlags();
  }

  void _viewProjectDetails(ProjectFlag flag) {
    // TODO: Navigate to project details
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _ResolutionDialog extends StatefulWidget {
  @override
  State<_ResolutionDialog> createState() => _ResolutionDialogState();
}

class _ResolutionDialogState extends State<_ResolutionDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resolve Flag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Resolution Notes',
          hintText: 'Describe how the issue was resolved...',
          border: OutlineInputBorder(),
        ),
        maxLines: 4,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Resolve'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CreateFlagDialog extends StatefulWidget {
  final String projectId;
  final String agencyId;
  final Function(ProjectFlag) onFlagCreated;

  const CreateFlagDialog({
    Key? key,
    required this.projectId,
    required this.agencyId,
    required this.onFlagCreated,
  }) : super(key: key);

  @override
  State<CreateFlagDialog> createState() => _CreateFlagDialogState();
}

class _CreateFlagDialogState extends State<CreateFlagDialog> {
  FlagReason _reason = FlagReason.delay;
  FlagSeverity _severity = FlagSeverity.medium;
  final _descriptionController = TextEditingController();
  final _customReasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Flag Project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<FlagReason>(
              value: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              items: FlagReason.values.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason.displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _reason = value!),
            ),
            if (_reason == FlagReason.custom) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customReasonController,
                decoration: const InputDecoration(
                  labelText: 'Custom Reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<FlagSeverity>(
              value: _severity,
              decoration: const InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(),
              ),
              items: FlagSeverity.values.map((severity) {
                return DropdownMenuItem(
                  value: severity,
                  child: Text(severity.value.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _severity = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Provide details about the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
          onPressed: _createFlag,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Flag Project'),
        ),
      ],
    );
  }

  void _createFlag() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    final flag = ProjectFlag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId,
      agencyId: widget.agencyId,
      reason: _reason,
      severity: _severity,
      status: FlagStatus.open,
      description: _descriptionController.text,
      customReason: _reason == FlagReason.custom
          ? _customReasonController.text
          : null,
      flaggedBy: 'current_user_id', // TODO: Get from auth
      flaggedAt: DateTime.now(),
    );

    widget.onFlagCreated(flag);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }
}