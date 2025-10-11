import 'package:latlong2/latlong.dart';
import 'dashboard_analytics_service.dart';

/// Mock data service to provide fallback data when backend is unavailable
class MockDashboardDataService {
  
  /// Get mock state metrics for national heatmap
  static List<StateMetrics> getMockStateMetrics() {
    return [
      StateMetrics(
        stateId: 'state-1',
        stateName: 'Delhi',
        centerLocation: const LatLng(28.7041, 77.1025),
        performanceScore: 85.5,
        totalProjects: 45,
        completedProjects: 32,
        fundUtilization: 78.2,
      ),
      StateMetrics(
        stateId: 'state-2',
        stateName: 'Maharashtra',
        centerLocation: const LatLng(19.7515, 75.7139),
        performanceScore: 92.3,
        totalProjects: 78,
        completedProjects: 65,
        fundUtilization: 88.5,
      ),
      StateMetrics(
        stateId: 'state-3',
        stateName: 'Karnataka',
        centerLocation: const LatLng(15.3173, 75.7139),
        performanceScore: 88.7,
        totalProjects: 62,
        completedProjects: 54,
        fundUtilization: 82.4,
      ),
      StateMetrics(
        stateId: 'state-4',
        stateName: 'Tamil Nadu',
        centerLocation: const LatLng(11.1271, 78.6569),
        performanceScore: 79.2,
        totalProjects: 56,
        completedProjects: 41,
        fundUtilization: 75.8,
      ),
      StateMetrics(
        stateId: 'state-5',
        stateName: 'Uttar Pradesh',
        centerLocation: const LatLng(26.8467, 80.9462),
        performanceScore: 72.5,
        totalProjects: 89,
        completedProjects: 58,
        fundUtilization: 68.3,
      ),
    ];
  }

  /// Get mock compliance data
  static ComplianceData getMockComplianceData() {
    final rankings = [
      ComplianceRanking(
        id: 'state-2',
        name: 'Maharashtra',
        overallScore: 95.2,
        financialScore: 96.5,
        timelineScore: 93.8,
        qualityScore: 95.3,
        badges: ['100_compliance', 'early_completion', 'quality_excellence'],
      ),
      ComplianceRanking(
        id: 'state-3',
        name: 'Karnataka',
        overallScore: 91.8,
        financialScore: 92.3,
        timelineScore: 90.5,
        qualityScore: 92.6,
        badges: ['best_practices', 'innovation_leader'],
      ),
      ComplianceRanking(
        id: 'state-1',
        name: 'Delhi',
        overallScore: 88.5,
        financialScore: 89.2,
        timelineScore: 87.3,
        qualityScore: 89.0,
        badges: ['quality_excellence'],
      ),
      ComplianceRanking(
        id: 'state-4',
        name: 'Tamil Nadu',
        overallScore: 85.3,
        financialScore: 86.8,
        timelineScore: 83.5,
        qualityScore: 85.6,
        badges: [],
      ),
      ComplianceRanking(
        id: 'state-5',
        name: 'Uttar Pradesh',
        overallScore: 78.2,
        financialScore: 79.5,
        timelineScore: 76.8,
        qualityScore: 78.3,
        badges: [],
      ),
    ];

    final topPerformers = rankings
        .where((r) => r.overallScore >= 90)
        .map((r) => CompliancePerformer(
              id: r.id,
              name: r.name,
              score: r.overallScore,
            ))
        .toList();

    return ComplianceData(
      rankings: rankings,
      topPerformers: topPerformers,
    );
  }

  /// Get mock network data for collaboration network
  static NetworkData getMockNetworkData() {
    final states = [
      StateNode(
        id: 'state-1',
        name: 'Delhi',
        location: const LatLng(28.7041, 77.1025),
      ),
      StateNode(
        id: 'state-2',
        name: 'Maharashtra',
        location: const LatLng(19.7515, 75.7139),
      ),
      StateNode(
        id: 'state-3',
        name: 'Karnataka',
        location: const LatLng(15.3173, 75.7139),
      ),
      StateNode(
        id: 'state-4',
        name: 'Tamil Nadu',
        location: const LatLng(11.1271, 78.6569),
      ),
      StateNode(
        id: 'state-5',
        name: 'Uttar Pradesh',
        location: const LatLng(26.8467, 80.9462),
      ),
    ];

    final collaborations = [
      Collaboration(fromStateId: 'state-1', toStateId: 'state-2', intensity: 12),
      Collaboration(fromStateId: 'state-1', toStateId: 'state-5', intensity: 8),
      Collaboration(fromStateId: 'state-2', toStateId: 'state-3', intensity: 15),
      Collaboration(fromStateId: 'state-2', toStateId: 'state-4', intensity: 10),
      Collaboration(fromStateId: 'state-3', toStateId: 'state-4', intensity: 11),
      Collaboration(fromStateId: 'state-3', toStateId: 'state-5', intensity: 6),
      Collaboration(fromStateId: 'state-4', toStateId: 'state-5', intensity: 7),
    ];

    return NetworkData(
      states: states,
      collaborations: collaborations,
    );
  }

  /// Get mock performance data for agency analytics
  static PerformanceData getMockPerformanceData(String agencyId) {
    return PerformanceData(
      overallScore: 87.5,
      previousScore: 82.3,
      stateRanking: 3,
      totalAgencies: 15,
      performanceHistory: _getMockPerformanceHistory(),
      agencyMetrics: {
        'project_completion': 85.2,
        'fund_utilization': 88.5,
        'timeline_adherence': 82.8,
        'quality_score': 90.3,
        'stakeholder_satisfaction': 86.7,
      },
      peerAverages: {
        'project_completion': 78.5,
        'fund_utilization': 82.1,
        'timeline_adherence': 75.3,
        'quality_score': 83.2,
        'stakeholder_satisfaction': 80.5,
      },
      earnedBadges: [
        Badge(id: 'badge-1', name: 'Quality', icon: '🏆'),
        Badge(id: 'badge-2', name: 'Efficiency', icon: '⚡'),
        Badge(id: 'badge-3', name: 'Innovation', icon: '💡'),
      ],
      availableBadges: [
        Badge(id: 'badge-1', name: 'Quality', icon: '🏆'),
        Badge(id: 'badge-2', name: 'Efficiency', icon: '⚡'),
        Badge(id: 'badge-3', name: 'Innovation', icon: '💡'),
        Badge(id: 'badge-4', name: 'Speed', icon: '🚀'),
        Badge(id: 'badge-5', name: 'Excellence', icon: '⭐'),
      ],
      recommendations: [
        Recommendation(
          id: 'rec-1',
          description: 'Focus on improving timeline adherence by 5% to reach top tier',
        ),
        Recommendation(
          id: 'rec-2',
          description: 'Consider resource sharing with neighboring agencies',
        ),
        Recommendation(
          id: 'rec-3',
          description: 'Implement best practices from Maharashtra for fund utilization',
        ),
      ],
      skillGaps: [
        SkillGap(id: 'gap-1', skillName: 'Advanced project management'),
        SkillGap(id: 'gap-2', skillName: 'Digital documentation'),
      ],
    );
  }

  static List<PerformanceHistory> _getMockPerformanceHistory() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - (11 - index), 1);
      const baseScore = 75.0;
      final trend = index * 1.5;
      final noise = (index % 3) * 2.5;
      return PerformanceHistory(
        date: date,
        score: baseScore + trend + noise,
      );
    });
  }

  /// Get mock fund flow data
  static FundFlowData getMockFundFlowData() {
    return FundFlowData(
      centreAllocation: 1000.0,
      stateReceived: 950.0,
      agencyDisbursed: 880.0,
      projectUtilized: 820.0,
      stages: [
        FundFlowStage(
          name: 'Centre Allocation',
          amount: 1000.0,
          timestamp: DateTime.now().subtract(const Duration(days: 90)),
          isBottleneck: false,
        ),
        FundFlowStage(
          name: 'State Receipt',
          amount: 950.0,
          timestamp: DateTime.now().subtract(const Duration(days: 75)),
          isBottleneck: false,
        ),
        FundFlowStage(
          name: 'Agency Disbursement',
          amount: 880.0,
          timestamp: DateTime.now().subtract(const Duration(days: 45)),
          isBottleneck: true,
        ),
        FundFlowStage(
          name: 'Project Utilization',
          amount: 820.0,
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          isBottleneck: false,
        ),
      ],
    );
  }
}