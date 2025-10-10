import 'package:latlong2/latlong.dart';

enum AgencyType {
  implementingAgency('implementing_agency'),
  nodalAgency('nodal_agency'),
  technicalAgency('technical_agency'),
  monitoringAgency('monitoring_agency');

  final String value;
  const AgencyType(this.value);

  static AgencyType fromString(String value) {
    return AgencyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AgencyType.implementingAgency,
    );
  }
}

class AgencyModel {
  final String id;
  final String name;
  final AgencyType type;
  final String? stateId;
  final String? districtId;
  final LatLng location;
  final List<LatLng>? coverageArea;
  final String? address;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final double capacityScore;
  final double performanceRating;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgencyModel({
    required this.id,
    required this.name,
    required this.type,
    this.stateId,
    this.districtId,
    required this.location,
    this.coverageArea,
    this.address,
    this.contactPerson,
    this.phone,
    this.email,
    this.capacityScore = 0.0,
    this.performanceRating = 0.0,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    final locationCoords = json['location']['coordinates'] as List;
    final location = LatLng(locationCoords[1], locationCoords[0]);

    List<LatLng>? coverageArea;
    if (json['coverage_area'] != null) {
      final coords = json['coverage_area']['coordinates'][0] as List;
      coverageArea = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
    }

    return AgencyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AgencyType.fromString(json['type'] as String),
      stateId: json['state_id'] as String?,
      districtId: json['district_id'] as String?,
      location: location,
      coverageArea: coverageArea,
      address: json['address'] as String?,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      capacityScore: (json['capacity_score'] as num?)?.toDouble() ?? 0.0,
      performanceRating: (json['performance_rating'] as num?)?.toDouble() ?? 0.0,
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
      'type': type.value,
      'state_id': stateId,
      'district_id': districtId,
      'location': {
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude]
      },
      'coverage_area': coverageArea != null
          ? {
              'type': 'Polygon',
              'coordinates': [
                coverageArea!.map((point) => [point.longitude, point.latitude]).toList()
              ]
            }
          : null,
      'address': address,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'capacity_score': capacityScore,
      'performance_rating': performanceRating,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AgencyModel copyWith({
    String? id,
    String? name,
    AgencyType? type,
    String? stateId,
    String? districtId,
    LatLng? location,
    List<LatLng>? coverageArea,
    String? address,
    String? contactPerson,
    String? phone,
    String? email,
    double? capacityScore,
    double? performanceRating,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      location: location ?? this.location,
      coverageArea: coverageArea ?? this.coverageArea,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      capacityScore: capacityScore ?? this.capacityScore,
      performanceRating: performanceRating ?? this.performanceRating,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}