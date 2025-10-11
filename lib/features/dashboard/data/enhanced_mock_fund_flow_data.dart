import 'dart:math';
import '../../../core/models/enhanced_fund_flow_models.dart';

/// Enhanced mock data generator for 5-level fund flow hierarchy
class EnhancedMockFundFlowData {
  static final Random _random = Random();

  /// Generate comprehensive 5-level mock fund flow data
  static EnhancedSankeyFlowData generateEnhancedMockData() {
    final nodes = <EnhancedFundFlowNode>[];
    final links = <EnhancedFundFlowLink>[];

    // Level 1: Centre
    final centreNode = _createCentreNode();
    nodes.add(centreNode);

    // Level 2: States (3 states)
    final states = _createStateNodes(centreNode.id, 3);
    nodes.addAll(states);
    links.addAll(_createLinks(centreNode.id, states));

    // Level 2: Districts and Agencies per state
    for (final state in states) {
      final districts = _createDistrictNodes(state.id, 2);
      nodes.addAll(districts);
      links.addAll(_createLinks(state.id, districts));

      final agencies = _createAgencyNodes(state.id, 2);
      nodes.addAll(agencies);
      links.addAll(_createLinks(state.id, agencies));

      // Level 3: Projects and Components
      for (final agency in agencies) {
        final projects = _createProjectNodes(agency.id, 2);
        nodes.addAll(projects);
        links.addAll(_createLinks(agency.id, projects));

        for (final project in projects) {
          final components = _createComponentNodes(project.id, 3);
          nodes.addAll(components);
          links.addAll(_createLinks(project.id, components));

          // Level 4: Milestones and Categories
          for (final component in components) {
            final milestones = _createMilestoneNodes(component.id, 2);
            nodes.addAll(milestones);
            links.addAll(_createLinks(component.id, milestones));

            final categories = _createCategoryNodes(component.id, 2);
            nodes.addAll(categories);
            links.addAll(_createLinks(component.id, categories));

            // Level 5: Line Items and Beneficiaries
            for (final category in categories) {
              final lineItems = _createLineItemNodes(category.id, 3);
              nodes.addAll(lineItems);
              links.addAll(_createLinks(category.id, lineItems));
            }

            for (final milestone in milestones) {
              final beneficiaries = _createBeneficiaryNodes(milestone.id, 2);
              nodes.addAll(beneficiaries);
              links.addAll(_createLinks(milestone.id, beneficiaries));
            }
          }
        }
      }
    }

    final analytics = _generateAnalytics(nodes, links);

    return EnhancedSankeyFlowData(
      nodes: nodes,
      links: links,
      analytics: analytics,
      timestamp: DateTime.now(),
      metadata: {
        'totalNodes': nodes.length,
        'totalLinks': links.length,
        'maxDepth': 5,
      },
    );
  }

  static EnhancedFundFlowNode _createCentreNode() {
    return EnhancedFundFlowNode(
      id: 'centre_01',
      name: 'Central Government - PM-AJAY',
      level: FundFlowLevel.centre,
      allocatedAmount: 10000.0,
      utilizedAmount: 7500.0,
      inTransitAmount: 1250.0,
      healthStatus: FlowHealthStatus.healthy,
      lastUpdated: DateTime.now(),
      metadata: {
        'scheme': 'PM-AJAY',
        'financialYear': '2024-25',
      },
      childNodeIds: [],
      utilizationRate: 75.0,
      delayDays: 0,
      riskScore: 2.5,
      flags: [],
    );
  }

  static List<EnhancedFundFlowNode> _createStateNodes(String parentId, int count) {
    final states = ['Maharashtra', 'Gujarat', 'Karnataka', 'Tamil Nadu', 'Rajasthan'];
    return List.generate(count, (i) {
      final allocated = 2000.0 + (_random.nextDouble() * 1500.0);
      final utilized = allocated * (0.6 + (_random.nextDouble() * 0.3));
      final inTransit = allocated * (0.1 + (_random.nextDouble() * 0.15));
      
      return EnhancedFundFlowNode(
        id: 'state_${i + 1}',
        name: states[i % states.length],
        level: FundFlowLevel.state,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
        metadata: {
          'stateCode': 'ST${i + 1}',
          'population': 50000000 + (_random.nextInt(50000000)),
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(10),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createDistrictNodes(String parentId, int count) {
    final districts = ['North District', 'South District', 'East District', 'West District'];
    return List.generate(count, (i) {
      final allocated = 500.0 + (_random.nextDouble() * 400.0);
      final utilized = allocated * (0.55 + (_random.nextDouble() * 0.35));
      final inTransit = allocated * (0.08 + (_random.nextDouble() * 0.12));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_district_${i + 1}',
        name: districts[i % districts.length],
        level: FundFlowLevel.district,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(5))),
        metadata: {
          'districtCode': 'DT${i + 1}',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(8),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createAgencyNodes(String parentId, int count) {
    final agencies = ['State Infrastructure Authority', 'Rural Development Board', 'Urban Development Corporation', 'Public Works Department'];
    return List.generate(count, (i) {
      final allocated = 800.0 + (_random.nextDouble() * 600.0);
      final utilized = allocated * (0.65 + (_random.nextDouble() * 0.25));
      final inTransit = allocated * (0.05 + (_random.nextDouble() * 0.1));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_agency_${i + 1}',
        name: agencies[i % agencies.length],
        level: FundFlowLevel.agency,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(4))),
        metadata: {
          'agencyCode': 'AG${i + 1}',
          'agencyType': i % 2 == 0 ? 'State' : 'Autonomous',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(12),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createProjectNodes(String parentId, int count) {
    final projects = ['Infrastructure Development', 'Digital Transformation', 'Healthcare Initiative', 'Education Reform'];
    return List.generate(count, (i) {
      final allocated = 300.0 + (_random.nextDouble() * 250.0);
      final utilized = allocated * (0.5 + (_random.nextDouble() * 0.4));
      final inTransit = allocated * (0.03 + (_random.nextDouble() * 0.08));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_project_${i + 1}',
        name: '${projects[i % projects.length]} - Phase ${i + 1}',
        level: FundFlowLevel.project,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(3))),
        metadata: {
          'projectCode': 'PRJ${i + 1}',
          'startDate': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(15),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createComponentNodes(String parentId, int count) {
    final components = ['Civil Works', 'Equipment Procurement', 'Training & Capacity Building', 'Monitoring & Evaluation'];
    return List.generate(count, (i) {
      final allocated = 80.0 + (_random.nextDouble() * 70.0);
      final utilized = allocated * (0.45 + (_random.nextDouble() * 0.45));
      final inTransit = allocated * (0.02 + (_random.nextDouble() * 0.06));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_component_${i + 1}',
        name: components[i % components.length],
        level: FundFlowLevel.component,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(2))),
        metadata: {
          'componentCode': 'CMP${i + 1}',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(10),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createMilestoneNodes(String parentId, int count) {
    final milestones = ['Foundation Work', 'Structural Completion', 'Final Inspection', 'Commissioning'];
    return List.generate(count, (i) {
      final allocated = 25.0 + (_random.nextDouble() * 20.0);
      final utilized = allocated * (0.4 + (_random.nextDouble() * 0.5));
      final inTransit = allocated * (0.01 + (_random.nextDouble() * 0.04));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_milestone_${i + 1}',
        name: '${milestones[i % milestones.length]} - M${i + 1}',
        level: FundFlowLevel.milestone,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(hours: _random.nextInt(48))),
        metadata: {
          'milestoneCode': 'MS${i + 1}',
          'targetDate': DateTime.now().add(Duration(days: 30 * (i + 1))).toIso8601String(),
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(7),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createCategoryNodes(String parentId, int count) {
    final categories = ['Labor Costs', 'Material Costs', 'Equipment Rental', 'Professional Services'];
    return List.generate(count, (i) {
      final allocated = 20.0 + (_random.nextDouble() * 18.0);
      final utilized = allocated * (0.35 + (_random.nextDouble() * 0.55));
      final inTransit = allocated * (0.01 + (_random.nextDouble() * 0.03));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_category_${i + 1}',
        name: categories[i % categories.length],
        level: FundFlowLevel.category,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(hours: _random.nextInt(24))),
        metadata: {
          'categoryCode': 'CAT${i + 1}',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(5),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createLineItemNodes(String parentId, int count) {
    final lineItems = ['Direct Payment', 'Reimbursement', 'Advance', 'Final Settlement'];
    return List.generate(count, (i) {
      final allocated = 5.0 + (_random.nextDouble() * 8.0);
      final utilized = allocated * (0.3 + (_random.nextDouble() * 0.6));
      final inTransit = allocated * (0.005 + (_random.nextDouble() * 0.02));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_lineitem_${i + 1}',
        name: '${lineItems[i % lineItems.length]} - LI${i + 1}',
        level: FundFlowLevel.lineItem,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(hours: _random.nextInt(12))),
        metadata: {
          'lineItemCode': 'LI${i + 1}',
          'invoiceNumber': 'INV-2024-${1000 + i}',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(3),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowNode> _createBeneficiaryNodes(String parentId, int count) {
    final beneficiaries = ['Contractor Group A', 'Vendor Consortium B', 'Service Provider C', 'Community Cooperative D'];
    return List.generate(count, (i) {
      final allocated = 8.0 + (_random.nextDouble() * 7.0);
      final utilized = allocated * (0.25 + (_random.nextDouble() * 0.65));
      final inTransit = allocated * (0.003 + (_random.nextDouble() * 0.015));
      
      return EnhancedFundFlowNode(
        id: '${parentId}_beneficiary_${i + 1}',
        name: beneficiaries[i % beneficiaries.length],
        level: FundFlowLevel.beneficiary,
        allocatedAmount: allocated,
        utilizedAmount: utilized,
        inTransitAmount: inTransit,
        healthStatus: _getRandomHealthStatus(),
        lastUpdated: DateTime.now().subtract(Duration(hours: _random.nextInt(6))),
        metadata: {
          'beneficiaryCode': 'BEN${i + 1}',
          'accountNumber': 'ACC-${10000 + i}',
        },
        childNodeIds: [],
        parentNodeId: parentId,
        utilizationRate: (utilized / allocated) * 100,
        delayDays: _random.nextInt(2),
        riskScore: _random.nextDouble() * 10,
        flags: _generateRandomFlags(),
      );
    });
  }

  static List<EnhancedFundFlowLink> _createLinks(String sourceId, List<EnhancedFundFlowNode> targets) {
    return targets.map((target) {
      final isDelayed = _random.nextDouble() > 0.7;
      final isAnomaly = _random.nextDouble() > 0.9;
      
      return EnhancedFundFlowLink(
        id: '${sourceId}_to_${target.id}',
        sourceNodeId: sourceId,
        targetNodeId: target.id,
        amount: target.allocatedAmount,
        transferDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        completionDate: isDelayed ? null : DateTime.now().subtract(Duration(days: _random.nextInt(15))),
        status: isDelayed ? FlowHealthStatus.warning : FlowHealthStatus.healthy,
        velocity: target.allocatedAmount / (1 + _random.nextInt(10)),
        transitDays: isDelayed ? 8 + _random.nextInt(7) : _random.nextInt(7),
        metadata: {
          'transferMode': _random.nextBool() ? 'Electronic' : 'Manual',
        },
        isAnomaly: isAnomaly,
        anomalyReasons: isAnomaly ? ['Statistical outlier', 'Unusual timing'] : [],
        confidenceScore: 0.8 + (_random.nextDouble() * 0.2),
      );
    }).toList();
  }

  static FlowHealthStatus _getRandomHealthStatus() {
    final value = _random.nextDouble();
    if (value < 0.6) return FlowHealthStatus.healthy;
    if (value < 0.85) return FlowHealthStatus.warning;
    if (value < 0.95) return FlowHealthStatus.critical;
    return FlowHealthStatus.blocked;
  }

  static List<String> _generateRandomFlags() {
    final allFlags = ['Delayed', 'Under Review', 'Documentation Pending', 'High Risk'];
    final count = _random.nextInt(3);
    if (count == 0) return [];
    
    final flags = <String>[];
    for (var i = 0; i < count; i++) {
      flags.add(allFlags[_random.nextInt(allFlags.length)]);
    }
    return flags.toSet().toList();
  }

  static FlowAnalytics _generateAnalytics(
    List<EnhancedFundFlowNode> nodes,
    List<EnhancedFundFlowLink> links,
  ) {
    final bottlenecks = _detectBottlenecks(nodes);
    final anomalies = _detectAnomalies(links);
    final velocity = _calculateAverageVelocity(links);
    final slaCompliance = _calculateSLACompliance(links);
    final levelUtilization = _calculateLevelUtilization(nodes);
    final patterns = _identifyPatterns(nodes, links);

    return FlowAnalytics(
      detectedBottlenecks: bottlenecks,
      leakageAlerts: anomalies,
      averageVelocity: velocity,
      slaCompliance: slaCompliance,
      levelUtilization: levelUtilization,
      patterns: patterns,
    );
  }

  static List<Bottleneck> _detectBottlenecks(List<EnhancedFundFlowNode> nodes) {
    return nodes
        .where((node) => node.delayDays > 7)
        .map((node) => Bottleneck(
              id: 'bottleneck_${node.id}',
              nodeId: node.id,
              nodeName: node.name,
              type: BottleneckType.processingDelay,
              delayDays: node.delayDays,
              impactAmount: node.inTransitAmount,
              affectedProjects: ['Project ${node.id}'],
              rootCause: 'Documentation pending or approval delays',
              recommendations: [
                'Expedite documentation',
                'Engage with stakeholders',
                'Consider alternative routes',
              ],
              detectedAt: DateTime.now(),
            ))
        .toList();
  }

  static List<FlowAnomaly> _detectAnomalies(List<EnhancedFundFlowLink> links) {
    return links
        .where((link) => link.isAnomaly)
        .map((link) => FlowAnomaly(
              id: 'anomaly_${link.id}',
              type: AnomalyType.statisticalOutlier,
              severityScore: 7.5 + (_random.nextDouble() * 2.5),
              description: 'Transaction amount or timing deviates significantly from norm',
              affectedEntities: [link.sourceNodeId, link.targetNodeId],
              evidence: {
                'amount': link.amount,
                'velocity': link.velocity,
                'transitDays': link.transitDays,
              },
              detectedAt: DateTime.now(),
            ))
        .toList();
  }

  static double _calculateAverageVelocity(List<EnhancedFundFlowLink> links) {
    if (links.isEmpty) return 0.0;
    final totalVelocity = links.fold<double>(0, (sum, link) => sum + link.velocity);
    return totalVelocity / links.length;
  }

  static Map<String, double> _calculateSLACompliance(List<EnhancedFundFlowLink> links) {
    final total = links.length;
    final onTime = links.where((link) => link.transitDays <= 7).length;
    
    return {
      'overall': total > 0 ? (onTime / total) * 100 : 100,
      'electronic': 95.0 + (_random.nextDouble() * 5),
      'manual': 75.0 + (_random.nextDouble() * 15),
    };
  }

  static Map<FundFlowLevel, double> _calculateLevelUtilization(List<EnhancedFundFlowNode> nodes) {
    final levelGroups = <FundFlowLevel, List<EnhancedFundFlowNode>>{};
    
    for (final node in nodes) {
      levelGroups.putIfAbsent(node.level, () => []).add(node);
    }

    return levelGroups.map((level, nodeList) {
      final avgUtilization = nodeList.fold<double>(0, (sum, node) => sum + node.utilizationRate) / nodeList.length;
      return MapEntry(level, avgUtilization);
    });
  }

  static List<EfficiencyPattern> _identifyPatterns(
    List<EnhancedFundFlowNode> nodes,
    List<EnhancedFundFlowLink> links,
  ) {
    return [
      EfficiencyPattern(
        id: 'pattern_01',
        type: PatternType.recurringDelay,
        description: 'State-to-District transfers consistently delayed by 5-7 days',
        frequency: 0.45,
        impactScore: 6.5,
        recommendations: [
          'Implement automated approval workflow',
          'Pre-validate documentation',
          'Increase processing capacity',
        ],
      ),
      EfficiencyPattern(
        id: 'pattern_02',
        type: PatternType.efficientRoute,
        description: 'Electronic transfers complete 3x faster than manual processes',
        frequency: 0.75,
        impactScore: 8.0,
        recommendations: [
          'Mandate electronic transfers where possible',
          'Provide training on digital systems',
          'Incentivize electronic adoption',
        ],
      ),
    ];
  }
}