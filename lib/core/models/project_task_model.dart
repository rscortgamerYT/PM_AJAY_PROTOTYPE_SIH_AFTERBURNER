import 'package:latlong2/latlong.dart';

enum TaskStatus {
  pending('pending'),
  assigned('assigned'),
  inProgress('in_progress'),
  completed('completed'),
  onHold('on_hold');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

class ProjectTaskModel {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final String? assignedAgencyId;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> requiredSkills;
  final double? estimatedBudget;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? estimatedDuration; // in days
  final LatLng? location;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectTaskModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    this.assignedAgencyId,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.requiredSkills = const [],
    this.estimatedBudget,
    this.startDate,
    this.dueDate,
    this.estimatedDuration,
    this.location,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['location'] != null) {
      final coords = json['location']['coordinates'] as List;
      location = LatLng(coords[1], coords[0]);
    }

    return ProjectTaskModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      assignedAgencyId: json['assigned_agency_id'] as String?,
      status: TaskStatus.fromString(json['status'] as String),
      priority: TaskPriority.fromString(json['priority'] as String),
      requiredSkills: (json['required_skills'] as List?)?.cast<String>() ?? [],
      estimatedBudget: (json['estimated_budget'] as num?)?.toDouble(),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      estimatedDuration: json['estimated_duration'] as int?,
      location: location,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'description': description,
      'assigned_agency_id': assignedAgencyId,
      'status': status.value,
      'priority': priority.value,
      'required_skills': requiredSkills,
      'estimated_budget': estimatedBudget,
      'start_date': startDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'location': location != null
          ? {
              'type': 'Point',
              'coordinates': [location!.longitude, location!.latitude]
            }
          : null,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProjectTaskModel copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? assignedAgencyId,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? requiredSkills,
    double? estimatedBudget,
    DateTime? startDate,
    DateTime? dueDate,
    int? estimatedDuration,
    LatLng? location,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectTaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      assignedAgencyId: assignedAgencyId ?? this.assignedAgencyId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}