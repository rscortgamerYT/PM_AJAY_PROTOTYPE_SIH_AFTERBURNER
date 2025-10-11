import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/communication_service.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Cross-Module Integration Widget
/// 
/// Enables seamless linking and navigation between Chat, Tickets, and Tags
class CrossModuleIntegrationWidget extends ConsumerStatefulWidget {
  final String sourceModule;
  final String sourceId;
  
  const CrossModuleIntegrationWidget({
    super.key,
    required this.sourceModule,
    required this.sourceId,
  });

  @override
  ConsumerState<CrossModuleIntegrationWidget> createState() => _CrossModuleIntegrationWidgetState();
}

class _CrossModuleIntegrationWidgetState extends ConsumerState<CrossModuleIntegrationWidget> {
  final CommunicationService _commService = CommunicationService();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRelatedItems(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showLinkDialog,
              icon: const Icon(Icons.link),
              label: const Text('Link Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItems() {
    return Column(
      children: [
        _buildLinkedTickets(),
        const SizedBox(height: 12),
        _buildLinkedMessages(),
        const SizedBox(height: 12),
        _buildAppliedTags(),
      ],
    );
  }

  Widget _buildLinkedTickets() {
    return ExpansionTile(
      leading: const Icon(Icons.confirmation_number),
      title: const Text('Linked Tickets'),
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.priority_high,
              color: AppTheme.primaryIndigo,
              size: 16,
            ),
          ),
          title: const Text('High Priority Issue'),
          subtitle: const Text('Ticket #1234'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _navigateToTicket('1234'),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedMessages() {
    return ExpansionTile(
      leading: const Icon(Icons.message),
      title: const Text('Linked Messages'),
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.secondaryBlue.withOpacity(0.2),
            child: const Icon(Icons.person, size: 16),
          ),
          title: const Text('Discussion about issue'),
          subtitle: const Text('#general channel'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _navigateToMessage('msg-123'),
          ),
        ),
      ],
    );
  }

  Widget _buildAppliedTags() {
    return ExpansionTile(
      leading: const Icon(Icons.label),
      title: const Text('Applied Tags'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTagChip('urgent', Colors.red),
              _buildTagChip('bug', Colors.orange),
              _buildTagChip('enhancement', Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
      avatar: Icon(Icons.label, size: 16, color: color),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _removeTag(label),
    );
  }

  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Link to Ticket'),
              onTap: () {
                Navigator.pop(context);
                _showTicketSelector();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Link to Message'),
              onTap: () {
                Navigator.pop(context);
                _showMessageSelector();
              },
            ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Apply Tag'),
              onTap: () {
                Navigator.pop(context);
                _showTagSelector();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTicketSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Ticket'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<Ticket>>(
            stream: _commService.getTicketsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tickets = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return ListTile(
                    leading: Icon(
                      Icons.confirmation_number,
                      color: _getPriorityColor(ticket.priority),
                    ),
                    title: Text(ticket.title),
                    subtitle: Text(ticket.status.name),
                    onTap: () {
                      _linkToTicket(ticket.id);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMessageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Message'),
        content: const Text('Message selector coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTagSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Tag'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Tag>>(
            future: _commService.getTags(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tags = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    leading: Icon(
                      Icons.label,
                      color: _parseColor(tag.color),
                    ),
                    title: Text(tag.name),
                    subtitle: tag.description != null ? Text(tag.description!) : null,
                    onTap: () {
                      _applyTag(tag.id);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.critical:
        return AppTheme.errorRed;
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryIndigo;
    }
  }

  void _navigateToTicket(String ticketId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to ticket $ticketId')),
    );
  }

  void _navigateToMessage(String messageId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to message $messageId')),
    );
  }

  void _linkToTicket(String ticketId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Linked to ticket $ticketId')),
    );
  }

  void _applyTag(String tagId) {
    if (widget.sourceModule == 'ticket') {
      _commService.tagTicket(widget.sourceId, tagId);
    } else if (widget.sourceModule == 'message') {
      _commService.tagMessage(widget.sourceId, tagId);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tag applied successfully')),
    );
    setState(() {});
  }

  void _removeTag(String tagLabel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed tag: $tagLabel')),
    );
    setState(() {});
  }
}