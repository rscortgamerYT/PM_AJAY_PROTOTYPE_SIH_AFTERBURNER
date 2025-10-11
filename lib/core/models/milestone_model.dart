import 'package:latlong2/latlong.dart';

enum MilestoneType {
  planning('planning'),
  design('design'),
  procurement('procurement'),
  construction('construction'),
  inspection('inspection'),
  completion('completion'),
  handover('handover'),
  custom('custom');

  final String value;
  const MilestoneType(this.value);

  static MilestoneType fromString(String value) {
    return MilestoneType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MilestoneType.custom,
    );
  }

  String get displayName {
    switch (this) {
      case MilestoneType.planning:
        return 'Planning';
      case MilestoneType.design:
        return 'Design';
      case MilestoneType.procurement:
        return 'Procurement';
      case MilestoneType.construction:
        return 'Construction';
      case MilestoneType.inspection:
        return 'Inspection';
      case MilestoneType.completion:
        return 'Completion';
      case MilestoneType.handover:
        return 'Handover';
      case MilestoneType.custom:
        return 'Custom';
    }
  }
}

enum MilestoneStatus {
  notStarted('not_started'),
  inProgress('in_progress'),
  submitted('submitted'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected'),
  delayed('delayed');

  final String value;
  const MilestoneStatus(this.value);

  static MilestoneStatus fromString(String value) {
    return MilestoneStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MilestoneStatus.notStarted,
    );
  }
}

class GeoFence {
  final LatLng center;
  final double radiusMeters;
  final List<LatLng>? polygon;

  GeoFence({
    required this.center,
    required this.radiusMeters,
    this.polygon,
  });

  factory GeoFence.fromJson(Map<String, dynamic> json) {
    return GeoFence(
      center: LatLng(
        json['center']['lat'] as double,
        json['center']['lng'] as double,
      ),
      radiusMeters: json['radius_meters'] as double,
      polygon: json['polygon'] != null
          ? (json['polygon'] as List)
              .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center': {
        'lat': center.latitude,
        'lng': center.longitude,
      },
      'radius_meters': radiusMeters,
      'polygon': polygon
          ?.map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
    };
  }

  bool containsPoint(LatLng point) {
    if (polygon != null) {
      return _pointInPolygon(point, polygon!);
    }
    const distance = Distance();
    return distance(center, point) <= radiusMeters;
  }

  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];
      
      if ((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) {
        final lng = (p2.longitude - p1.longitude) *
                (point.latitude - p1.latitude) /
                (p2.latitude - p1.latitude) +
            p1.longitude;
        if (point.longitude < lng) {
          intersections++;
        }
      }
    }
    return intersections % 2 == 1;
  }
}

class MilestoneEvidence {
  final String id;
  final String type; // photo, document, report
  final String url;
  final String? thumbnail;
  final LatLng? location;
  final DateTime capturedAt;
  final String capturedBy;
  final Map<String, dynamic> metadata;

  MilestoneEvidence({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.location,
    required this.capturedAt,
    required this.capturedBy,
    this.metadata = const {},
  });

  factory MilestoneEvidence.fromJson(Map<String, dynamic> json) {
    return MilestoneEvidence(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      location: json['location'] != null
          ? LatLng(
              json['location']['lat'] as double,
              json['location']['lng'] as double,
            )
          : null,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      capturedBy: json['captured_by'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnail': thumbnail,
      'location': location != null
          ? {
              'lat': location!.latitude,
              'lng': location!.longitude,
            }
          : null,
      'captured_at': capturedAt.toIso8601String(),
      'captured_by': capturedBy,
      'metadata': metadata,
    };
  }
}

class ProjectMilestone {
  final String id;
  final String projectId;
  final String agencyId;
  final String name;
  final String description;
  final MilestoneType type;
  final MilestoneStatus status;
  final DateTime plannedStartDate;
  final DateTime plannedEndDate;
  final DateTime? actualStartDate;
  final DateTime? actualEndDate;
  final double completionPercentage;
  final GeoFence? geoFence;
  final bool requiresGeoValidation;
  final List<MilestoneEvidence> evidence;
  final String? submittedBy;
  final DateTime? submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final int? slaHours;
  final DateTime? slaDueDate;
  final List<String> dependencies;
  final Map<String, dynamic> metadata;

  ProjectMilestone({
    required this.id,
    required this.projectId,
    required this.agencyId,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.plannedStartDate,
    required this.plannedEndDate,
    this.actualStartDate,
    this.actualEndDate,
    this.completionPercentage = 0.0,
    this.geoFence,
    this.requiresGeoValidation = false,
    this.evidence = const [],
    this.submittedBy,
    this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.slaHours,
    this.slaDueDate,
    this.dependencies = const [],
    this.metadata = const {},
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) {
    return ProjectMilestone(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      agencyId: json['agency_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: MilestoneType.fromString(json['type'] as String),
      status: MilestoneStatus.fromString(json['status'] as String),
      plannedStartDate: DateTime.parse(json['planned_start_date'] as String),
      plannedEndDate: DateTime.parse(json['planned_end_date'] as String),
      actualStartDate: json['actual_start_date'] != null
          ? DateTime.parse(json['actual_start_date'] as String)
          : null,
      actualEndDate: json['actual_end_date'] != null
          ? DateTime.parse(json['actual_end_date'] as String)
          : null,
      completionPercentage: json['completion_percentage'] as double? ?? 0.0,
      geoFence: json['geo_fence'] != null
          ? GeoFence.fromJson(json['geo_fence'] as Map<String, dynamic>)
          : null,
      requiresGeoValidation: json['requires_geo_validation'] as bool? ?? false,
      evidence: (json['evidence'] as List?)
              ?.map((e) => MilestoneEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      submittedBy: json['submitted_by'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewNotes: json['review_notes'] as String?,
      slaHours: json['sla_hours'] as int?,
      slaDueDate: json['sla_due_date'] != null
          ? DateTime.parse(json['sla_due_date'] as String)
          : null,
      dependencies: List<String>.from(json['dependencies'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'agency_id': agencyId,
      'name': name,
      'description': description,
      'type': type.value,
      'status': status.value,
      'planned_start_date': plannedStartDate.toIso8601String(),
      'planned_end_date': plannedEndDate.toIso8601String(),
      'actual_start_date': actualStartDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'completion_percentage': completionPercentage,
      'geo_fence': geoFence?.toJson(),
      'requires_geo_validation': requiresGeoValidation,
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'submitted_by': submittedBy,
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'review_notes': reviewNotes,
      'sla_hours': slaHours,
      'sla_due_date': slaDueDate?.toIso8601String(),
      'dependencies': dependencies,
      'metadata': metadata,
    };
  }

  bool get isDelayed {
    if (status == MilestoneStatus.approved) return false;
    return DateTime.now().isAfter(plannedEndDate);
  }

  bool get isSlaBreach {
    if (slaDueDate == null) return false;
    if (status == MilestoneStatus.approved) return false;
    return DateTime.now().isAfter(slaDueDate!);
  }

  Duration? get remainingSlaTime {
    if (slaDueDate == null) return null;
    if (status == MilestoneStatus.approved) return null;
    return slaDueDate!.difference(DateTime.now());
  }

  ProjectMilestone copyWith({
    String? id,
    String? projectId,
    String? agencyId,
    String? name,
    String? description,
    MilestoneType? type,
    MilestoneStatus? status,
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    DateTime? actualStartDate,
    DateTime? actualEndDate,
    double? completionPercentage,
    GeoFence? geoFence,
    bool? requiresGeoValidation,
    List<MilestoneEvidence>? evidence,
    String? submittedBy,
    DateTime? submittedAt,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNotes,
    int? slaHours,
    DateTime? slaDueDate,
    List<String>? dependencies,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      agencyId: agencyId ?? this.agencyId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      plannedStartDate: plannedStartDate ?? this.plannedStartDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      geoFence: geoFence ?? this.geoFence,
      requiresGeoValidation: requiresGeoValidation ?? this.requiresGeoValidation,
      evidence: evidence ?? this.evidence,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      slaHours: slaHours ?? this.slaHours,
      slaDueDate: slaDueDate ?? this.slaDueDate,
      dependencies: dependencies ?? this.dependencies,
      metadata: metadata ?? this.metadata,
    );
  }
}