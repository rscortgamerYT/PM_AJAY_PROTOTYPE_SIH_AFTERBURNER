import 'dart:async';
import '../models/communication_models.dart';
import '../data/demo_data_generator.dart';

/// Demo Communication Service
/// 
/// Provides mock data streams for Communication Hub when Supabase is not available
class CommunicationServiceDemo {
  // Static demo data storage
  static List<Channel>? _channels;
  static final Map<String, List<Message>> _messagesByChannel = {};
  static List<Ticket>? _tickets;
  static List<Tag>? _tags;

  /// Get all channels for the current user
  Stream<List<Channel>> getChannelsStream(String userId) {
    _channels ??= DemoDataGenerator.generateChannels(count: 15, userId: userId);
    return Stream.periodic(const Duration(milliseconds: 100), (_) => _channels!)
        .take(1);
  }

  /// Get messages for a specific channel
  Stream<List<Message>> getMessagesStream(String channelId) {
    if (!_messagesByChannel.containsKey(channelId)) {
      _messagesByChannel[channelId] = 
          DemoDataGenerator.generateMessages(count: 50, channelId: channelId);
    }
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => _messagesByChannel[channelId]!
    ).take(1);
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
      id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
      channelId: channelId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      mentions: mentions,
      attachments: attachments,
      parentMessageId: parentMessageId,
    );

    if (!_messagesByChannel.containsKey(channelId)) {
      _messagesByChannel[channelId] = [];
    }
    _messagesByChannel[channelId]!.add(message);

    // Update channel last message
    if (_channels != null) {
      final channelIndex = _channels!.indexWhere((c) => c.id == channelId);
      if (channelIndex != -1) {
        final channel = _channels![channelIndex];
        _channels![channelIndex] = Channel(
          id: channel.id,
          name: channel.name,
          type: channel.type,
          memberIds: channel.memberIds,
          createdAt: channel.createdAt,
          lastMessageAt: DateTime.now(),
          lastMessage: content,
          unreadCount: channel.unreadCount,
          metadata: channel.metadata,
        );
      }
    }

    return message;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String channelId, String userId) async {
    if (_channels != null) {
      final channelIndex = _channels!.indexWhere((c) => c.id == channelId);
      if (channelIndex != -1) {
        final channel = _channels![channelIndex];
        _channels![channelIndex] = Channel(
          id: channel.id,
          name: channel.name,
          type: channel.type,
          memberIds: channel.memberIds,
          createdAt: channel.createdAt,
          lastMessageAt: channel.lastMessageAt,
          lastMessage: channel.lastMessage,
          unreadCount: 0,
          metadata: channel.metadata,
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get all tickets
  Stream<List<Ticket>> getTicketsStream({
    String? userId,
    TicketStatus? status,
    TicketPriority? priority,
    String? projectId,
  }) {
    _tickets ??= DemoDataGenerator.generateTickets(count: 30);
    
    var filteredTickets = _tickets!.where((ticket) {
      if (userId != null &&
          ticket.creatorId != userId &&
          ticket.assigneeId != userId) {
        return false;
      }
      if (status != null && ticket.status != status) return false;
      if (priority != null && ticket.priority != priority) return false;
      if (projectId != null && ticket.projectId != projectId) return false;
      return true;
    }).toList();

    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) => filteredTickets
    ).take(1);
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
      id: 'TKT${DateTime.now().millisecondsSinceEpoch}',
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

    _tickets ??= [];
    _tickets!.add(ticket);

    return ticket;
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    if (_tickets != null) {
      final ticketIndex = _tickets!.indexWhere((t) => t.id == ticketId);
      if (ticketIndex != -1) {
        final ticket = _tickets![ticketIndex];
        _tickets![ticketIndex] = Ticket(
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          type: ticket.type,
          priority: ticket.priority,
          status: status,
          creatorId: ticket.creatorId,
          assigneeId: ticket.assigneeId,
          projectId: ticket.projectId,
          createdAt: ticket.createdAt,
          updatedAt: DateTime.now(),
          resolvedAt: status == TicketStatus.resolved ? DateTime.now() : ticket.resolvedAt,
          dueDate: ticket.dueDate,
          tags: ticket.tags,
          comments: ticket.comments,
          attachments: ticket.attachments,
          metadata: ticket.metadata,
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
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
      id: 'CMT${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
      isInternal: isInternal,
    );

    if (_tickets != null) {
      final ticketIndex = _tickets!.indexWhere((t) => t.id == ticketId);
      if (ticketIndex != -1) {
        final ticket = _tickets![ticketIndex];
        final updatedComments = List<TicketComment>.from(ticket.comments)..add(comment);
        _tickets![ticketIndex] = Ticket(
          id: ticket.id,
          title: ticket.title,
          description: ticket.description,
          type: ticket.type,
          priority: ticket.priority,
          status: ticket.status,
          creatorId: ticket.creatorId,
          assigneeId: ticket.assigneeId,
          projectId: ticket.projectId,
          createdAt: ticket.createdAt,
          updatedAt: DateTime.now(),
          resolvedAt: ticket.resolvedAt,
          dueDate: ticket.dueDate,
          tags: ticket.tags,
          comments: updatedComments,
          attachments: ticket.attachments,
          metadata: ticket.metadata,
        );
      }
    }

    return comment;
  }

  /// Get all tags
  Future<List<Tag>> getTags() async {
    _tags ??= DemoDataGenerator.generateTags(count: 20);
    await Future.delayed(const Duration(milliseconds: 100));
    return _tags!;
  }

  /// Create a new tag
  Future<Tag> createTag({
    required String name,
    required String color,
    String? description,
  }) async {
    final tag = Tag(
      id: 'TAG${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      color: color,
      description: description,
      createdAt: DateTime.now(),
    );

    _tags ??= [];
    _tags!.add(tag);

    return tag;
  }
}