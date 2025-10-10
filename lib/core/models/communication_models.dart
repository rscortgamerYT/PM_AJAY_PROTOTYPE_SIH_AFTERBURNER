import 'package:latlong2/latlong.dart';

/// Message model for chat functionality
class Message {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final List<String> mentions;
  final List<Attachment> attachments;
  final String? parentMessageId;
  final bool isRead;
  final MessageType type;

  Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.mentions = const [],
    this.attachments = const [],
    this.parentMessageId,
    this.isRead = false,
    this.type = MessageType.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mentions: (json['mentions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      attachments: (json['attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e))
          .toList() ?? [],
      parentMessageId: json['parent_message_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'mentions': mentions,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'parent_message_id': parentMessageId,
      'is_read': isRead,
      'type': type.name,
    };
  }
}

enum MessageType {
  text,
  file,
  image,
  system,
}

/// Channel model for chat
class Channel {
  final String id;
  final String name;
  final ChannelType type;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final int unreadCount;
  final Map<String, dynamic> metadata;

  Channel({
    required this.id,
    required this.name,
    required this.type,
    required this.memberIds,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.metadata = const {},
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ChannelType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChannelType.group,
      ),
      memberIds: (json['member_ids'] as List).map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'member_ids': memberIds,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'metadata': metadata,
    };
  }
}

enum ChannelType {
  direct,
  group,
  broadcast,
}

/// Attachment model for files
class Attachment {
  final String id;
  final String name;
  final String url;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      mimeType: json['mime_type'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'mime_type': mimeType,
      'size': size,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

/// Ticket model for issue tracking
class Ticket {
  final String id;
  final String title;
  final String description;
  final TicketType type;
  final TicketPriority priority;
  final TicketStatus status;
  final String creatorId;
  final String? assigneeId;
  final String? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? dueDate;
  final List<String> tags;
  final List<TicketComment> comments;
  final List<Attachment> attachments;
  final Map<String, dynamic> metadata;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.creatorId,
    this.assigneeId,
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.dueDate,
    this.tags = const [],
    this.comments = const [],
    this.attachments = const [],
    this.metadata = const {},
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TicketType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TicketType.general,
      ),
      priority: TicketPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      creatorId: json['creator_id'] as String,
      assigneeId: json['assignee_id'] as String?,
      projectId: json['project_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      comments: (json['comments'] as List?)
          ?.map((e) => TicketComment.fromJson(e))
          .toList() ?? [],
      attachments: (json['attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e))
          .toList() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'creator_id': creatorId,
      'assignee_id': assigneeId,
      'project_id': projectId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'tags': tags,
      'comments': comments.map((c) => c.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'metadata': metadata,
    };
  }

  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && status != TicketStatus.resolved;
}

enum TicketType {
  general,
  fundRequest,
  escalation,
  technical,
  compliance,
  quality,
}

enum TicketPriority {
  low,
  medium,
  high,
  critical,
}

enum TicketStatus {
  open,
  inProgress,
  pendingInfo,
  resolved,
  closed,
}

/// Ticket comment model
class TicketComment {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final bool isInternal;

  TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.isInternal = false,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isInternal: json['is_internal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_internal': isInternal,
    };
  }
}

/// Tag model for categorization
class Tag {
  final String id;
  final String name;
  final String color;
  final String? description;
  final int usageCount;
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    this.usageCount = 0,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Notification model
class CommunicationNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  CommunicationNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data = const {},
  });

  factory CommunicationNotification.fromJson(Map<String, dynamic> json) {
    return CommunicationNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
    };
  }
}

enum NotificationType {
  general,
  newMessage,
  mention,
  ticketAssigned,
  ticketUpdated,
  ticketEscalated,
  tagAdded,
}