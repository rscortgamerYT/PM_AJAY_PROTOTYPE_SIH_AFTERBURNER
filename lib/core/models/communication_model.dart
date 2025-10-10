enum ConversationType {
  centreToState('centre_to_state'),
  stateToAgency('state_to_agency'),
  centreToAgency('centre_to_agency'),
  broadcast('broadcast');

  final String value;
  const ConversationType(this.value);

  static ConversationType fromString(String value) {
    return ConversationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ConversationType.broadcast,
    );
  }
}

enum MessagePriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const MessagePriority(this.value);

  static MessagePriority fromString(String value) {
    return MessagePriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => MessagePriority.medium,
    );
  }
}

class ConversationChannel {
  final String id;
  final String title;
  final ConversationType type;
  final String? projectId;
  final String? milestoneId;
  final List<String> participants;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isArchived;
  final Map<String, dynamic> metadata;

  ConversationChannel({
    required this.id,
    required this.title,
    required this.type,
    this.projectId,
    this.milestoneId,
    required this.participants,
    required this.createdBy,
    required this.createdAt,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isArchived = false,
    this.metadata = const {},
  });

  factory ConversationChannel.fromJson(Map<String, dynamic> json) {
    return ConversationChannel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ConversationType.fromString(json['type'] as String),
      projectId: json['project_id'] as String?,
      milestoneId: json['milestone_id'] as String?,
      participants: List<String>.from(json['participants'] as List),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.value,
      'project_id': projectId,
      'milestone_id': milestoneId,
      'participants': participants,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'is_archived': isArchived,
      'metadata': metadata,
    };
  }
}

class Message {
  final String id;
  final String channelId;
  final String senderId;
  final String content;
  final String? parentMessageId;
  final MessagePriority priority;
  final List<String> mentions;
  final List<MessageAttachment> attachments;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> readBy;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.content,
    this.parentMessageId,
    this.priority = MessagePriority.medium,
    this.mentions = const [],
    this.attachments = const [],
    this.isEdited = false,
    this.editedAt,
    this.readBy = const [],
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      parentMessageId: json['parent_message_id'] as String?,
      priority: MessagePriority.fromString(json['priority'] as String? ?? 'medium'),
      mentions: List<String>.from(json['mentions'] as List? ?? []),
      attachments: (json['attachments'] as List?)
              ?.map((a) => MessageAttachment.fromJson(a))
              .toList() ??
          [],
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      readBy: List<String>.from(json['read_by'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'sender_id': senderId,
      'content': content,
      'parent_message_id': parentMessageId,
      'priority': priority.value,
      'mentions': mentions,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'read_by': readBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MessageAttachment {
  final String id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String storagePath;
  final String? thumbnailPath;
  final DateTime uploadedAt;

  MessageAttachment({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.storagePath,
    this.thumbnailPath,
    required this.uploadedAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}