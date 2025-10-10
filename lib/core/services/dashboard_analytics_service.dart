import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agency_model.dart';
import '../models/project_model.dart';

/// Service for dashboard analytics and performance metrics
class DashboardAnalyticsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get state-level performance metrics for national heatmap
  Future<List<StateMetrics>> getStateMetrics() async {
    final response = await _client
        .rpc('get_state_performance_metrics')
        .select();
    
    return (response as List)
        .map((json) => StateMetrics.fromJson(json))
        .toList();
  }

  /// Stream state metrics for real-time updates
  Stream<List<StateMetrics>> getStateMetricsStream() {
    return _client
        .from('state_performance_view')
        .stream(primaryKey: ['state_id'])
        .map((data) => data.map((json) => StateMetrics.fromJson(json)).toList());
  }

  /// Get agency performance scores for heatmap coloring
  Future<Map<String, double>> getAgencyPerformanceScores() async {
    final response = await _client
        .from('agencies')
        .select('id, performance_rating')
        .order('performance_rating', ascending: false);

    final Map<String, double> scores = {};
    for (var item in response) {
      scores[item['id'] as String] = (item['performance_rating'] as num).toDouble();
    }
    return scores;
  }

  /// Get fund flow data for waterfall visualization
  Future<FundFlowData> getFundFlowData() async {
    final response = await _client
        .rpc('get_fund_flow_waterfall_data')
        .single();

    return FundFlowData.fromJson(response as Map<String, dynamic>);
  }

  /// Get predictive analytics data
  Future<PredictionData> getDelayPredictions() async {
    final response = await _client
        .rpc('predict_project_delays')
        .single();

    return PredictionData.fromJson(response as Map<String, dynamic>);
  }

  /// Get compliance scores for scoreboard
  Stream<ComplianceData> getComplianceStream() {
    return _client
        .from('compliance_scores_view')
        .stream(primaryKey: ['entity_id'])
        .map((data) => ComplianceData.fromList(data));
  }

  /// Get district performance for state dashboard
  Future<StateData> getStateData(String stateId) async {
    final response = await _client
        .rpc('get_district_performance', params: {'state_uuid': stateId})
        .single();

    return StateData.fromJson(response as Map<String, dynamic>);
  }

  /// Get capacity optimization suggestions
  Future<OptimizationData> getCapacityOptimization(String stateId) async {
    final response = await _client
        .rpc('optimize_agency_capacity', params: {'state_uuid': stateId})
        .single();

    return OptimizationData.fromJson(response as Map<String, dynamic>);
  }

  /// Get project timeline data with dependencies
  Stream<TimelineData> getComponentTimelinesStream(String stateId) {
    return _client
        .from('project_timelines_view')
        .stream(primaryKey: ['project_id'])
        .eq('state_id', stateId)
        .map((data) => TimelineData.fromList(data));
  }

  /// Get agency requests for state approval
  Stream<List<AgencyRequest>> getAgencyRequestsStream(String stateId) {
    return _client
        .from('agency_requests')
        .stream(primaryKey: ['id'])
        .map((data) => data
            .where((item) =>
                item['state_id'] == stateId &&
                item['status'] == 'pending')
            .toList())
        .map((data) => data.map((json) => AgencyRequest.fromJson(json)).toList());
  }

  /// Get project location tracking data
  Stream<ProjectLocationData> trackProjectLocation(String projectId) {
    return _client
        .from('project_location_tracking')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('timestamp', ascending: false)
        .limit(1)
        .map((data) => data.isNotEmpty 
            ? ProjectLocationData.fromJson(data.first)
            : ProjectLocationData.empty());
  }

  /// Get milestone data for smart claims
  Stream<MilestoneData> getMilestoneDataStream(String projectId) {
    return _client
        .from('project_milestones_view')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('sequence', ascending: true)
        .map((data) => MilestoneData.fromList(data));
  }

  /// Get nearby resources for proximity intelligence
  Future<ResourceMapData> getNearbyResources(
    LatLng projectLocation,
    double searchRadius,
    List<String> resourceTypes,
  ) async {
    final response = await _client.rpc('find_nearby_resources', params: {
      'target_longitude': projectLocation.longitude,
      'target_latitude': projectLocation.latitude,
      'radius_meters': searchRadius * 1000, // Convert km to meters
      'resource_types': resourceTypes,
    });

    return ResourceMapData.fromJson(response);
  }

  /// Get collaboration data for multi-agency projects
  Stream<CollaborationData> getCollaborationDataStream(String projectId) {
    return _client
        .from('project_collaboration_view')
        .stream(primaryKey: ['project_id'])
        .eq('project_id', projectId)
        .map((data) => data.isNotEmpty
            ? CollaborationData.fromJson(data.first)
            : CollaborationData.empty());
  }

  /// Get agency performance analytics
  Future<PerformanceData> getAgencyPerformanceData(String agencyId) async {
    final response = await _client
        .rpc('get_agency_performance_analytics', params: {'agency_uuid': agencyId})
        .single();

    return PerformanceData.fromJson(response as Map<String, dynamic>);
  }

  /// Get collaboration network for cross-state partnerships
  Stream<NetworkData> getCollaborationNetworkStream() {
    return _client
        .from('collaboration_network_view')
        .stream(primaryKey: ['id'])
        .map((data) => NetworkData.fromList(data));
  }

  /// Get collaboration zones for inter-agency coordination
  Stream<List<CollaborationZone>> getCollaborationZones(
    String agencyId,
    double radiusKm,
  ) {
    return _client
        .from('collaboration_zones_view')
        .stream(primaryKey: ['id'])
        .eq('agency_id', agencyId)
        .map((data) => data
            .map((json) => CollaborationZone.fromJson(json))
            .where((zone) => zone.distance <= radiusKm)
            .toList());
  }
}

// Data models for analytics

class StateMetrics {
  final String stateId;
  final String stateName;
  final LatLng centerLocation;
  final double performanceScore;
  final int totalProjects;
  final int completedProjects;
  final double fundUtilization;

  StateMetrics({
    required this.stateId,
    required this.stateName,
    required this.centerLocation,
    required this.performanceScore,
    required this.totalProjects,
    required this.completedProjects,
    required this.fundUtilization,
  });

  factory StateMetrics.fromJson(Map<String, dynamic> json) {
    return StateMetrics(
      stateId: json['state_id'] as String,
      stateName: json['state_name'] as String,
      centerLocation: LatLng(
        json['center_latitude'] as double,
        json['center_longitude'] as double,
      ),
      performanceScore: (json['performance_score'] as num).toDouble(),
      totalProjects: json['total_projects'] as int,
      completedProjects: json['completed_projects'] as int,
      fundUtilization: (json['fund_utilization'] as num).toDouble(),
    );
  }
}

class FundFlowData {
  final double centreAllocation;
  final double stateReceived;
  final double agencyDisbursed;
  final double projectUtilized;
  final List<FundFlowStage> stages;

  FundFlowData({
    required this.centreAllocation,
    required this.stateReceived,
    required this.agencyDisbursed,
    required this.projectUtilized,
    required this.stages,
  });

  factory FundFlowData.fromJson(Map<String, dynamic> json) {
    return FundFlowData(
      centreAllocation: (json['centre_allocation'] as num).toDouble(),
      stateReceived: (json['state_received'] as num).toDouble(),
      agencyDisbursed: (json['agency_disbursed'] as num).toDouble(),
      projectUtilized: (json['project_utilized'] as num).toDouble(),
      stages: (json['stages'] as List)
          .map((s) => FundFlowStage.fromJson(s))
          .toList(),
    );
  }
}

class FundFlowStage {
  final String name;
  final double amount;
  final DateTime timestamp;
  final bool isBottleneck;

  FundFlowStage({
    required this.name,
    required this.amount,
    required this.timestamp,
    required this.isBottleneck,
  });

  factory FundFlowStage.fromJson(Map<String, dynamic> json) {
    return FundFlowStage(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isBottleneck: json['is_bottleneck'] as bool,
    );
  }
}

class PredictionData {
  final List<DelayPrediction> delayPredictions;
  final List<RiskAssessment> riskAssessments;

  PredictionData({
    required this.delayPredictions,
    required this.riskAssessments,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      delayPredictions: (json['delay_predictions'] as List)
          .map((p) => DelayPrediction.fromJson(p))
          .toList(),
      riskAssessments: (json['risk_assessments'] as List)
          .map((r) => RiskAssessment.fromJson(r))
          .toList(),
    );
  }
}

class DelayPrediction {
  final String projectId;
  final DateTime predictedDelayDate;
  final double confidence;

  DelayPrediction({
    required this.projectId,
    required this.predictedDelayDate,
    required this.confidence,
  });

  factory DelayPrediction.fromJson(Map<String, dynamic> json) {
    return DelayPrediction(
      projectId: json['project_id'] as String,
      predictedDelayDate: DateTime.parse(json['predicted_delay_date'] as String),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class RiskAssessment {
  final String entityId;
  final double riskScore;
  final String riskLevel;

  RiskAssessment({
    required this.entityId,
    required this.riskScore,
    required this.riskLevel,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      entityId: json['entity_id'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
    );
  }
}

class ComplianceData {
  final List<ComplianceRanking> rankings;
  final List<CompliancePerformer> topPerformers;

  ComplianceData({
    required this.rankings,
    required this.topPerformers,
  });

  factory ComplianceData.fromList(List<Map<String, dynamic>> data) {
    return ComplianceData(
      rankings: data.map((json) => ComplianceRanking.fromJson(json)).toList(),
      topPerformers: data
          .where((json) => (json['overall_score'] as num) >= 90)
          .take(10)
          .map((json) => CompliancePerformer.fromJson(json))
          .toList(),
    );
  }
}

class ComplianceRanking {
  final String id;
  final String name;
  final double overallScore;
  final double financialScore;
  final double timelineScore;
  final double qualityScore;
  final List<String> badges;

  ComplianceRanking({
    required this.id,
    required this.name,
    required this.overallScore,
    required this.financialScore,
    required this.timelineScore,
    required this.qualityScore,
    required this.badges,
  });

  factory ComplianceRanking.fromJson(Map<String, dynamic> json) {
    return ComplianceRanking(
      id: json['id'] as String,
      name: json['name'] as String,
      overallScore: (json['overall_score'] as num).toDouble(),
      financialScore: (json['financial_score'] as num).toDouble(),
      timelineScore: (json['timeline_score'] as num).toDouble(),
      qualityScore: (json['quality_score'] as num).toDouble(),
      badges: (json['badges'] as List).cast<String>(),
    );
  }
}

class CompliancePerformer {
  final String id;
  final String name;
  final double score;

  CompliancePerformer({
    required this.id,
    required this.name,
    required this.score,
  });

  factory CompliancePerformer.fromJson(Map<String, dynamic> json) {
    return CompliancePerformer(
      id: json['id'] as String,
      name: json['name'] as String,
      score: (json['overall_score'] as num).toDouble(),
    );
  }
}

class StateData {
  final LatLng stateCenter;
  final List<DistrictPerformance> districts;
  final List<AgencyModel> agencies;

  StateData({
    required this.stateCenter,
    required this.districts,
    required this.agencies,
  });

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      stateCenter: LatLng(
        json['state_center']['latitude'] as double,
        json['state_center']['longitude'] as double,
      ),
      districts: (json['districts'] as List)
          .map((d) => DistrictPerformance.fromJson(d))
          .toList(),
      agencies: (json['agencies'] as List)
          .map((a) => AgencyModel.fromJson(a))
          .toList(),
    );
  }
}

class DistrictPerformance {
  final String districtId;
  final String districtName;
  final List<LatLng> boundaryPoints;
  final double performanceScore;

  DistrictPerformance({
    required this.districtId,
    required this.districtName,
    required this.boundaryPoints,
    required this.performanceScore,
  });

  factory DistrictPerformance.fromJson(Map<String, dynamic> json) {
    return DistrictPerformance(
      districtId: json['district_id'] as String,
      districtName: json['district_name'] as String,
      boundaryPoints: (json['boundary']['coordinates'][0] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList(),
      performanceScore: (json['performance_score'] as num).toDouble(),
    );
  }
}

class OptimizationData {
  final List<AgencyCapacity> agencies;
  final List<OptimizationSuggestion> suggestions;

  OptimizationData({
    required this.agencies,
    required this.suggestions,
  });

  factory OptimizationData.fromJson(Map<String, dynamic> json) {
    return OptimizationData(
      agencies: (json['agencies'] as List)
          .map((a) => AgencyCapacity.fromJson(a))
          .toList(),
      suggestions: (json['suggestions'] as List)
          .map((s) => OptimizationSuggestion.fromJson(s))
          .toList(),
    );
  }
}

class AgencyCapacity {
  final String id;
  final String name;
  final double currentCapacity;
  final double optimalCapacity;

  AgencyCapacity({
    required this.id,
    required this.name,
    required this.currentCapacity,
    required this.optimalCapacity,
  });

  factory AgencyCapacity.fromJson(Map<String, dynamic> json) {
    return AgencyCapacity(
      id: json['id'] as String,
      name: json['name'] as String,
      currentCapacity: (json['current_capacity'] as num).toDouble(),
      optimalCapacity: (json['optimal_capacity'] as num).toDouble(),
    );
  }
}

class OptimizationSuggestion {
  final String description;
  final double impactScore;

  OptimizationSuggestion({
    required this.description,
    required this.impactScore,
  });

  factory OptimizationSuggestion.fromJson(Map<String, dynamic> json) {
    return OptimizationSuggestion(
      description: json['description'] as String,
      impactScore: (json['impact_score'] as num).toDouble(),
    );
  }
}

class TimelineData {
  final List<MilestoneTimeline> timelineData;
  final List<Dependency> dependencies;
  final List<String> resourceConflicts;
  final List<String> criticalPath;

  TimelineData({
    required this.timelineData,
    required this.dependencies,
    required this.resourceConflicts,
    required this.criticalPath,
  });

  factory TimelineData.fromList(List<Map<String, dynamic>> data) {
    // This would be implemented based on actual database structure
    return TimelineData(
      timelineData: [],
      dependencies: [],
      resourceConflicts: [],
      criticalPath: [],
    );
  }
}

class MilestoneTimeline {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  MilestoneTimeline({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });
}

class Dependency {
  final String fromTaskId;
  final String toTaskId;

  Dependency({
    required this.fromTaskId,
    required this.toTaskId,
  });
}

class AgencyRequest {
  final String id;
  final String agencyId;
  final String requestType;
  final String description;
  final DateTime createdAt;
  final int priority;

  AgencyRequest({
    required this.id,
    required this.agencyId,
    required this.requestType,
    required this.description,
    required this.createdAt,
    required this.priority,
  });

  factory AgencyRequest.fromJson(Map<String, dynamic> json) {
    return AgencyRequest(
      id: json['id'] as String,
      agencyId: json['agency_id'] as String,
      requestType: json['request_type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      priority: json['priority'] as int,
    );
  }
}

class ProjectLocationData {
  final LatLng currentLocation;
  final bool isWithinBoundary;
  final double accuracy;
  final DateTime lastUpdate;
  final LatLng projectCenter;
  final List<LatLng> projectBoundary;

  ProjectLocationData({
    required this.currentLocation,
    required this.isWithinBoundary,
    required this.accuracy,
    required this.lastUpdate,
    required this.projectCenter,
    required this.projectBoundary,
  });

  factory ProjectLocationData.fromJson(Map<String, dynamic> json) {
    return ProjectLocationData(
      currentLocation: LatLng(
        json['current_latitude'] as double,
        json['current_longitude'] as double,
      ),
      isWithinBoundary: json['is_within_boundary'] as bool,
      accuracy: (json['accuracy'] as num).toDouble(),
      lastUpdate: DateTime.parse(json['last_update'] as String),
      projectCenter: LatLng(
        json['project_center']['latitude'] as double,
        json['project_center']['longitude'] as double,
      ),
      projectBoundary: (json['project_boundary']['coordinates'][0] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList(),
    );
  }

  factory ProjectLocationData.empty() {
    return ProjectLocationData(
      currentLocation: const LatLng(0, 0),
      isWithinBoundary: false,
      accuracy: 0,
      lastUpdate: DateTime.now(),
      projectCenter: const LatLng(0, 0),
      projectBoundary: [],
    );
  }
}

class MilestoneData {
  final List<MilestoneInfo> milestones;
  final MilestoneInfo? currentMilestone;

  MilestoneData({
    required this.milestones,
    this.currentMilestone,
  });

  factory MilestoneData.fromList(List<Map<String, dynamic>> data) {
    final milestones = data.map((json) => MilestoneInfo.fromJson(json)).toList();
    final current = milestones.firstWhere(
      (m) => m.status == 'in_progress',
      orElse: () => milestones.first,
    );
    return MilestoneData(
      milestones: milestones,
      currentMilestone: current,
    );
  }
}

class MilestoneInfo {
  final String id;
  final String name;
  final int sequence;
  final String status;

  MilestoneInfo({
    required this.id,
    required this.name,
    required this.sequence,
    required this.status,
  });

  factory MilestoneInfo.fromJson(Map<String, dynamic> json) {
    return MilestoneInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      sequence: json['sequence'] as int,
      status: json['status'] as String,
    );
  }
}

class ResourceMapData {
  final List<Resource> resources;

  ResourceMapData({required this.resources});

  factory ResourceMapData.fromJson(Map<String, dynamic> json) {
    return ResourceMapData(
      resources: (json['resources'] as List)
          .map((r) => Resource.fromJson(r))
          .toList(),
    );
  }
}

class Resource {
  final String id;
  final String name;
  final String type;
  final LatLng location;
  final bool available;

  Resource({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.available,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      available: json['available'] as bool,
    );
  }
}

class CollaborationData {
  final List<Participant> participants;
  final List<User> onlineUsers;
  final List<Document> sharedDocuments;
  final List<Task> sharedTasks;
  final List<Resource> sharedResources;
  final List<Message> messages;
  final List<Activity> recentActivities;

  CollaborationData({
    required this.participants,
    required this.onlineUsers,
    required this.sharedDocuments,
    required this.sharedTasks,
    required this.sharedResources,
    required this.messages,
    required this.recentActivities,
  });

  factory CollaborationData.fromJson(Map<String, dynamic> json) {
    return CollaborationData(
      participants: [],
      onlineUsers: [],
      sharedDocuments: [],
      sharedTasks: [],
      sharedResources: [],
      messages: [],
      recentActivities: [],
    );
  }

  factory CollaborationData.empty() {
    return CollaborationData(
      participants: [],
      onlineUsers: [],
      sharedDocuments: [],
      sharedTasks: [],
      sharedResources: [],
      messages: [],
      recentActivities: [],
    );
  }
}

class Participant {
  final String id;
  final String name;

  Participant({required this.id, required this.name});
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

class Document {
  final String id;
  final String title;

  Document({required this.id, required this.title});
}

class Task {
  final String id;
  final String description;

  Task({required this.id, required this.description});
}

class Message {
  final String id;
  final String content;

  Message({required this.id, required this.content});
}

class Activity {
  final String id;
  final String description;

  Activity({required this.id, required this.description});
}

class PerformanceData {
  final double overallScore;
  final double previousScore;
  final int stateRanking;
  final int totalAgencies;
  final List<PerformanceHistory> performanceHistory;
  final Map<String, double> agencyMetrics;
  final Map<String, double> peerAverages;
  final List<Badge> earnedBadges;
  final List<Badge> availableBadges;
  final List<Recommendation> recommendations;
  final List<SkillGap> skillGaps;

  PerformanceData({
    required this.overallScore,
    required this.previousScore,
    required this.stateRanking,
    required this.totalAgencies,
    required this.performanceHistory,
    required this.agencyMetrics,
    required this.peerAverages,
    required this.earnedBadges,
    required this.availableBadges,
    required this.recommendations,
    required this.skillGaps,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      overallScore: (json['overall_score'] as num).toDouble(),
      previousScore: (json['previous_score'] as num).toDouble(),
      stateRanking: json['state_ranking'] as int,
      totalAgencies: json['total_agencies'] as int,
      performanceHistory: [],
      agencyMetrics: {},
      peerAverages: {},
      earnedBadges: [],
      availableBadges: [],
      recommendations: [],
      skillGaps: [],
    );
  }
}

class PerformanceHistory {
  final DateTime date;
  final double score;

  PerformanceHistory({required this.date, required this.score});
}

class Badge {
  final String id;
  final String name;
  final String icon;

  Badge({required this.id, required this.name, required this.icon});
}

class Recommendation {
  final String id;
  final String description;

  Recommendation({required this.id, required this.description});
}

class SkillGap {
  final String id;
  final String skillName;

  SkillGap({required this.id, required this.skillName});
}

class NetworkData {
  final List<StateNode> states;
  final List<Collaboration> collaborations;

  NetworkData({
    required this.states,
    required this.collaborations,
  });

  factory NetworkData.fromList(List<Map<String, dynamic>> data) {
    return NetworkData(
      states: [],
      collaborations: [],
    );
  }
}

class StateNode {
  final String id;
  final String name;
  final LatLng location;

  StateNode({
    required this.id,
    required this.name,
    required this.location,
  });
}

class Collaboration {
  final String fromStateId;
  final String toStateId;
  final int intensity;

  Collaboration({
    required this.fromStateId,
    required this.toStateId,
    required this.intensity,
  });
}
class CollaborationZone {
  final String id;
  final String projectName;
  final String agencyName;
  final LatLng location;
  final String type;
  final String status;
  final double distance;
  final List<String> opportunities;

  CollaborationZone({
    required this.id,
    required this.projectName,
    required this.agencyName,
    required this.location,
    required this.type,
    required this.status,
    required this.distance,
    required this.opportunities,
  });

  factory CollaborationZone.fromJson(Map<String, dynamic> json) {
    return CollaborationZone(
      id: json['id'] as String,
      projectName: json['project_name'] as String,
      agencyName: json['agency_name'] as String,
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      type: json['type'] as String,
      status: json['status'] as String,
      distance: (json['distance'] as num).toDouble(),
      opportunities: (json['opportunities'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}