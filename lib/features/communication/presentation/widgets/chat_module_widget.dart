import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/communication_service_demo.dart';
import '../../../../core/models/communication_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Chat Module Widget
/// 
/// Real-time messaging with channels, threads, and file sharing
class ChatModuleWidget extends ConsumerStatefulWidget {
  const ChatModuleWidget({super.key});

  @override
  ConsumerState<ChatModuleWidget> createState() => _ChatModuleWidgetState();
}

class _ChatModuleWidgetState extends ConsumerState<ChatModuleWidget> {
  final CommunicationServiceDemo _commService = CommunicationServiceDemo();
  final TextEditingController _messageController = TextEditingController();
  
  String? _selectedChannelId;
  Message? _replyToMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = 'current-user-id'; // TODO: Get from auth

    return Row(
      children: [
        // Channel List
        SizedBox(
          width: 280,
          child: _buildChannelList(userId),
        ),
        
        const VerticalDivider(width: 1),
        
        // Message Thread
        Expanded(
          child: _selectedChannelId != null
              ? _buildMessageThread(_selectedChannelId!)
              : _buildEmptyState(),
        ),
        
        // Context Panel (optional)
        if (_selectedChannelId != null)
          SizedBox(
            width: 300,
            child: _buildContextPanel(),
          ),
      ],
    );
  }

  Widget _buildChannelList(String userId) {
    return StreamBuilder<List<Channel>>(
      stream: _commService.getChannelsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final channels = snapshot.data ?? [];

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Channels',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showCreateChannelDialog,
                    tooltip: 'New Channel',
                  ),
                ],
              ),
            ),
            
            // Channel Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: true,
                      onSelected: (selected) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Direct'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Groups'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
              ),
            ),
            
            const Divider(),
            
            // Channel List
            Expanded(
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  return _buildChannelTile(channel);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelTile(Channel channel) {
    final isSelected = _selectedChannelId == channel.id;
    
    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(
        backgroundColor: isSelected 
            ? AppTheme.primaryIndigo 
            : AppTheme.neutralGray.withOpacity(0.3),
        child: Icon(
          _getChannelIcon(channel.type),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontWeight: channel.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: channel.lastMessage != null
          ? Text(
              channel.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: channel.unreadCount > 0 
                    ? AppTheme.onSurfaceLight 
                    : AppTheme.neutralGray,
              ),
            )
          : null,
      trailing: channel.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
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
      onTap: () {
        setState(() => _selectedChannelId = channel.id);
        _commService.markMessagesAsRead(channel.id, 'current-user-id');
      },
    );
  }

  IconData _getChannelIcon(ChannelType type) {
    switch (type) {
      case ChannelType.direct:
        return Icons.person;
      case ChannelType.group:
        return Icons.group;
      case ChannelType.broadcast:
        return Icons.campaign;
    }
  }

  Widget _buildMessageThread(String channelId) {
    return StreamBuilder<List<Message>>(
      stream: _commService.getMessagesStream(channelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];

        return Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            
            // Reply To Bar
            if (_replyToMessage != null)
              _buildReplyToBar(),
            
            const Divider(height: 1),
            
            // Message Input
            _buildMessageInput(),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = message.senderId == 'current-user-id'; // TODO: Get from auth
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              child: Text(message.senderName[0]),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? AppTheme.primaryIndigo 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.neutralGray,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser 
                          ? Colors.white70 
                          : AppTheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyToBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to ${_replyToMessage!.senderName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _replyToMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _handleAttachment,
            tooltip: 'Attach File',
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {},
            tooltip: 'Emojis',
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Channel Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildContextSection('Members', Icons.people, '5 members'),
                const SizedBox(height: 16),
                _buildContextSection('Files', Icons.folder, '12 files'),
                const SizedBox(height: 16),
                _buildContextSection('Links', Icons.link, '8 links'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextSection(String title, IconData icon, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryIndigo),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a channel to start messaging',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedChannelId == null) {
      return;
    }

    _commService.sendMessage(
      channelId: _selectedChannelId!,
      senderId: 'current-user-id', // TODO: Get from auth
      senderName: 'Current User', // TODO: Get from auth
      content: _messageController.text.trim(),
      parentMessageId: _replyToMessage?.id,
    );

    _messageController.clear();
    setState(() => _replyToMessage = null);
  }

  void _handleAttachment() {
    // Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attachment coming soon')),
    );
  }

  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Enter channel name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChannelType>(
              decoration: const InputDecoration(
                labelText: 'Channel Type',
              ),
              items: ChannelType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
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
              // Implement channel creation
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}