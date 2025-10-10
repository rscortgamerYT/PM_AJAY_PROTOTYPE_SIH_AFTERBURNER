import 'package:latlong2/latlong.dart';

enum UserRole {
  centreAdmin('centre_admin'),
  stateOfficer('state_officer'),
  agencyUser('agency_user'),
  overwatch('overwatch'),
  public('public');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.public,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  final String fullName;
  final String? phone;
  final String? stateId;
  final String? districtId;
  final String? agencyId;
  final LatLng? location;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.stateId,
    this.districtId,
    this.agencyId,
    this.location,
    this.isActive = true,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['location'] != null) {
      final coords = json['location']['coordinates'] as List;
      location = LatLng(coords[1], coords[0]);
    }

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      stateId: json['state_id'] as String?,
      districtId: json['district_id'] as String?,
      agencyId: json['agency_id'] as String?,
      location: location,
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'full_name': fullName,
      'phone': phone,
      'state_id': stateId,
      'district_id': districtId,
      'agency_id': agencyId,
      'location': location != null
          ? {
              'type': 'Point',
              'coordinates': [location!.longitude, location!.latitude]
            }
          : null,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? phone,
    String? stateId,
    String? districtId,
    String? agencyId,
    LatLng? location,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      agencyId: agencyId ?? this.agencyId,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}