import 'package:latlong2/latlong.dart';

enum ProjectStatus {
  planning('planning'),
  inProgress('in_progress'),
  review('review'),
  completed('completed'),
  onHold('on_hold'),
  cancelled('cancelled');

  final String value;
  const ProjectStatus(this.value);

  static ProjectStatus fromString(String value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.planning,
    );
  }
}

enum ProjectComponent {
  adarshGram('adarsh_gram'),
  gia('gia'),
  hostel('hostel'),
  admin('admin');

  final String value;
  const ProjectComponent(this.value);

  static ProjectComponent fromString(String value) {
    return ProjectComponent.values.firstWhere(
      (component) => component.value == value,
      orElse: () => ProjectComponent.adarshGram,
    );
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? agencyId;
  final String? stateId;
  final String? districtId;
  final LatLng? location;
  final List<LatLng>? projectArea;
  final ProjectStatus status;
  final ProjectComponent component;
  final double? totalBudget;
  final double? allocatedBudget;
  final double? utilizedBudget;
  final DateTime? startDate;
  final DateTime? endDate;
  final double completionPercentage;
  final int beneficiariesCount;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.agencyId,
    this.stateId,
    this.districtId,
    this.location,
    this.projectArea,
    this.status = ProjectStatus.planning,
    required this.component,
    this.totalBudget,
    this.allocatedBudget,
    this.utilizedBudget,
    this.startDate,
    this.endDate,
    this.completionPercentage = 0.0,
    this.beneficiariesCount = 0,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['location'] != null) {
      final coords = json['location']['coordinates'] as List;
      location = LatLng(coords[1], coords[0]);
    }

    List<LatLng>? projectArea;
    if (json['project_area'] != null) {
      final coords = json['project_area']['coordinates'][0] as List;
      projectArea = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
    }

    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      agencyId: json['agency_id'] as String?,
      stateId: json['state_id'] as String?,
      districtId: json['district_id'] as String?,
      location: location,
      projectArea: projectArea,
      status: ProjectStatus.fromString(json['status'] as String),
      component: ProjectComponent.fromString(json['component'] as String),
      totalBudget: (json['total_budget'] as num?)?.toDouble(),
      allocatedBudget: (json['allocated_budget'] as num?)?.toDouble(),
      utilizedBudget: (json['utilized_budget'] as num?)?.toDouble(),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      completionPercentage: (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
      beneficiariesCount: json['beneficiaries_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'agency_id': agencyId,
      'state_id': stateId,
      'district_id': districtId,
      'location': location != null
          ? {
              'type': 'Point',
              'coordinates': [location!.longitude, location!.latitude]
            }
          : null,
      'project_area': projectArea != null
          ? {
              'type': 'Polygon',
              'coordinates': [
                projectArea!.map((point) => [point.longitude, point.latitude]).toList()
              ]
            }
          : null,
      'status': status.value,
      'component': component.value,
      'total_budget': totalBudget,
      'allocated_budget': allocatedBudget,
      'utilized_budget': utilizedBudget,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'completion_percentage': completionPercentage,
      'beneficiaries_count': beneficiariesCount,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? agencyId,
    String? stateId,
    String? districtId,
    LatLng? location,
    List<LatLng>? projectArea,
    ProjectStatus? status,
    ProjectComponent? component,
    double? totalBudget,
    double? allocatedBudget,
    double? utilizedBudget,
    DateTime? startDate,
    DateTime? endDate,
    double? completionPercentage,
    int? beneficiariesCount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      agencyId: agencyId ?? this.agencyId,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      location: location ?? this.location,
      projectArea: projectArea ?? this.projectArea,
      status: status ?? this.status,
      component: component ?? this.component,
      totalBudget: totalBudget ?? this.totalBudget,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      utilizedBudget: utilizedBudget ?? this.utilizedBudget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      beneficiariesCount: beneficiariesCount ?? this.beneficiariesCount,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}