import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/communication_model.dart';
import '../../../core/theme/app_theme.dart';

class CommunicationHubWidget extends ConsumerStatefulWidget {
  final String userId;
  final String userRole;

  const CommunicationHubWidget({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  ConsumerState<CommunicationHubWidget> createState() => _CommunicationHubWidgetState();
}

class _CommunicationHubWidgetState extends ConsumerState<CommunicationHubWidget> {
  ConversationChannel? _selectedChannel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  
  // Mock data - will be replaced with Supabase real-time data
  final List<ConversationChannel> _channels = [];
  final List<Message> _messages = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _channels.addAll([
      ConversationChannel(
        id: '1',
        title: 'Project Alpha Discussion',
        type: ConversationType.stateToAgency,
        projectId: 'project-1',
        participants: [widget.userId, 'user-2', 'user-3'],
        createdBy: widget.userId,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 3,
      ),
      ConversationChannel(
        id: '2',
        title: 'Fund Release Updates',
        type: ConversationType.centreToState,
        participants: [widget.userId, 'user-4'],
        createdBy: 'user-4',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 0,
      ),
    ]);

    _messages.addAll([
      Message(
        id: 'msg-1',
        channelId: '1',
        senderId: 'user-2',
        content: 'Can you provide an update on the land acquisition status?',
        priority: MessagePriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        readBy: [widget.userId],
      ),
      Message(
        id: 'msg-2',
        channelId: '1',
        senderId: widget.userId,
        content: 'The land acquisition is 75% complete. We expect to finish by next week.',
        parentMessageId: 'msg-1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        readBy: ['user-2', widget.userId],
      ),
    ]);
  }

  List<ConversationChannel> _getFilteredChannels() {
    if (_searchQuery.isEmpty) return _channels;
    return _channels.where((channel) {
      return channel.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Message> _getChannelMessages() {
    if (_selectedChannel == null) return [];
    return _messages.where((msg) => msg.channelId == _selectedChannel!.id).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Widget _buildChannelsList() {
    final filteredChannels = _getFilteredChannels();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search channels...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredChannels.length,
            itemBuilder: (context, index) {
              final channel = filteredChannels[index];
              final isSelected = _selectedChannel?.id == channel.id;
              
              return ListTile(
                selected: isSelected,
                leading: CircleAvatar(
                  backgroundColor: _getChannelTypeColor(channel.type),
                  child: Icon(
                    _getChannelTypeIcon(channel.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  channel.title,
                  style: TextStyle(
                    fontWeight: channel.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  channel.lastMessageAt != null
                      ? _formatDateTime(channel.lastMessageAt!)
                      : 'No messages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: channel.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${channel.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () => setState(() => _selectedChannel = channel),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesView() {
    if (_selectedChannel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a channel to start messaging',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    final messages = _getChannelMessages();

    return Column(
      children: [
        _buildChannelHeader(),
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('No messages yet'))
              : ListView.builder(
                  controller: _messagesScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
                ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChannelHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getChannelTypeColor(_selectedChannel!.type),
            child: Icon(
              _getChannelTypeIcon(_selectedChannel!.type),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedChannel!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${_selectedChannel!.participants.length} participants',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show channel options menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isOwnMessage = message.senderId == widget.userId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryIndigo,
              child: Text(
                message.senderId[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOwnMessage ? AppTheme.primaryIndigo : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isOwnMessage ? 12 : 0),
                      bottomRight: Radius.circular(isOwnMessage ? 0 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.priority != MessagePriority.medium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(message.priority),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            message.priority.value.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isOwnMessage ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (message.attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: message.attachments.map((attachment) {
                            return Chip(
                              avatar: const Icon(Icons.attach_file, size: 16),
                              label: Text(attachment.fileName),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateTime(message.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (message.isEdited) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(edited)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryIndigo,
              child: Text(
                widget.userId[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // Handle file attachment
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppTheme.primaryIndigo,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedChannel == null) return;

    // TODO: Send message via Supabase
    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      channelId: _selectedChannel!.id,
      senderId: widget.userId,
      content: _messageController.text.trim(),
      createdAt: DateTime.now(),
      readBy: [widget.userId],
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _messagesScrollController.animateTo(
        _messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Color _getChannelTypeColor(ConversationType type) {
    switch (type) {
      case ConversationType.centreToState:
        return AppTheme.primaryIndigo;
      case ConversationType.stateToAgency:
        return AppTheme.secondaryBlue;
      case ConversationType.centreToAgency:
        return AppTheme.accentTeal;
      case ConversationType.broadcast:
        return AppTheme.warningOrange;
    }
  }

  IconData _getChannelTypeIcon(ConversationType type) {
    switch (type) {
      case ConversationType.centreToState:
        return Icons.account_balance;
      case ConversationType.stateToAgency:
        return Icons.business;
      case ConversationType.centreToAgency:
        return Icons.hub;
      case ConversationType.broadcast:
        return Icons.campaign;
    }
  }

  Color _getPriorityColor(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.low:
        return Colors.green;
      case MessagePriority.medium:
        return Colors.blue;
      case MessagePriority.high:
        return AppTheme.warningOrange;
      case MessagePriority.critical:
        return AppTheme.errorRed;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: _buildChannelsList(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildMessagesView(),
        ),
      ],
    );
  }
}