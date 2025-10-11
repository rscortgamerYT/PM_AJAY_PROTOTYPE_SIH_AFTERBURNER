import 'dart:math';
import '../models/project_intelligence_models.dart';

class MockProjectIntelligenceData {
  static final Random _random = Random();
  
  static final List<String> _projectNames = [
    'Highway Construction Project',
    'School Building Initiative',
    'Water Supply Scheme',
    'Rural Electrification',
    'Hospital Modernization',
    'Bridge Construction',
    'Irrigation System Upgrade',
    'Community Center Development',
  ];
  
  static final List<String> _stakeholderNames = [
    'Rajesh Kumar',
    'Priya Sharma',
    'Amit Patel',
    'Sneha Reddy',
    'Vikram Singh',
    'Anita Desai',
    'Rahul Gupta',
    'Deepa Iyer',
  ];
  
  static final List<String> _organizations = [
    'Public Works Department',
    'State Highway Authority',
    'Municipal Corporation',
    'Rural Development Agency',
    'Construction Company A',
    'Engineering Consultants Ltd',
    'Community Welfare Trust',
    'District Administration',
  ];
  
  static final List<String> _concerns = [
    'Budget utilization delays',
    'Quality compliance issues',
    'Timeline adherence',
    'Resource availability',
    'Environmental clearances',
    'Stakeholder coordination',
    'Material procurement',
    'Weather impact on schedule',
  ];
  
  static final List<String> _roles = [
    'Project Director',
    'Chief Engineer',
    'Financial Controller',
    'Quality Inspector',
    'Site Supervisor',
    'Procurement Officer',
    'Environmental Officer',
    'Community Liaison',
  ];

  static ProjectIntelligence generateMockProjectIntelligence(String projectId) {
    return ProjectIntelligence(
      scorecard: _generateScorecard(projectId),
      stakeholders: _generateStakeholders(15),
      healthMetrics: _generateHealthMetrics(projectId),
      predictiveAnalytics: _generatePredictiveAnalytics(projectId),
      recentEvents: _generateRecentEvents(10),
      keyPerformanceIndicators: _generateKPIs(),
    );
  }

  static ProjectScorecard _generateScorecard(String projectId) {
    final projectName = _projectNames[_random.nextInt(_projectNames.length)];
    final financialHealth = 60.0 + _random.nextDouble() * 40;
    final timelineAdherence = 50.0 + _random.nextDouble() * 50;
    final qualityCompliance = 70.0 + _random.nextDouble() * 30;
    final stakeholderSatisfaction = 60.0 + _random.nextDouble() * 40;
    final riskManagement = 65.0 + _random.nextDouble() * 35;
    final resourceUtilization = 55.0 + _random.nextDouble() * 45;
    
    final overallScore = (financialHealth + timelineAdherence + qualityCompliance + 
                          stakeholderSatisfaction + riskManagement + resourceUtilization) / 6;
    
    final overallHealth = _determineHealth(overallScore);
    
    return ProjectScorecard(
      projectId: projectId,
      projectName: projectName,
      overallHealth: overallHealth,
      overallScore: overallScore,
      financialHealth: financialHealth,
      timelineAdherence: timelineAdherence,
      qualityCompliance: qualityCompliance,
      stakeholderSatisfaction: stakeholderSatisfaction,
      riskManagement: riskManagement,
      resourceUtilization: resourceUtilization,
      budgetUtilization: 0.6 + _random.nextDouble() * 0.35,
      scheduleVariance: -20.0 + _random.nextDouble() * 40,
      qualityIssues: _random.nextInt(15),
      openRisks: _random.nextInt(20),
      stakeholderCount: 12 + _random.nextInt(20),
      financialTrend: -5.0 + _random.nextDouble() * 10,
      timelineTrend: -5.0 + _random.nextDouble() * 10,
      qualityTrend: -5.0 + _random.nextDouble() * 10,
      lastUpdated: DateTime.now(),
    );
  }
  
  static ProjectHealth _determineHealth(double score) {
    if (score >= 85) return ProjectHealth.excellent;
    if (score >= 70) return ProjectHealth.good;
    if (score >= 50) return ProjectHealth.warning;
    return ProjectHealth.critical;
  }

  static List<Stakeholder> _generateStakeholders(int count) {
    final stakeholders = <Stakeholder>[];
    
    for (int i = 0; i < count; i++) {
      stakeholders.add(Stakeholder(
        id: 'SH${(i + 1).toString().padLeft(4, '0')}',
        name: _stakeholderNames[_random.nextInt(_stakeholderNames.length)],
        role: _roles[_random.nextInt(_roles.length)],
        organization: _organizations[_random.nextInt(_organizations.length)],
        type: StakeholderType.values[_random.nextInt(StakeholderType.values.length)],
        influenceScore: 0.3 + _random.nextDouble() * 0.7,
        engagementLevel: 0.4 + _random.nextDouble() * 0.6,
        connectedStakeholders: _generateConnectedStakeholders(i, count),
        concerns: _generateConcerns(),
        lastInteraction: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ));
    }
    
    return stakeholders;
  }
  
  static List<String> _generateConnectedStakeholders(int current, int total) {
    final numConnections = _random.nextInt(5) + 1;
    final connections = <String>[];
    
    for (int i = 0; i < numConnections; i++) {
      int connectedIndex = _random.nextInt(total);
      if (connectedIndex != current) {
        connections.add('SH${(connectedIndex + 1).toString().padLeft(4, '0')}');
      }
    }
    
    return connections;
  }
  
  static List<String> _generateConcerns() {
    final numConcerns = _random.nextInt(3) + 1;
    final concerns = <String>[];
    
    for (int i = 0; i < numConcerns; i++) {
      final concern = _concerns[_random.nextInt(_concerns.length)];
      if (!concerns.contains(concern)) {
        concerns.add(concern);
      }
    }
    
    return concerns;
  }

  static ProjectHealthMetrics _generateHealthMetrics(String projectId) {
    return ProjectHealthMetrics(
      projectId: projectId,
      timestamp: DateTime.now(),
      cashFlowRate: 50000 + _random.nextDouble() * 100000,
      completionVelocity: 0.5 + _random.nextDouble() * 2.0,
      activeIssues: _random.nextInt(20),
      criticalAlerts: _random.nextInt(5),
      completionProbability: 0.6 + _random.nextDouble() * 0.35,
      predictedCompletion: DateTime.now().add(Duration(days: 90 + _random.nextInt(180))),
      budgetOverrunRisk: _random.nextDouble() * 0.4,
      upcomingMilestones: _generateMilestones(),
      recentTransactions: _random.nextInt(50) + 10,
      recentInspections: _random.nextInt(15) + 2,
      recentApprovals: _random.nextInt(10) + 1,
    );
  }
  
  static List<String> _generateMilestones() {
    final milestones = [
      'Foundation Completion',
      'Structural Framework',
      'MEP Installation',
      'Interior Finishing',
      'Final Inspection',
    ];
    
    final numMilestones = _random.nextInt(3) + 1;
    return milestones.take(numMilestones).toList();
  }

  static PredictiveAnalytics _generatePredictiveAnalytics(String projectId) {
    return PredictiveAnalytics(
      projectId: projectId,
      estimatedCompletion: DateTime.now().add(Duration(days: 120 + _random.nextInt(150))),
      confidenceLevel: 0.7 + _random.nextDouble() * 0.25,
      delayRisks: _generateDelayRisks(),
      projectedFinalCost: 50000000 + _random.nextDouble() * 50000000,
      costOverrunProbability: _random.nextDouble() * 0.35,
      costRisks: _generateCostRisks(),
      qualityComplianceForecast: 0.75 + _random.nextDouble() * 0.2,
      qualityRisks: _generateQualityRisks(),
      recommendations: _generateRecommendations(),
    );
  }
  
  static List<DelayRisk> _generateDelayRisks() {
    return [
      DelayRisk(
        factor: 'Weather Conditions',
        impactDays: 5 + _random.nextDouble() * 15,
        probability: 0.3 + _random.nextDouble() * 0.4,
        mitigation: 'Accelerate indoor work during monsoon season',
      ),
      DelayRisk(
        factor: 'Material Shortage',
        impactDays: 10 + _random.nextDouble() * 20,
        probability: 0.2 + _random.nextDouble() * 0.3,
        mitigation: 'Establish alternative supplier agreements',
      ),
      DelayRisk(
        factor: 'Labor Availability',
        impactDays: 7 + _random.nextDouble() * 14,
        probability: 0.15 + _random.nextDouble() * 0.25,
        mitigation: 'Maintain backup workforce arrangements',
      ),
    ];
  }
  
  static List<CostRisk> _generateCostRisks() {
    return [
      CostRisk(
        factor: 'Material Price Escalation',
        impactAmount: 2000000 + _random.nextDouble() * 5000000,
        probability: 0.4 + _random.nextDouble() * 0.3,
        mitigation: 'Lock in prices with long-term contracts',
      ),
      CostRisk(
        factor: 'Design Changes',
        impactAmount: 1000000 + _random.nextDouble() * 3000000,
        probability: 0.25 + _random.nextDouble() * 0.25,
        mitigation: 'Implement strict change control process',
      ),
      CostRisk(
        factor: 'Regulatory Compliance',
        impactAmount: 500000 + _random.nextDouble() * 2000000,
        probability: 0.2 + _random.nextDouble() * 0.2,
        mitigation: 'Regular compliance audits and early consultation',
      ),
    ];
  }
  
  static List<QualityRisk> _generateQualityRisks() {
    return [
      QualityRisk(
        factor: 'Substandard Materials',
        impact: 'Structural integrity compromise',
        probability: 0.15 + _random.nextDouble() * 0.2,
        mitigation: 'Implement rigorous material testing protocol',
      ),
      QualityRisk(
        factor: 'Workmanship Issues',
        impact: 'Rework and delays',
        probability: 0.2 + _random.nextDouble() * 0.25,
        mitigation: 'Enhanced supervision and skill training',
      ),
      QualityRisk(
        factor: 'Design Flaws',
        impact: 'Functional deficiencies',
        probability: 0.1 + _random.nextDouble() * 0.15,
        mitigation: 'Third-party design review and validation',
      ),
    ];
  }
  
  static List<ActionableInsight> _generateRecommendations() {
    final priorities = [
      InsightPriority.critical,
      InsightPriority.high,
      InsightPriority.medium,
      InsightPriority.low,
    ];
    
    return [
      ActionableInsight(
        title: 'Accelerate Material Procurement',
        description: 'Current procurement pace may lead to delays in Q3 milestones',
        priority: priorities[_random.nextInt(2)],
        actions: [
          'Expedite pending purchase orders',
          'Activate alternate suppliers',
          'Review inventory buffer levels',
        ],
        potentialImpact: 0.15 + _random.nextDouble() * 0.25,
      ),
      ActionableInsight(
        title: 'Enhance Quality Monitoring',
        description: 'Recent inspections show increasing deviation from standards',
        priority: priorities[_random.nextInt(3)],
        actions: [
          'Increase inspection frequency',
          'Provide additional training to contractors',
          'Implement real-time quality dashboards',
        ],
        potentialImpact: 0.1 + _random.nextDouble() * 0.2,
      ),
      ActionableInsight(
        title: 'Optimize Cash Flow',
        description: 'Budget utilization lagging behind schedule progress',
        priority: priorities[_random.nextInt(priorities.length)],
        actions: [
          'Review pending payment approvals',
          'Streamline disbursement process',
          'Align payment schedules with milestones',
        ],
        potentialImpact: 0.08 + _random.nextDouble() * 0.15,
      ),
    ];
  }

  static List<String> _generateRecentEvents(int count) {
    final events = [
      'Foundation work completed ahead of schedule',
      'Quality inspection passed with minor observations',
      'Budget review meeting conducted with stakeholders',
      'New environmental clearance received',
      'Contractor mobilized additional resources',
      'Material delivery delayed due to logistics',
      'Safety audit completed successfully',
      'Design modification approved by committee',
      'Payment milestone achieved',
      'Community consultation held',
    ];
    
    return events.take(count).toList();
  }

  static Map<String, double> _generateKPIs() {
    return {
      'Cost Performance Index': 0.85 + _random.nextDouble() * 0.3,
      'Schedule Performance Index': 0.80 + _random.nextDouble() * 0.35,
      'Quality Index': 0.75 + _random.nextDouble() * 0.2,
      'Safety Index': 0.85 + _random.nextDouble() * 0.15,
      'Stakeholder Satisfaction': 0.70 + _random.nextDouble() * 0.25,
      'Resource Efficiency': 0.75 + _random.nextDouble() * 0.2,
    };
  }
}