import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agency_model.dart';
import '../models/project_model.dart';

class SpatialQueryService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Find agencies within a specified radius (in meters) of a location
  Future<List<AgencyModel>> findNearbyAgencies({
    required LatLng location,
    required double radiusInMeters,
    AgencyType? type,
  }) async {
    final query = _client
        .rpc('find_nearby_agencies', params: {
          'target_longitude': location.longitude,
          'target_latitude': location.latitude,
          'radius_meters': radiusInMeters,
          'agency_type_filter': type?.value,
        });

    final response = await query;
    return (response as List)
        .map((json) => AgencyModel.fromJson(json))
        .toList();
  }

  /// Find projects within a specified radius of a location
  Future<List<ProjectModel>> findNearbyProjects({
    required LatLng location,
    required double radiusInMeters,
    ProjectStatus? status,
    ProjectComponent? component,
  }) async {
    final query = _client
        .rpc('find_nearby_projects', params: {
          'target_longitude': location.longitude,
          'target_latitude': location.latitude,
          'radius_meters': radiusInMeters,
          'status_filter': status?.value,
          'component_filter': component?.value,
        });

    final response = await query;
    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Find all projects within a polygon boundary
  Future<List<ProjectModel>> findProjectsInBoundary({
    required List<LatLng> boundaryPoints,
  }) async {
    final coordinates = boundaryPoints
        .map((point) => [point.longitude, point.latitude])
        .toList();

    final query = _client
        .rpc('find_projects_in_polygon', params: {
          'polygon_coords': coordinates,
        });

    final response = await query;
    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Calculate distance between two points in meters
  Future<double> calculateDistance({
    required LatLng from,
    required LatLng to,
  }) async {
    final response = await _client
        .rpc('calculate_distance', params: {
          'from_longitude': from.longitude,
          'from_latitude': from.latitude,
          'to_longitude': to.longitude,
          'to_latitude': to.latitude,
        });

    return (response as num).toDouble();
  }

  /// Check if a point is within an agency's coverage area
  Future<bool> isPointInCoverageArea({
    required String agencyId,
    required LatLng point,
  }) async {
    final response = await _client
        .rpc('is_point_in_coverage', params: {
          'agency_uuid': agencyId,
          'point_longitude': point.longitude,
          'point_latitude': point.latitude,
        });

    return response as bool;
  }

  /// Get agencies whose coverage areas overlap with a given polygon
  Future<List<AgencyModel>> findOverlappingAgencies({
    required List<LatLng> polygonPoints,
  }) async {
    final coordinates = polygonPoints
        .map((point) => [point.longitude, point.latitude])
        .toList();

    final query = _client
        .rpc('find_overlapping_agencies', params: {
          'polygon_coords': coordinates,
        });

    final response = await query;
    return (response as List)
        .map((json) => AgencyModel.fromJson(json))
        .toList();
  }

  /// Find the nearest agency to a location
  Future<AgencyModel?> findNearestAgency({
    required LatLng location,
    AgencyType? type,
  }) async {
    final agencies = await findNearbyAgencies(
      location: location,
      radiusInMeters: 100000, // 100km
      type: type,
    );

    if (agencies.isEmpty) return null;
    return agencies.first;
  }

  /// Get projects along a route (within a buffer distance)
  Future<List<ProjectModel>> findProjectsAlongRoute({
    required List<LatLng> routePoints,
    required double bufferMeters,
  }) async {
    final coordinates = routePoints
        .map((point) => [point.longitude, point.latitude])
        .toList();

    final query = _client
        .rpc('find_projects_along_route', params: {
          'route_coords': coordinates,
          'buffer_meters': bufferMeters,
        });

    final response = await query;
    return (response as List)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Get district boundaries containing a point
  Future<Map<String, dynamic>?> getDistrictAtLocation({
    required LatLng location,
  }) async {
    final response = await _client
        .rpc('get_district_at_point', params: {
          'point_longitude': location.longitude,
          'point_latitude': location.latitude,
        });

    return response as Map<String, dynamic>?;
  }

  /// Calculate coverage percentage of projects in a district
  Future<double> calculateDistrictCoverage({
    required String districtId,
  }) async {
    final response = await _client
        .rpc('calculate_district_coverage', params: {
          'district_uuid': districtId,
        });

    return (response as num).toDouble();
  }
}