import '../models/overwatch_project_model.dart';
import '../models/overwatch_fund_flow_model.dart';
import 'dart:math';

class OverwatchMockData {
  static final Random _random = Random();

  /// Generate mock projects for Overwatch dashboard
  static List<OverwatchProject> generateMockProjects() {
    return [
      OverwatchProject(
        id: 'PMAJAY-2025-001',
        name: 'Adarsh Gram Development - Wardha Village',
        agency: 'Maharashtra Rural Development Agency',
        state: 'Maharashtra',
        district: 'Wardha',
        component: ProjectComponentType.adarshGram,
        totalFunds: 5000000,
        utilizedFunds: 3750000,
        allocatedFunds: 5000000,
        status: OverwatchProjectStatus.active,
        riskScore: 7.2,
        riskLevel: RiskLevel.medium,
        progress: 75.0,
        location: 'Wardha, Maharashtra',
        timeline: 'Jan 2025 - Dec 2025',
        responsiblePerson: ResponsiblePerson(
          name: 'Mr. Suresh Patil',
          designation: 'Project Manager',
          contact: '+91-7123456789',
          empId: 'MRDA-PM-045',
          email: 'suresh.patil@mrda.gov.in',
          department: 'Rural Development',
        ),
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        flags: ['Documentation Pending'],
        metadata: {
          'beneficiaries': 500,
          'villages': 3,
        },
      ),
      OverwatchProject(
        id: 'PMAJAY-2025-002',
        name: 'Hostel Construction - Nagpur',
        agency: 'Maharashtra Social Welfare Department',
        state: 'Maharashtra',
        district: 'Nagpur',
        component: ProjectComponentType.hostel,
        totalFunds: 8000000,
        utilizedFunds: 3600000,
        allocatedFunds: 8000000,
        status: OverwatchProjectStatus.delayed,
        riskScore: 8.5,
        riskLevel: RiskLevel.high,
        progress: 45.0,
        location: 'Nagpur, Maharashtra',
        timeline: 'Mar 2025 - Feb 2026',
        responsiblePerson: ResponsiblePerson(
          name: 'Mrs. Anjali Desai',
          designation: 'Chief Engineer',
          contact: '+91-8234567890',
          empId: 'MSWD-CE-023',
          email: 'anjali.desai@mswd.gov.in',
          department: 'Social Welfare',
        ),
        lastUpdate: DateTime.now().subtract(const Duration(hours: 5)),
        startDate: DateTime(2025, 3, 1),
        endDate: DateTime(2026, 2, 28),
        flags: ['Delayed Milestone', 'Contractor Issues'],
        metadata: {
          'capacity': 200,
          'floors': 4,
        },
      ),
      OverwatchProject(
        id: 'PMAJAY-2025-003',
        name: 'GIA Skill Development Center',
        agency: 'Maharashtra Skill Development Agency',
        state: 'Maharashtra',
        district: 'Pune',
        component: ProjectComponentType.gia,
        totalFunds: 3000000,
        utilizedFunds: 2700000,
        allocatedFunds: 3000000,
        status: OverwatchProjectStatus.active,
        riskScore: 3.5,
        riskLevel: RiskLevel.low,
        progress: 90.0,
        location: 'Pune, Maharashtra',
        timeline: 'Feb 2025 - Aug 2025',
        responsiblePerson: ResponsiblePerson(
          name: 'Dr. Rahul Sharma',
          designation: 'Director',
          contact: '+91-9123456789',
          empId: 'MSDA-DIR-001',
          email: 'rahul.sharma@msda.gov.in',
          department: 'Skill Development',
        ),
        lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 8, 31),
        flags: [],
        metadata: {
          'trainingCapacity': 100,
          'courses': 8,
        },
      ),
      OverwatchProject(
        id: 'PMAJAY-2025-004',
        name: 'Community Center - Aurangabad',
        agency: 'Maharashtra Community Development Board',
        state: 'Maharashtra',
        district: 'Aurangabad',
        component: ProjectComponentType.adarshGram,
        totalFunds: 4500000,
        utilizedFunds: 1125000,
        allocatedFunds: 4500000,
        status: OverwatchProjectStatus.flagged,
        riskScore: 9.2,
        riskLevel: RiskLevel.high,
        progress: 25.0,
        location: 'Aurangabad, Maharashtra',
        timeline: 'Apr 2025 - Oct 2025',
        responsiblePerson: ResponsiblePerson(
          name: 'Mr. Vikram Jadhav',
          designation: 'Project Coordinator',
          contact: '+91-7234567890',
          empId: 'MCDB-PC-078',
          email: 'vikram.jadhav@mcdb.gov.in',
          department: 'Community Development',
        ),
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 30)),
        startDate: DateTime(2025, 4, 1),
        endDate: DateTime(2025, 10, 31),
        flags: ['Evidence Quality Issues', 'Fund Mismatch', 'High Risk'],
        metadata: {
          'beneficiaries': 300,
          'area': '5000 sq ft',
        },
      ),
    ];
  }

  /// Generate complete fund flow data for a project
  static CompleteFundFlowData generateFundFlowForProject(OverwatchProject project) {
    final nodes = <FundFlowNode>[];
    final links = <FundFlowLink>[];

    // Level 0: Centre
    final centreNode = FundFlowNode(
      id: 'centre',
      name: 'Ministry of Social Justice & Empowerment',
      type: FundFlowNodeType.centre,
      level: 0,
      amount: 50000000,
      responsiblePerson: ResponsiblePerson(
        name: 'Dr. Rajesh Kumar',
        designation: 'Joint Secretary',
        contact: '+91-11-23384417',
        empId: 'MOSJE001',
      ),
      metadata: {'ministry': 'Social Justice'},
    );
    nodes.add(centreNode);

    // Level 1: State
    final stateNode = FundFlowNode(
      id: 'state_${project.state}',
      name: '${project.state} State',
      type: FundFlowNodeType.state,
      level: 1,
      amount: project.totalFunds,
      responsiblePerson: ResponsiblePerson(
        name: 'Mrs. Priya Sharma',
        designation: 'Director, Social Welfare',
        contact: '+91-22-22694827',
        empId: 'MH-SW-001',
      ),
      parentNodeId: centreNode.id,
      metadata: {'state': project.state},
    );
    nodes.add(stateNode);

    links.add(FundFlowLink(
      id: '${centreNode.id}_to_${stateNode.id}',
      sourceNodeId: centreNode.id,
      targetNodeId: stateNode.id,
      value: project.totalFunds,
      status: FlowLinkStatus.completed,
      details: PFMSDetails(
        pfmsId: 'PFMS-2025-001234',
        transferDate: DateTime.now().subtract(const Duration(days: 60)),
        processingDays: 2,
        documents: ['Sanction_Letter.pdf', 'UC_Previous.pdf'],
      ),
    ));

    // Level 2: Agency
    final agencyNode = FundFlowNode(
      id: 'agency_${project.id}',
      name: project.agency,
      type: FundFlowNodeType.agency,
      level: 2,
      amount: project.totalFunds,
      responsiblePerson: project.responsiblePerson,
      parentNodeId: stateNode.id,
      metadata: {'agency': project.agency},
    );
    nodes.add(agencyNode);

    links.add(FundFlowLink(
      id: '${stateNode.id}_to_${agencyNode.id}',
      sourceNodeId: stateNode.id,
      targetNodeId: agencyNode.id,
      value: project.totalFunds,
      status: FlowLinkStatus.completed,
      details: PFMSDetails(
        pfmsId: 'PFMS-2025-001235',
        transferDate: DateTime.now().subtract(const Duration(days: 50)),
        processingDays: 5,
        documents: ['Work_Order.pdf', 'Agency_Agreement.pdf'],
      ),
    ));

    // Level 3: Project
    final projectNode = FundFlowNode(
      id: 'project_${project.id}',
      name: project.name,
      type: FundFlowNodeType.project,
      level: 3,
      amount: project.totalFunds,
      responsiblePerson: project.responsiblePerson,
      parentNodeId: agencyNode.id,
      metadata: {'project': project.id},
    );
    nodes.add(projectNode);

    links.add(FundFlowLink(
      id: '${agencyNode.id}_to_${projectNode.id}',
      sourceNodeId: agencyNode.id,
      targetNodeId: projectNode.id,
      value: project.totalFunds,
      status: FlowLinkStatus.completed,
      details: PFMSDetails(
        pfmsId: 'PFMS-2025-001236',
        transferDate: DateTime.now().subtract(const Duration(days: 45)),
        processingDays: 3,
        documents: ['Project_Allocation.pdf'],
      ),
    ));

    // Level 4: Milestones
    final milestones = _generateMilestones(projectNode, project);
    nodes.addAll(milestones.map((m) => m.$1));
    links.addAll(milestones.map((m) => m.$2));

    // Level 5: Expenses
    for (final (milestoneNode, _) in milestones) {
      final expenses = _generateExpenses(milestoneNode);
      nodes.addAll(expenses.map((e) => e.$1));
      links.addAll(expenses.map((e) => e.$2));
    }

    return CompleteFundFlowData(
      nodes: nodes,
      links: links,
      timestamp: DateTime.now(),
      analytics: {
        'totalNodes': nodes.length,
        'totalLinks': links.length,
        'utilizationRate': project.utilizationPercentage,
      },
    );
  }

  static List<(FundFlowNode, FundFlowLink)> _generateMilestones(
    FundFlowNode projectNode,
    OverwatchProject project,
  ) {
    final milestones = <(FundFlowNode, FundFlowLink)>[];
    final milestoneNames = ['Land Acquisition', 'Infrastructure Development', 'Community Facilities'];
    final amounts = [
      project.totalFunds * 0.4,
      project.totalFunds * 0.5,
      project.totalFunds * 0.1,
    ];

    for (int i = 0; i < milestoneNames.length; i++) {
      final node = FundFlowNode(
        id: '${projectNode.id}_milestone_$i',
        name: milestoneNames[i],
        type: FundFlowNodeType.milestone,
        level: 4,
        amount: amounts[i],
        parentNodeId: projectNode.id,
        metadata: {'milestone': i},
      );

      final link = FundFlowLink(
        id: '${projectNode.id}_to_${node.id}',
        sourceNodeId: projectNode.id,
        targetNodeId: node.id,
        value: amounts[i],
        status: i == 0
            ? FlowLinkStatus.completed
            : i == 1
                ? FlowLinkStatus.pending
                : FlowLinkStatus.pending,
        details: PFMSDetails(
          pfmsId: 'PFMS-2025-00123${7 + i}',
          transferDate: DateTime.now().subtract(Duration(days: 30 - (i * 10))),
          processingDays: i == 0 ? 1 : 0,
          documents: ['Milestone_Approval.pdf'],
        ),
      );

      milestones.add((node, link));
    }

    return milestones;
  }

  static List<(FundFlowNode, FundFlowLink)> _generateExpenses(FundFlowNode milestoneNode) {
    final expenses = <(FundFlowNode, FundFlowLink)>[];
    final expenseNames = ['Direct Payment', 'Material Cost', 'Labor Cost'];
    
    for (int i = 0; i < 2; i++) {
      final amount = milestoneNode.amount * (i == 0 ? 0.6 : 0.4);
      
      final node = FundFlowNode(
        id: '${milestoneNode.id}_expense_$i',
        name: expenseNames[i],
        type: FundFlowNodeType.expense,
        level: 5,
        amount: amount,
        parentNodeId: milestoneNode.id,
        details: TransactionDetails(
          transactionId: 'TXN-${milestoneNode.id}-${i + 1}',
          date: DateTime.now().subtract(Duration(days: _random.nextInt(20))),
          bankDetails: 'SBI Wardha Branch',
          approvalStatus: i == 0 ? 'Completed' : 'In Progress',
          pfmsId: 'PFMS-2025-00124${i}',
        ),
        metadata: {'expense': i},
      );

      final link = FundFlowLink(
        id: '${milestoneNode.id}_to_${node.id}',
        sourceNodeId: milestoneNode.id,
        targetNodeId: node.id,
        value: amount,
        status: i == 0 ? FlowLinkStatus.completed : FlowLinkStatus.pending,
        details: PFMSDetails(
          pfmsId: 'PFMS-2025-00124${i}',
          transferDate: DateTime.now().subtract(Duration(days: 15 - (i * 5))),
          processingDays: i == 0 ? 2 : 7,
          documents: ['Invoice.pdf', 'Receipt.pdf'],
        ),
      );

      expenses.add((node, link));
    }

    return expenses;
  }
}