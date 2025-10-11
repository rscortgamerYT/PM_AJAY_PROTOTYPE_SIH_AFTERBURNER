import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/communication_models.dart';

/// Communication Hub Service
/// 
/// Centralized service for chat, ticketing, and tagging functionality
class CommunicationService {
  final SupabaseClient _client = Supabase.instance.client;

  // ========== CHAT MODULE ==========

  /// Get all channels for the current user
  Stream<List<Channel>> getChannelsStream(String userId) {
    return _client
        .from('channels')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((channel) => 
                (channel['member_ids'] as List).contains(userId))
            .map((json) => Channel.fromJson(json))
            .toList());
  }

  /// Get messages for a specific channel
  Stream<List<Message>> getMessagesStream(String channelId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('channel_id', channelId)
        .order('timestamp', ascending: true)
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }

  /// Send a message to a channel
  Future<Message> sendMessage({
    required String channelId,
    required String senderId,
    required String senderName,
    required String content,
    List<String> mentions = const [],
    List<Attachment> attachments = const [],
    String? parentMessageId,
  }) async {
    final message = Message(
      id: _client.auth.currentUser!.id,
      channelId: channelId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      mentions: mentions,
      attachments: attachments,
      parentMessageId: parentMessageId,
    );

    await _client.from('messages').insert(message.toJson());
    
    // Update channel last message
    await _client
        .from('channels')
        .update({
          'last_message': content,
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .eq('id', channelId);

    // Create notifications for mentions
    if (mentions.isNotEmpty) {
      await _createMentionNotifications(mentions, message);
    }

    return message;
  }

  /// Create a new channel
  Future<Channel> createChannel({
    required String name,
    required ChannelType type,
    required List<String> memberIds,
    Map<String, dynamic> metadata = const {},
  }) async {
    final channel = Channel(
      id: '',
      name: name,
      type: type,
      memberIds: memberIds,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    final response = await _client
        .from('channels')
        .insert(channel.toJson())
        .select()
        .single();

    return Channel.fromJson(response);
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String channelId, String userId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('channel_id', channelId)
        .neq('sender_id', userId);

    await _client
        .from('channels')
        .update({'unread_count': 0})
        .eq('id', channelId);
  }

  /// Search messages
  Future<List<Message>> searchMessages(
    String query,
    String userId, {
    String? channelId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var queryBuilder = _client
        .from('messages')
        .select()
        .textSearch('content', query);

    if (channelId != null) {
      queryBuilder = queryBuilder.eq('channel_id', channelId);
    }

    if (startDate != null) {
      queryBuilder = queryBuilder.gte('timestamp', startDate.toIso8601String());
    }

    if (endDate != null) {
      queryBuilder = queryBuilder.lte('timestamp', endDate.toIso8601String());
    }

    final response = await queryBuilder;
    return (response as List).map((json) => Message.fromJson(json)).toList();
  }

  /// Upload file attachment
  Future<Attachment> uploadAttachment(
    String channelId,
    String fileName,
    List<int> bytes,
    String mimeType,
  ) async {
    final filePath = 'channels/$channelId/$fileName';
    
    await _client.storage
        .from('attachments')
        .uploadBinary(filePath, Uint8List.fromList(bytes));

    final url = _client.storage
        .from('attachments')
        .getPublicUrl(filePath);

    return Attachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fileName,
      url: url,
      mimeType: mimeType,
      size: bytes.length,
      uploadedAt: DateTime.now(),
    );
  }

  // ========== TICKETING MODULE ==========

  /// Get all tickets
  Stream<List<Ticket>> getTicketsStream({
    String? userId,
    TicketStatus? status,
    TicketPriority? priority,
    String? projectId,
  }) {
    return _client
        .from('tickets')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .map((json) => Ticket.fromJson(json))
            .where((ticket) {
              if (userId != null &&
                  ticket.creatorId != userId &&
                  ticket.assigneeId != userId) {
                return false;
              }
              if (status != null && ticket.status != status) return false;
              if (priority != null && ticket.priority != priority) return false;
              if (projectId != null && ticket.projectId != projectId) return false;
              return true;
            })
            .toList());
  }

  /// Create a new ticket
  Future<Ticket> createTicket({
    required String title,
    required String description,
    required TicketType type,
    required TicketPriority priority,
    required String creatorId,
    String? assigneeId,
    String? projectId,
    DateTime? dueDate,
    List<String> tags = const [],
    List<Attachment> attachments = const [],
  }) async {
    final ticket = Ticket(
      id: '',
      title: title,
      description: description,
      type: type,
      priority: priority,
      status: TicketStatus.open,
      creatorId: creatorId,
      assigneeId: assigneeId,
      projectId: projectId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
      attachments: attachments,
    );

    final response = await _client
        .from('tickets')
        .insert(ticket.toJson())
        .select()
        .single();

    final createdTicket = Ticket.fromJson(response);

    // Create notification for assignee
    if (assigneeId != null) {
      await _createTicketNotification(
        assigneeId,
        NotificationType.ticketAssigned,
        'New Ticket Assigned',
        'You have been assigned ticket: $title',
        {'ticket_id': createdTicket.id},
      );
    }

    return createdTicket;
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    await _client
        .from('tickets')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
          if (status == TicketStatus.resolved)
            'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId);

    // Get ticket details for notification
    final ticket = await _client
        .from('tickets')
        .select()
        .eq('id', ticketId)
        .single();

    // Notify creator of status change
    await _createTicketNotification(
      ticket['creator_id'],
      NotificationType.ticketUpdated,
      'Ticket Status Updated',
      'Ticket "${ticket['title']}" status changed to ${status.name}',
      {'ticket_id': ticketId},
    );
  }

  /// Assign ticket to user
  Future<void> assignTicket(String ticketId, String assigneeId) async {
    await _client
        .from('tickets')
        .update({
          'assignee_id': assigneeId,
          'status': TicketStatus.inProgress.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', ticketId);

    final ticket = await _client
        .from('tickets')
        .select()
        .eq('id', ticketId)
        .single();

    await _createTicketNotification(
      assigneeId,
      NotificationType.ticketAssigned,
      'Ticket Assigned',
      'You have been assigned: ${ticket['title']}',
      {'ticket_id': ticketId},
    );
  }

  /// Add comment to ticket
  Future<TicketComment> addTicketComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
    bool isInternal = false,
  }) async {
    final comment = TicketComment(
      id: '',
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
      isInternal: isInternal,
    );

    final response = await _client
        .from('ticket_comments')
        .insert(comment.toJson())
        .select()
        .single();

    await _client
        .from('tickets')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', ticketId);

    return TicketComment.fromJson(response);
  }

  /// Get ticket analytics
  Future<Map<String, dynamic>> getTicketAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client
        .rpc('get_ticket_analytics', params: {
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
        })
        .single();

    return response;
  }

  // ========== TAGGING MODULE ==========

  /// Get all tags
  Future<List<Tag>> getTags() async {
    final response = await _client
        .from('tags')
        .select()
        .order('usage_count', ascending: false);

    return (response as List).map((json) => Tag.fromJson(json)).toList();
  }

  /// Create a new tag
  Future<Tag> createTag({
    required String name,
    required String color,
    String? description,
  }) async {
    final tag = Tag(
      id: '',
      name: name,
      color: color,
      description: description,
      createdAt: DateTime.now(),
    );

    final response = await _client
        .from('tags')
        .insert(tag.toJson())
        .select()
        .single();

    return Tag.fromJson(response);
  }

  /// Apply tag to message
  Future<void> tagMessage(String messageId, String tagId) async {
    await _client.from('message_tags').insert({
      'message_id': messageId,
      'tag_id': tagId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _incrementTagUsage(tagId);
  }

  /// Apply tag to ticket
  Future<void> tagTicket(String ticketId, String tagId) async {
    await _client.from('ticket_tags').insert({
      'ticket_id': ticketId,
      'tag_id': tagId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _incrementTagUsage(tagId);
  }

  /// Get suggested tags for content (AI-based)
  Future<List<Tag>> getSuggestedTags(String content) async {
    // This would integrate with an AI service for tag suggestions
    // For now, return simple keyword-based suggestions
    final allTags = await getTags();
    
    return allTags.where((tag) {
      final contentLower = content.toLowerCase();
      final tagLower = tag.name.toLowerCase();
      return contentLower.contains(tagLower);
    }).take(5).toList();
  }

  /// Search by tags
  Future<Map<String, List<dynamic>>> searchByTags(List<String> tagIds) async {
    final messages = await _client
        .from('message_tags')
        .select('message_id')
        .inFilter('tag_id', tagIds);

    final tickets = await _client
        .from('ticket_tags')
        .select('ticket_id')
        .inFilter('tag_id', tagIds);

    return {
      'messages': messages,
      'tickets': tickets,
    };
  }

  // ========== NOTIFICATIONS ==========

  /// Get notifications for user
  Stream<List<CommunicationNotification>> getNotificationsStream(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('timestamp', ascending: false)
        .map((data) => data
            .map((json) => CommunicationNotification.fromJson(json))
            .toList());
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  // ========== AUDIT LOGGING ==========

  /// Log communication action
  Future<void> logAction({
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _client.from('communications_audit').insert({
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ========== PRIVATE HELPERS ==========

  Future<void> _incrementTagUsage(String tagId) async {
    await _client.rpc('increment_tag_usage', params: {'tag_uuid': tagId});
  }

  Future<void> _createMentionNotifications(
    List<String> mentions,
    Message message,
  ) async {
    for (final userId in mentions) {
      await _createTicketNotification(
        userId,
        NotificationType.mention,
        'You were mentioned',
        '${message.senderName} mentioned you in a message',
        {'message_id': message.id, 'channel_id': message.channelId},
      );
    }
  }

  Future<void> _createTicketNotification(
    String userId,
    NotificationType type,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final notification = CommunicationNotification(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      data: data,
    );

    await _client.from('notifications').insert(notification.toJson());
  }
}