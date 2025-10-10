import 'package:latlong2/latlong.dart';

class StateModel {
  final String id;
  final String name;
  final String code;
  final LatLng capitalLocation;
  final List<String> districtIds;
  final String? nodalOfficer;
  final String? nodalOfficerContact;
  final double fundUtilizationRate;
  final double performanceScore;
  final int totalProjects;
  final int completedProjects;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  StateModel({
    required this.id,
    required this.name,
    required this.code,
    required this.capitalLocation,
    this.districtIds = const [],
    this.nodalOfficer,
    this.nodalOfficerContact,
    this.fundUtilizationRate = 0.0,
    this.performanceScore = 0.0,
    this.totalProjects = 0,
    this.completedProjects = 0,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    LatLng capitalLocation;
    if (json['capital_location'] != null) {
      final coords = json['capital_location']['coordinates'] as List;
      capitalLocation = LatLng(coords[1], coords[0]);
    } else {
      capitalLocation = const LatLng(0, 0);
    }

    return StateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      capitalLocation: capitalLocation,
      districtIds: List<String>.from(json['district_ids'] as List? ?? []),
      nodalOfficer: json['nodal_officer'] as String?,
      nodalOfficerContact: json['nodal_officer_contact'] as String?,
      fundUtilizationRate: (json['fund_utilization_rate'] as num?)?.toDouble() ?? 0.0,
      performanceScore: (json['performance_score'] as num?)?.toDouble() ?? 0.0,
      totalProjects: json['total_projects'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'capital_location': {
        'type': 'Point',
        'coordinates': [capitalLocation.longitude, capitalLocation.latitude]
      },
      'district_ids': districtIds,
      'nodal_officer': nodalOfficer,
      'nodal_officer_contact': nodalOfficerContact,
      'fund_utilization_rate': fundUtilizationRate,
      'performance_score': performanceScore,
      'total_projects': totalProjects,
      'completed_projects': completedProjects,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StateModel copyWith({
    String? id,
    String? name,
    String? code,
    LatLng? capitalLocation,
    List<String>? districtIds,
    String? nodalOfficer,
    String? nodalOfficerContact,
    double? fundUtilizationRate,
    double? performanceScore,
    int? totalProjects,
    int? completedProjects,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      capitalLocation: capitalLocation ?? this.capitalLocation,
      districtIds: districtIds ?? this.districtIds,
      nodalOfficer: nodalOfficer ?? this.nodalOfficer,
      nodalOfficerContact: nodalOfficerContact ?? this.nodalOfficerContact,
      fundUtilizationRate: fundUtilizationRate ?? this.fundUtilizationRate,
      performanceScore: performanceScore ?? this.performanceScore,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}