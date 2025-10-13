import '../models/agency_model.dart';
import '../models/project_model.dart';
import '../models/project_task_model.dart';
import 'spatial_query_service.dart';

class AgencyRecommendation {
  final AgencyModel agency;
  final double matchScore;
  final Map<String, double> criteria;
  final List<String> strengths;
  final List<String> considerations;

  AgencyRecommendation({
    required this.agency,
    required this.matchScore,
    required this.criteria,
    required this.strengths,
    required this.considerations,
  });
}

class AgencyRecommendationService {
  final SpatialQueryService _spatialQueryService = SpatialQueryService();

  /// Get AI-powered agency recommendations for a project
  Future<List<AgencyRecommendation>> getProjectRecommendations({
    required ProjectModel project,
    required List<AgencyModel> availableAgencies,
  }) async {
    final recommendations = <AgencyRecommendation>[];

    for (final agency in availableAgencies) {
      if (!agency.isActive) continue;

      final matchScore = await _calculateProjectMatchScore(project, agency);
      final criteria = await _getMatchCriteria(project, agency);
      final strengths = _getAgencyStrengths(agency, project);
      final considerations = _getAgencyConsiderations(agency, project);

      recommendations.add(AgencyRecommendation(
        agency: agency,
        matchScore: matchScore,
        criteria: criteria,
        strengths: strengths,
        considerations: considerations,
      ));
    }

    // Sort by match score (highest first)
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations;
  }

  /// Get AI-powered agency recommendations for a specific task
  Future<List<AgencyRecommendation>> getTaskRecommendations({
    required ProjectTaskModel task,
    required ProjectModel project,
    required List<AgencyModel> availableAgencies,
  }) async {
    final recommendations = <AgencyRecommendation>[];

    for (final agency in availableAgencies) {
      if (!agency.isActive) continue;

      final matchScore = await _calculateTaskMatchScore(task, project, agency);
      final criteria = await _getTaskMatchCriteria(task, project, agency);
      final strengths = _getTaskAgencyStrengths(agency, task);
      final considerations = _getTaskAgencyConsiderations(agency, task);

      recommendations.add(AgencyRecommendation(
        agency: agency,
        matchScore: matchScore,
        criteria: criteria,
        strengths: strengths,
        considerations: considerations,
      ));
    }

    // Sort by match score (highest first)
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations;
  }

  /// Calculate project match score (0-100)
  Future<double> _calculateProjectMatchScore(ProjectModel project, AgencyModel agency) async {
    double score = 0.0;

    // Geographic proximity (30% weight)
    if (project.location != null) {
      final distance = await _spatialQueryService.calculateDistance(
        from: project.location!,
        to: agency.location,
      );
      score += _getProximityScore(distance) * 0.30;
    }

    // Agency type compatibility (25% weight)
    score += _getTypeCompatibilityScore(project, agency) * 0.25;

    // Performance rating (20% weight)
    score += (agency.performanceRating / 5.0) * 100 * 0.20;

    // Capacity score (15% weight)
    score += agency.capacityScore * 0.15;

    // Coverage area overlap (10% weight)
    if (agency.coverageArea != null && project.location != null) {
      final isInCoverage = await _spatialQueryService.isPointInCoverageArea(
        agencyId: agency.id,
        point: project.location!,
      );
      score += (isInCoverage ? 100.0 : 0.0) * 0.10;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Calculate task-specific match score
  Future<double> _calculateTaskMatchScore(
    ProjectTaskModel task,
    ProjectModel project,
    AgencyModel agency,
  ) async {
    double score = 0.0;

    // Base project compatibility
    final baseScore = await _calculateProjectMatchScore(project, agency);
    score += baseScore * 0.40;

    // Task priority alignment (20% weight)
    score += _getPriorityAlignmentScore(task, agency) * 0.20;

    // Skill match (20% weight)
    score += _getSkillMatchScore(task, agency) * 0.20;

    // Workload capacity (20% weight)
    score += _getWorkloadCapacityScore(agency) * 0.20;

    return score.clamp(0.0, 100.0);
  }

  /// Get detailed match criteria for project
  Future<Map<String, double>> _getMatchCriteria(ProjectModel project, AgencyModel agency) async {
    final criteria = <String, double>{};

    if (project.location != null) {
      final distance = await _spatialQueryService.calculateDistance(
        from: project.location!,
        to: agency.location,
      );
      criteria['proximity'] = _getProximityScore(distance);
    }

    criteria['performance'] = (agency.performanceRating / 5.0) * 100;
    criteria['capacity'] = agency.capacityScore;
    criteria['type_compatibility'] = _getTypeCompatibilityScore(project, agency);

    return criteria;
  }

  /// Get detailed match criteria for task
  Future<Map<String, double>> _getTaskMatchCriteria(
    ProjectTaskModel task,
    ProjectModel project,
    AgencyModel agency,
  ) async {
    final criteria = await _getMatchCriteria(project, agency);
    criteria['skill_match'] = _getSkillMatchScore(task, agency);
    criteria['priority_alignment'] = _getPriorityAlignmentScore(task, agency);
    criteria['workload_capacity'] = _getWorkloadCapacityScore(agency);
    return criteria;
  }

  /// Calculate proximity score based on distance
  double _getProximityScore(double distanceInMeters) {
    if (distanceInMeters <= 10000) return 100.0; // Within 10km
    if (distanceInMeters <= 25000) return 80.0;  // Within 25km
    if (distanceInMeters <= 50000) return 60.0;  // Within 50km
    if (distanceInMeters <= 100000) return 40.0; // Within 100km
    return 20.0; // Beyond 100km
  }

  /// Calculate type compatibility score
  double _getTypeCompatibilityScore(ProjectModel project, AgencyModel agency) {
    switch (agency.type) {
      case AgencyType.implementingAgency:
        return project.component == ProjectComponent.adarshGram ? 100.0 : 80.0;
      case AgencyType.technicalAgency:
        return project.component == ProjectComponent.admin ? 100.0 : 70.0;
      case AgencyType.nodalAgency:
        return 90.0; // Good for coordination
      case AgencyType.monitoringAgency:
        return 60.0; // Can assist but not primary
    }
  }

  /// Calculate skill match score for task
  double _getSkillMatchScore(ProjectTaskModel task, AgencyModel agency) {
    if (task.requiredSkills.isEmpty) return 80.0; // Default if no specific skills

    // Mock skill matching - in real implementation, this would check agency capabilities
    final agencySkills = _getAgencySkills(agency);
    final matchedSkills = task.requiredSkills.where(agencySkills.contains).toList();
    
    return (matchedSkills.length / task.requiredSkills.length * 100).clamp(0.0, 100.0);
  }

  /// Get mock agency skills based on type and metadata
  List<String> _getAgencySkills(AgencyModel agency) {
    switch (agency.type) {
      case AgencyType.implementingAgency:
        return ['construction', 'project_management', 'community_engagement'];
      case AgencyType.technicalAgency:
        return ['technical_design', 'engineering', 'quality_assurance'];
      case AgencyType.nodalAgency:
        return ['coordination', 'stakeholder_management', 'compliance'];
      case AgencyType.monitoringAgency:
        return ['monitoring', 'evaluation', 'reporting'];
    }
  }

  /// Calculate priority alignment score
  double _getPriorityAlignmentScore(ProjectTaskModel task, AgencyModel agency) {
    // Mock implementation - would check agency's current workload priorities
    switch (task.priority) {
      case TaskPriority.critical:
        return agency.performanceRating >= 4.0 ? 100.0 : 70.0;
      case TaskPriority.high:
        return agency.performanceRating >= 3.5 ? 90.0 : 80.0;
      case TaskPriority.medium:
        return 85.0;
      case TaskPriority.low:
        return 80.0;
    }
  }

  /// Calculate workload capacity score
  double _getWorkloadCapacityScore(AgencyModel agency) {
    // Mock implementation - would check current assignments
    return agency.capacityScore;
  }

  /// Get agency strengths for project
  List<String> _getAgencyStrengths(AgencyModel agency, ProjectModel project) {
    final strengths = <String>[];

    if (agency.performanceRating >= 4.5) {
      strengths.add('Excellent track record');
    }

    if (agency.capacityScore >= 80) {
      strengths.add('High capacity available');
    }

    switch (agency.type) {
      case AgencyType.implementingAgency:
        strengths.add('Specialized in implementation');
        break;
      case AgencyType.technicalAgency:
        strengths.add('Technical expertise');
        break;
      case AgencyType.nodalAgency:
        strengths.add('Strong coordination skills');
        break;
      case AgencyType.monitoringAgency:
        strengths.add('Quality monitoring');
        break;
    }

    return strengths;
  }

  /// Get agency considerations for project
  List<String> _getAgencyConsiderations(AgencyModel agency, ProjectModel project) {
    final considerations = <String>[];

    if (agency.performanceRating < 3.0) {
      considerations.add('Below average performance rating');
    }

    if (agency.capacityScore < 50) {
      considerations.add('Limited capacity available');
    }

    if (project.location != null) {
      // Would calculate actual distance in real implementation
      considerations.add('Distance from project site');
    }

    return considerations;
  }

  /// Get task-specific agency strengths
  List<String> _getTaskAgencyStrengths(AgencyModel agency, ProjectTaskModel task) {
    final strengths = <String>[];
    final agencySkills = _getAgencySkills(agency);
    
    final matchedSkills = task.requiredSkills.where(agencySkills.contains).toList();
    if (matchedSkills.isNotEmpty) {
      strengths.add('Has required skills: ${matchedSkills.join(', ')}');
    }

    if (task.priority == TaskPriority.critical && agency.performanceRating >= 4.0) {
      strengths.add('Suitable for critical tasks');
    }

    return strengths;
  }

  /// Get task-specific agency considerations
  List<String> _getTaskAgencyConsiderations(AgencyModel agency, ProjectTaskModel task) {
    final considerations = <String>[];
    
    final agencySkills = _getAgencySkills(agency);
    final missingSkills = task.requiredSkills.where((skill) => !agencySkills.contains(skill)).toList();
    
    if (missingSkills.isNotEmpty) {
      considerations.add('Missing skills: ${missingSkills.join(', ')}');
    }

    if (task.priority == TaskPriority.critical && agency.performanceRating < 4.0) {
      considerations.add('May need additional support for critical task');
    }

    return considerations;
  }
}