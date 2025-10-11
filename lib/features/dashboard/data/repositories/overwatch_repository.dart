import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/overwatch_project_model.dart';
import '../../models/overwatch_fund_flow_model.dart';

/// Repository for Overwatch dashboard data with Supabase integration
class OverwatchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all projects from Supabase
  Future<List<OverwatchProject>> fetchProjects({
    OverwatchProjectStatus? status,
    RiskLevel? riskLevel,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.from('overwatch_projects').select();

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (riskLevel != null) {
        final minScore = _getRiskScoreRange(riskLevel);
        query = query.gte('risk_score', minScore.$1).lte('risk_score', minScore.$2);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,agency.ilike.%$searchQuery%,state.ilike.%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => OverwatchProject.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Fetch a single project by ID
  Future<OverwatchProject?> fetchProjectById(String projectId) async {
    try {
      final response = await _supabase
          .from('overwatch_projects')
          .select()
          .eq('id', projectId)
          .single();

      return OverwatchProject.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Fetch fund flow data for a project
  Future<CompleteFundFlowData?> fetchFundFlowForProject(String projectId) async {
    try {
      final response = await _supabase
          .from('overwatch_fund_flows')
          .select()
          .eq('project_id', projectId)
          .order('level', ascending: true);

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      // Build hierarchical structure from flat data
      return _buildFundFlowHierarchy(response as List);
    } catch (e) {
      throw Exception('Failed to fetch fund flow: $e');
    }
  }

  /// Fetch complete fund flow hierarchy
  Future<CompleteFundFlowData> fetchCompleteFundFlow() async {
    try {
      final response = await _supabase
          .from('overwatch_fund_flows')
          .select()
          .order('level', ascending: true);

      return _buildFundFlowHierarchy(response as List);
    } catch (e) {
      throw Exception('Failed to fetch fund flow: $e');
    }
  }

  /// Update project status
  Future<void> updateProjectStatus(
    String projectId,
    OverwatchProjectStatus status,
  ) async {
    try {
      await _supabase
          .from('overwatch_projects')
          .update({'status': status.name})
          .eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to update project status: $e');
    }
  }

  /// Add flag to project
  Future<void> addProjectFlag(String projectId, String flagReason) async {
    try {
      await _supabase.from('overwatch_project_flags').insert({
        'project_id': projectId,
        'reason': flagReason,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add project flag: $e');
    }
  }

  /// Fetch project flags
  Future<List<Map<String, dynamic>>> fetchProjectFlags(String projectId) async {
    try {
      final response = await _supabase
          .from('overwatch_project_flags')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch project flags: $e');
    }
  }

  /// Subscribe to project updates (simplified - realtime may need additional setup)
  void subscribeToProjects(
    void Function(List<OverwatchProject>) onUpdate,
  ) {
    // Note: Supabase realtime subscriptions require proper channel setup
    // This is a placeholder for the subscription logic
    // In production, implement proper realtime channel subscription
  }

  /// Helper: Get risk score range for risk level
  (double, double) _getRiskScoreRange(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return (0.0, 4.9);
      case RiskLevel.medium:
        return (5.0, 7.9);
      case RiskLevel.high:
        return (8.0, 10.0);
    }
  }

  /// Helper: Build fund flow hierarchy from flat data
  CompleteFundFlowData _buildFundFlowHierarchy(List data) {
    final nodesList = <FundFlowNode>[];
    final linksList = <FundFlowLink>[];
    
    // Parse nodes from data
    for (final item in data) {
      final json = item as Map<String, dynamic>;
      nodesList.add(FundFlowNode.fromJson(json));
      
      // Create links based on parent-child relationships
      final parentId = json['parent_node_id'] as String?;
      if (parentId != null) {
        linksList.add(FundFlowLink(
          id: '${parentId}_${json['id']}',
          sourceNodeId: parentId,
          targetNodeId: json['id'] as String,
          value: (json['amount'] as num).toDouble(),
          status: FlowLinkStatus.completed,
          details: PFMSDetails(
            pfmsId: json['pfms_id'] as String? ?? 'N/A',
            transferDate: DateTime.now(),
            processingDays: 0,
            documents: [],
          ),
        ));
      }
    }

    return CompleteFundFlowData(
      nodes: nodesList,
      links: linksList,
      timestamp: DateTime.now(),
    );
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final projects = await fetchProjects();
      
      final totalProjects = projects.length;
      final activeProjects = projects.where((p) => p.status == OverwatchProjectStatus.active).length;
      final flaggedProjects = projects.where((p) => p.status == OverwatchProjectStatus.flagged).length;
      final highRiskProjects = projects.where((p) => p.riskLevel == RiskLevel.high).length;
      
      final totalFunds = projects.fold<double>(0, (sum, p) => sum + p.totalFunds);
      final utilizedFunds = projects.fold<double>(0, (sum, p) => sum + p.utilizedFunds);
      final utilizationPercentage = totalFunds > 0 ? (utilizedFunds / totalFunds * 100) : 0;

      return {
        'total_projects': totalProjects,
        'active_projects': activeProjects,
        'flagged_projects': flaggedProjects,
        'high_risk_projects': highRiskProjects,
        'total_funds': totalFunds,
        'utilized_funds': utilizedFunds,
        'utilization_percentage': utilizationPercentage,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}