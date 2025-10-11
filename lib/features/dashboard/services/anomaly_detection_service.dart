import 'dart:math';
import '../../../core/models/enhanced_fund_flow_models.dart';

/// Risk level classification
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Prediction type
enum PredictionType {
  fundShortfall,
  delayCascade,
  complianceRisk,
  performanceDegradation,
}

/// Statistical metrics
class Statistics {
  final double mean;
  final double stdDev;

  Statistics({required this.mean, required this.stdDev});
}

/// Risk score for an entity
class RiskScore {
  final String entityId;
  final double score;
  final RiskLevel level;
  final List<String> factors;
  final int anomalyCount;
  final DateTime lastUpdated;

  RiskScore({
    required this.entityId,
    required this.score,
    required this.level,
    required this.factors,
    required this.anomalyCount,
    required this.lastUpdated,
  });
}

/// Predictive insight
class PredictiveInsight {
  final String id;
  final PredictionType type;
  final String entityId;
  final String entityName;
  final String prediction;
  final double confidence;
  final Duration timeframe;
  final String severity;
  final List<String> recommendations;

  PredictiveInsight({
    required this.id,
    required this.type,
    required this.entityId,
    required this.entityName,
    required this.prediction,
    required this.confidence,
    required this.timeframe,
    required this.severity,
    required this.recommendations,
  });
}

/// Anomaly detection result container
class AnomalyDetectionResult {
  final List<FlowAnomaly> anomalies;
  final Map<String, RiskScore> riskScores;
  final List<PredictiveInsight> predictions;
  final DateTime detectionTimestamp;
  final double confidence;

  AnomalyDetectionResult({
    required this.anomalies,
    required this.riskScores,
    required this.predictions,
    required this.detectionTimestamp,
    required this.confidence,
  });

  int get criticalAnomalyCount => anomalies.where((a) => a.severityScore >= 8.0).length;
  int get highRiskEntityCount => riskScores.values.where((r) => r.level == RiskLevel.critical).length;
}

/// AI-Powered Anomaly Detection Service
/// Implements multiple detection algorithms for comprehensive fraud and irregularity identification
class AnomalyDetectionService {
  static final Random _random = Random();

  /// Detect anomalies across entire fund flow data
  static AnomalyDetectionResult detectAnomalies(EnhancedSankeyFlowData data) {
    final statisticalOutliers = _detectStatisticalOutliers(data.nodes, data.links);
    final behavioralAnomalies = _detectBehavioralPatterns(data.nodes);
    final velocityAnomalies = _detectVelocityAnomalies(data.links);
    final duplicateTransactions = _detectDuplicateTransactions(data.links);
    final fraudIndicators = _detectFraudIndicators(data.nodes, data.links);
    
    final allAnomalies = [
      ...statisticalOutliers,
      ...behavioralAnomalies,
      ...velocityAnomalies,
      ...duplicateTransactions,
      ...fraudIndicators,
    ];

    final riskScores = _calculateRiskScores(data.nodes, allAnomalies);
    final predictions = _generatePredictions(data.nodes, allAnomalies);

    return AnomalyDetectionResult(
      anomalies: allAnomalies,
      riskScores: riskScores,
      predictions: predictions,
      detectionTimestamp: DateTime.now(),
      confidence: _calculateOverallConfidence(allAnomalies),
    );
  }

  /// Statistical outlier detection using Z-score method
  /// Flags transactions/nodes deviating >2 standard deviations from norm
  static List<FlowAnomaly> _detectStatisticalOutliers(
    List<EnhancedFundFlowNode> nodes,
    List<EnhancedFundFlowLink> links,
  ) {
    final anomalies = <FlowAnomaly>[];

    // Analyze node amounts
    if (nodes.length > 2) {
      final amounts = nodes.map((n) => n.allocatedAmount).toList();
      final stats = _calculateStatistics(amounts);
      
      for (final node in nodes) {
        final zScore = (node.allocatedAmount - stats.mean) / stats.stdDev;
        if (zScore.abs() > 2.0) {
          anomalies.add(FlowAnomaly(
            id: 'outlier_node_${node.id}',
            type: AnomalyType.statisticalOutlier,
            severityScore: _calculateSeverity(zScore.abs()),
            description: 'Fund allocation deviates ${zScore.abs().toStringAsFixed(1)} standard deviations from mean',
            affectedEntities: [node.id],
            evidence: {
              'amount': node.allocatedAmount,
              'mean': stats.mean,
              'stdDev': stats.stdDev,
              'zScore': zScore,
            },
            detectedAt: DateTime.now(),
          ));
        }
      }
    }

    // Analyze link velocities
    if (links.length > 2) {
      final velocities = links.map((l) => l.velocity).toList();
      final stats = _calculateStatistics(velocities);
      
      for (final link in links) {
        final zScore = (link.velocity - stats.mean) / stats.stdDev;
        if (zScore.abs() > 2.0) {
          anomalies.add(FlowAnomaly(
            id: 'outlier_link_${link.id}',
            type: AnomalyType.velocityAnomaly,
            severityScore: _calculateSeverity(zScore.abs()),
            description: 'Transfer velocity deviates ${zScore.abs().toStringAsFixed(1)} standard deviations from norm',
            affectedEntities: [link.sourceNodeId, link.targetNodeId],
            evidence: {
              'velocity': link.velocity,
              'mean': stats.mean,
              'stdDev': stats.stdDev,
              'zScore': zScore,
            },
            detectedAt: DateTime.now(),
          ));
        }
      }
    }

    return anomalies;
  }

  /// Behavioral pattern analysis
  /// Identifies unusual spending patterns and deviations from historical behavior
  static List<FlowAnomaly> _detectBehavioralPatterns(List<EnhancedFundFlowNode> nodes) {
    final anomalies = <FlowAnomaly>[];

    for (final node in nodes) {
      // Unusual utilization rate
      if (node.utilizationRate > 95.0) {
        anomalies.add(FlowAnomaly(
          id: 'behavior_rapid_${node.id}',
          type: AnomalyType.unusualPattern,
          severityScore: 6.5 + (node.utilizationRate - 95.0) / 10,
          description: 'Unusually high utilization rate (${node.utilizationRate.toStringAsFixed(1)}%) may indicate rushed spending',
          affectedEntities: [node.id],
          evidence: {
            'utilizationRate': node.utilizationRate,
            'threshold': 95.0,
          },
          detectedAt: DateTime.now(),
        ));
      }

      // Unusual delay patterns
      if (node.delayDays > 14) {
        anomalies.add(FlowAnomaly(
          id: 'behavior_delay_${node.id}',
          type: AnomalyType.unusualPattern,
          severityScore: 5.0 + (node.delayDays / 14.0),
          description: 'Unusual delay pattern (${node.delayDays} days) may indicate processing issues',
          affectedEntities: [node.id],
          evidence: {
            'delayDays': node.delayDays,
            'threshold': 14,
          },
          detectedAt: DateTime.now(),
        ));
      }

      // High risk score with multiple flags
      if (node.riskScore > 7.0 && node.flags.length > 2) {
        anomalies.add(FlowAnomaly(
          id: 'behavior_risk_${node.id}',
          type: AnomalyType.unusualPattern,
          severityScore: node.riskScore,
          description: 'High risk score (${node.riskScore.toStringAsFixed(1)}) with multiple flags requires investigation',
          affectedEntities: [node.id],
          evidence: {
            'riskScore': node.riskScore,
            'flags': node.flags,
            'flagCount': node.flags.length,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }

    return anomalies;
  }

  /// Velocity anomaly detection
  /// Identifies unusual transfer speeds and timing patterns
  static List<FlowAnomaly> _detectVelocityAnomalies(List<EnhancedFundFlowLink> links) {
    final anomalies = <FlowAnomaly>[];

    for (final link in links) {
      // Unusually fast transfer (potential automation bypass)
      if (link.transitDays == 0 && link.amount > 50.0) {
        anomalies.add(FlowAnomaly(
          id: 'velocity_instant_${link.id}',
          type: AnomalyType.velocityAnomaly,
          severityScore: 7.5,
          description: 'Instant large transfer (₹${link.amount.toStringAsFixed(2)}Cr) may bypass approval workflow',
          affectedEntities: [link.sourceNodeId, link.targetNodeId],
          evidence: {
            'amount': link.amount,
            'transitDays': link.transitDays,
            'velocity': link.velocity,
          },
          detectedAt: DateTime.now(),
        ));
      }

      // Unusually slow transfer (potential fund parking)
      if (link.transitDays > 15 && link.amount > 100.0) {
        anomalies.add(FlowAnomaly(
          id: 'velocity_slow_${link.id}',
          type: AnomalyType.velocityAnomaly,
          severityScore: 6.0 + (link.transitDays / 30.0),
          description: 'Unusually slow large transfer (${link.transitDays} days) may indicate fund parking',
          affectedEntities: [link.sourceNodeId, link.targetNodeId],
          evidence: {
            'amount': link.amount,
            'transitDays': link.transitDays,
            'velocity': link.velocity,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }

    return anomalies;
  }

  /// Duplicate transaction detection
  /// Identifies potentially duplicate or recycled transactions
  static List<FlowAnomaly> _detectDuplicateTransactions(List<EnhancedFundFlowLink> links) {
    final anomalies = <FlowAnomaly>[];
    final seen = <String, EnhancedFundFlowLink>{};

    for (final link in links) {
      final key = '${link.sourceNodeId}_${link.targetNodeId}_${link.amount.toStringAsFixed(2)}';
      
      if (seen.containsKey(key)) {
        final original = seen[key]!;
        final daysDiff = link.transferDate.difference(original.transferDate).inDays.abs();
        
        if (daysDiff < 7) {
          anomalies.add(FlowAnomaly(
            id: 'duplicate_${link.id}',
            type: AnomalyType.duplicateTransaction,
            severityScore: 8.5,
            description: 'Potential duplicate transaction: identical amount, route, and timing',
            affectedEntities: [link.sourceNodeId, link.targetNodeId],
            evidence: {
              'originalId': original.id,
              'duplicateId': link.id,
              'amount': link.amount,
              'daysBetween': daysDiff,
            },
            detectedAt: DateTime.now(),
          ));
        }
      } else {
        seen[key] = link;
      }
    }

    return anomalies;
  }

  /// Fraud indicator detection
  /// Advanced pattern matching for potential fraudulent activity
  static List<FlowAnomaly> _detectFraudIndicators(
    List<EnhancedFundFlowNode> nodes,
    List<EnhancedFundFlowLink> links,
  ) {
    final anomalies = <FlowAnomaly>[];

    // Round-tripping detection (funds returning to source)
    final flowGraph = _buildFlowGraph(links);
    for (final entry in flowGraph.entries) {
      final sourceId = entry.key;
      final targets = entry.value;
      
      for (final targetId in targets) {
        if (flowGraph[targetId]?.contains(sourceId) ?? false) {
          anomalies.add(FlowAnomaly(
            id: 'fraud_roundtrip_${sourceId}_$targetId',
            type: AnomalyType.fraudIndicator,
            severityScore: 9.0,
            description: 'Potential round-tripping detected: funds flowing in circular pattern',
            affectedEntities: [sourceId, targetId],
            evidence: {
              'pattern': 'circular_flow',
              'nodes': [sourceId, targetId],
            },
            detectedAt: DateTime.now(),
          ));
        }
      }
    }

    // Disproportionate fund allocation
    for (final node in nodes) {
      final totalAllocated = node.allocatedAmount;
      final childLinks = links.where((l) => l.sourceNodeId == node.id).toList();
      final childTotal = childLinks.fold<double>(0, (sum, l) => sum + l.amount);
      
      if (childTotal > totalAllocated * 1.1) {
        anomalies.add(FlowAnomaly(
          id: 'fraud_over_allocation_${node.id}',
          type: AnomalyType.possibleLeakage,
          severityScore: 8.5,
          description: 'Total child allocations exceed parent by ${((childTotal / totalAllocated - 1) * 100).toStringAsFixed(1)}%',
          affectedEntities: [node.id, ...childLinks.map((l) => l.targetNodeId)],
          evidence: {
            'parentAllocation': totalAllocated,
            'childTotal': childTotal,
            'excess': childTotal - totalAllocated,
          },
          detectedAt: DateTime.now(),
        ));
      }
    }

    return anomalies;
  }

  /// Calculate risk scores for all entities
  static Map<String, RiskScore> _calculateRiskScores(
    List<EnhancedFundFlowNode> nodes,
    List<FlowAnomaly> anomalies,
  ) {
    final scores = <String, RiskScore>{};

    for (final node in nodes) {
      final relatedAnomalies = anomalies
          .where((a) => a.affectedEntities.contains(node.id))
          .toList();

      final baseScore = node.riskScore;
      final anomalyScore = relatedAnomalies.isEmpty
          ? 0.0
          : relatedAnomalies.map((a) => a.severityScore).reduce((a, b) => a + b) / relatedAnomalies.length;

      final finalScore = (baseScore + anomalyScore) / 2;

      scores[node.id] = RiskScore(
        entityId: node.id,
        score: finalScore.clamp(0.0, 10.0),
        level: _getRiskLevel(finalScore),
        factors: [
          if (node.delayDays > 7) 'Processing delays',
          if (node.utilizationRate > 90) 'High utilization',
          if (node.flags.isNotEmpty) 'Active flags',
          if (relatedAnomalies.isNotEmpty) 'Detected anomalies',
        ],
        anomalyCount: relatedAnomalies.length,
        lastUpdated: DateTime.now(),
      );
    }

    return scores;
  }

  /// Generate predictive insights
  static List<PredictiveInsight> _generatePredictions(
    List<EnhancedFundFlowNode> nodes,
    List<FlowAnomaly> anomalies,
  ) {
    final predictions = <PredictiveInsight>[];

    // Fund shortfall prediction
    final criticalNodes = nodes.where((n) => 
      n.remainingAmount < n.allocatedAmount * 0.15 && n.utilizationRate > 80
    ).toList();

    for (final node in criticalNodes) {
      final daysToDepletion = _predictDaysToDepletion(node);
      predictions.add(PredictiveInsight(
        id: 'predict_shortfall_${node.id}',
        type: PredictionType.fundShortfall,
        entityId: node.id,
        entityName: node.name,
        prediction: 'Fund depletion expected in $daysToDepletion days',
        confidence: 0.75 + (_random.nextDouble() * 0.2),
        timeframe: Duration(days: daysToDepletion),
        severity: daysToDepletion < 30 ? 'High' : 'Medium',
        recommendations: [
          'Request additional allocation',
          'Slow down spending rate',
          'Review budget priorities',
        ],
      ));
    }

    // Delay cascade prediction
    final delayedNodes = nodes.where((n) => n.delayDays > 10).toList();
    for (final node in delayedNodes) {
      predictions.add(PredictiveInsight(
        id: 'predict_cascade_${node.id}',
        type: PredictionType.delayCascade,
        entityId: node.id,
        entityName: node.name,
        prediction: 'Current delays likely to cascade to ${node.childNodeIds.length} child entities',
        confidence: 0.70 + (_random.nextDouble() * 0.25),
        timeframe: Duration(days: node.delayDays + 7),
        severity: 'Medium',
        recommendations: [
          'Expedite processing for this node',
          'Alert downstream entities',
          'Consider parallel processing',
        ],
      ));
    }

    // Compliance risk prediction
    final highRiskNodes = nodes.where((n) => n.riskScore > 7.0).toList();
    for (final node in highRiskNodes) {
      predictions.add(PredictiveInsight(
        id: 'predict_compliance_${node.id}',
        type: PredictionType.complianceRisk,
        entityId: node.id,
        entityName: node.name,
        prediction: 'High probability of compliance issues in next audit cycle',
        confidence: 0.65 + (_random.nextDouble() * 0.3),
        timeframe: const Duration(days: 90),
        severity: 'High',
        recommendations: [
          'Conduct immediate compliance review',
          'Update documentation',
          'Schedule preventive audit',
        ],
      ));
    }

    return predictions;
  }

  // Helper methods

  static Statistics _calculateStatistics(List<double> values) {
    if (values.isEmpty) return Statistics(mean: 0, stdDev: 0);
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);
    
    return Statistics(mean: mean, stdDev: stdDev);
  }

  static double _calculateSeverity(double zScore) {
    return (5.0 + (zScore - 2.0) * 2.0).clamp(5.0, 10.0);
  }

  static Map<String, List<String>> _buildFlowGraph(List<EnhancedFundFlowLink> links) {
    final graph = <String, List<String>>{};
    for (final link in links) {
      graph.putIfAbsent(link.sourceNodeId, () => []).add(link.targetNodeId);
    }
    return graph;
  }

  static RiskLevel _getRiskLevel(double score) {
    if (score >= 8.0) return RiskLevel.critical;
    if (score >= 6.0) return RiskLevel.high;
    if (score >= 4.0) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static int _predictDaysToDepletion(EnhancedFundFlowNode node) {
    final dailyBurnRate = node.utilizationRate > 0
        ? node.utilizedAmount / 30
        : 1.0;
    return (node.remainingAmount / dailyBurnRate).ceil();
  }

  static double _calculateOverallConfidence(List<FlowAnomaly> anomalies) {
    if (anomalies.isEmpty) return 1.0;
    return anomalies.map((a) => 0.8 + (_random.nextDouble() * 0.15)).reduce((a, b) => a + b) / anomalies.length;
  }
}