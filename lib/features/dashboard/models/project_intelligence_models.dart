import 'package:flutter/material.dart';

/// Project health status
enum ProjectHealth {
  excellent,
  good,
  warning,
  critical,
}

extension ProjectHealthExtension on ProjectHealth {
  String get label {
    switch (this) {
      case ProjectHealth.excellent:
        return 'Excellent';
      case ProjectHealth.good:
        return 'Good';
      case ProjectHealth.warning:
        return 'Warning';
      case ProjectHealth.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case ProjectHealth.excellent:
        return const Color(0xFF10B981);
      case ProjectHealth.good:
        return const Color(0xFF3B82F6);
      case ProjectHealth.warning:
        return const Color(0xFFF59E0B);
      case ProjectHealth.critical:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectHealth.excellent:
        return Icons.check_circle;
      case ProjectHealth.good:
        return Icons.thumb_up;
      case ProjectHealth.warning:
        return Icons.warning;
      case ProjectHealth.critical:
        return Icons.error;
    }
  }
}

/// Multi-dimensional project scorecard
class ProjectScorecard {
  final String projectId;
  final String projectName;
  final ProjectHealth overallHealth;
  final double overallScore;
  
  // Dimension scores (0-100)
  final double financialHealth;
  final double timelineAdherence;
  final double qualityCompliance;
  final double stakeholderSatisfaction;
  final double riskManagement;
  final double resourceUtilization;
  
  // Key metrics
  final double budgetUtilization;
  final double scheduleVariance;
  final int qualityIssues;
  final int openRisks;
  final int stakeholderCount;
  
  // Trends
  final double financialTrend;
  final double timelineTrend;
  final double qualityTrend;
  
  final DateTime lastUpdated;

  ProjectScorecard({
    required this.projectId,
    required this.projectName,
    required this.overallHealth,
    required this.overallScore,
    required this.financialHealth,
    required this.timelineAdherence,
    required this.qualityCompliance,
    required this.stakeholderSatisfaction,
    required this.riskManagement,
    required this.resourceUtilization,
    required this.budgetUtilization,
    required this.scheduleVariance,
    required this.qualityIssues,
    required this.openRisks,
    required this.stakeholderCount,
    required this.financialTrend,
    required this.timelineTrend,
    required this.qualityTrend,
    required this.lastUpdated,
  });
}

/// Stakeholder in project network
class Stakeholder {
  final String id;
  final String name;
  final String role;
  final String organization;
  final StakeholderType type;
  final double influenceScore;
  final double engagementLevel;
  final List<String> connectedStakeholders;
  final List<String> concerns;
  final DateTime lastInteraction;

  Stakeholder({
    required this.id,
    required this.name,
    required this.role,
    required this.organization,
    required this.type,
    required this.influenceScore,
    required this.engagementLevel,
    required this.connectedStakeholders,
    required this.concerns,
    required this.lastInteraction,
  });
}

/// Stakeholder type
enum StakeholderType {
  government,
  contractor,
  beneficiary,
  ngo,
  consultant,
  supplier,
}

extension StakeholderTypeExtension on StakeholderType {
  String get label {
    switch (this) {
      case StakeholderType.government:
        return 'Government';
      case StakeholderType.contractor:
        return 'Contractor';
      case StakeholderType.beneficiary:
        return 'Beneficiary';
      case StakeholderType.ngo:
        return 'NGO';
      case StakeholderType.consultant:
        return 'Consultant';
      case StakeholderType.supplier:
        return 'Supplier';
    }
  }

  Color get color {
    switch (this) {
      case StakeholderType.government:
        return const Color(0xFF3B82F6);
      case StakeholderType.contractor:
        return const Color(0xFF8B5CF6);
      case StakeholderType.beneficiary:
        return const Color(0xFF10B981);
      case StakeholderType.ngo:
        return const Color(0xFFF59E0B);
      case StakeholderType.consultant:
        return const Color(0xFF06B6D4);
      case StakeholderType.supplier:
        return const Color(0xFFEF4444);
    }
  }
}

/// Real-time project health monitoring
class ProjectHealthMetrics {
  final String projectId;
  final DateTime timestamp;
  
  // Real-time indicators
  final double cashFlowRate;
  final double completionVelocity;
  final int activeIssues;
  final int criticalAlerts;
  
  // Predictive indicators
  final double completionProbability;
  final DateTime? predictedCompletion;
  final double budgetOverrunRisk;
  final List<String> upcomingMilestones;
  
  // Recent activities
  final int recentTransactions;
  final int recentInspections;
  final int recentApprovals;

  ProjectHealthMetrics({
    required this.projectId,
    required this.timestamp,
    required this.cashFlowRate,
    required this.completionVelocity,
    required this.activeIssues,
    required this.criticalAlerts,
    required this.completionProbability,
    this.predictedCompletion,
    required this.budgetOverrunRisk,
    required this.upcomingMilestones,
    required this.recentTransactions,
    required this.recentInspections,
    required this.recentApprovals,
  });
}

/// Predictive project analytics
class PredictiveAnalytics {
  final String projectId;
  
  // Completion predictions
  final DateTime estimatedCompletion;
  final double confidenceLevel;
  final List<DelayRisk> delayRisks;
  
  // Budget predictions
  final double projectedFinalCost;
  final double costOverrunProbability;
  final List<CostRisk> costRisks;
  
  // Quality predictions
  final double qualityComplianceForecast;
  final List<QualityRisk> qualityRisks;
  
  // Recommendations
  final List<ActionableInsight> recommendations;

  PredictiveAnalytics({
    required this.projectId,
    required this.estimatedCompletion,
    required this.confidenceLevel,
    required this.delayRisks,
    required this.projectedFinalCost,
    required this.costOverrunProbability,
    required this.costRisks,
    required this.qualityComplianceForecast,
    required this.qualityRisks,
    required this.recommendations,
  });
}

/// Delay risk factor
class DelayRisk {
  final String factor;
  final double impactDays;
  final double probability;
  final String mitigation;

  DelayRisk({
    required this.factor,
    required this.impactDays,
    required this.probability,
    required this.mitigation,
  });
}

/// Cost risk factor
class CostRisk {
  final String factor;
  final double impactAmount;
  final double probability;
  final String mitigation;

  CostRisk({
    required this.factor,
    required this.impactAmount,
    required this.probability,
    required this.mitigation,
  });
}

/// Quality risk factor
class QualityRisk {
  final String factor;
  final String impact;
  final double probability;
  final String mitigation;

  QualityRisk({
    required this.factor,
    required this.impact,
    required this.probability,
    required this.mitigation,
  });
}

/// Actionable insight
class ActionableInsight {
  final String title;
  final String description;
  final InsightPriority priority;
  final List<String> actions;
  final double potentialImpact;

  ActionableInsight({
    required this.title,
    required this.description,
    required this.priority,
    required this.actions,
    required this.potentialImpact,
  });
}

/// Insight priority
enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

extension InsightPriorityExtension on InsightPriority {
  String get label {
    switch (this) {
      case InsightPriority.low:
        return 'Low';
      case InsightPriority.medium:
        return 'Medium';
      case InsightPriority.high:
        return 'High';
      case InsightPriority.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case InsightPriority.low:
        return const Color(0xFF6B7280);
      case InsightPriority.medium:
        return const Color(0xFF3B82F6);
      case InsightPriority.high:
        return const Color(0xFFF59E0B);
      case InsightPriority.critical:
        return const Color(0xFFEF4444);
    }
  }
}

/// Project intelligence summary
class ProjectIntelligence {
  final ProjectScorecard scorecard;
  final List<Stakeholder> stakeholders;
  final ProjectHealthMetrics healthMetrics;
  final PredictiveAnalytics predictiveAnalytics;
  final List<String> recentEvents;
  final Map<String, double> keyPerformanceIndicators;

  ProjectIntelligence({
    required this.scorecard,
    required this.stakeholders,
    required this.healthMetrics,
    required this.predictiveAnalytics,
    required this.recentEvents,
    required this.keyPerformanceIndicators,
  });
}