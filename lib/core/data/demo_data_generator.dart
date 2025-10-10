import 'package:latlong2/latlong.dart';
import '../models/fund_transaction_model.dart';
import '../models/project_model.dart';
import '../models/agency_model.dart';
import '../models/communication_models.dart';
import '../models/state_model.dart';

/// Comprehensive demo data generator for PM-AJAY Platform
/// Generates realistic data across all features to showcase full potential
class DemoDataGenerator {
  // Indian States with major cities coordinates
  static final List<Map<String, dynamic>> _indianStates = [
    {'name': 'Maharashtra', 'capital': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Karnataka', 'capital': 'Bengaluru', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'Tamil Nadu', 'capital': 'Chennai', 'lat': 13.0827, 'lng': 80.2707},
    {'name': 'Uttar Pradesh', 'capital': 'Lucknow', 'lat': 26.8467, 'lng': 80.9462},
    {'name': 'Gujarat', 'capital': 'Gandhinagar', 'lat': 23.2156, 'lng': 72.6369},
    {'name': 'Rajasthan', 'capital': 'Jaipur', 'lat': 26.9124, 'lng': 75.7873},
    {'name': 'West Bengal', 'capital': 'Kolkata', 'lat': 22.5726, 'lng': 88.3639},
    {'name': 'Madhya Pradesh', 'capital': 'Bhopal', 'lat': 23.2599, 'lng': 77.4126},
    {'name': 'Bihar', 'capital': 'Patna', 'lat': 25.5941, 'lng': 85.1376},
    {'name': 'Andhra Pradesh', 'capital': 'Amaravati', 'lat': 16.5062, 'lng': 80.6480},
    {'name': 'Telangana', 'capital': 'Hyderabad', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'Odisha', 'capital': 'Bhubaneswar', 'lat': 20.2961, 'lng': 85.8245},
    {'name': 'Kerala', 'capital': 'Thiruvananthapuram', 'lat': 8.5241, 'lng': 76.9366},
    {'name': 'Assam', 'capital': 'Dispur', 'lat': 26.1445, 'lng': 91.7362},
    {'name': 'Punjab', 'capital': 'Chandigarh', 'lat': 30.7333, 'lng': 76.7794},
    {'name': 'Haryana', 'capital': 'Chandigarh', 'lat': 30.7333, 'lng': 76.7794},
    {'name': 'Jharkhand', 'capital': 'Ranchi', 'lat': 23.3441, 'lng': 85.3096},
    {'name': 'Chhattisgarh', 'capital': 'Raipur', 'lat': 21.2514, 'lng': 81.6296},
    {'name': 'Uttarakhand', 'capital': 'Dehradun', 'lat': 30.3165, 'lng': 78.0322},
    {'name': 'Himachal Pradesh', 'capital': 'Shimla', 'lat': 31.1048, 'lng': 77.1734},
  ];

  static final List<String> _projectNames = [
    'Adarsh Gram Development',
    'Tribal Hostel Construction',
    'Community Infrastructure Upgrade',
    'Skill Development Center',
    'Primary Healthcare Facility',
    'Water Supply Network',
    'Rural Road Connectivity',
    'Digital Literacy Center',
    'Sanitation Infrastructure',
    'Agricultural Training Hub',
    'Women Empowerment Center',
    'Youth Skill Academy',
    'Traditional Craft Revival',
    'Eco-Tourism Development',
    'Renewable Energy Installation',
    'Village Library Setup',
    'Sports Complex Development',
    'Market Infrastructure',
    'Dairy Cooperative Facility',
    'Horticulture Development',
  ];

  static final List<String> _agencyNames = [
    'State Tribal Welfare',
    'District Development Authority',
    'Regional Planning Commission',
    'Technical Support Unit',
    'Monitoring & Evaluation Cell',
    'Capacity Building Center',
    'Implementation Support Agency',
    'Quality Assurance Division',
    'Financial Management Unit',
    'Social Welfare Department',
  ];

  /// Generate comprehensive fund transactions
  static List<FundTransaction> generateFundTransactions({int count = 100}) {
    final transactions = <FundTransaction>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final stateIndex = i % _indianStates.length;
      final state = _indianStates[stateIndex];
      final daysAgo = (i * 3) % 365;
      final transactionDate = now.subtract(Duration(days: daysAgo));
      
      final stages = FundFlowStage.values;
      final statuses = TransactionStatus.values;
      final components = SchemeComponent.values;
      
      transactions.add(FundTransaction(
        id: 'TXN${(i + 1).toString().padLeft(6, '0')}',
        pfmsId: 'PFMS${(i + 1).toString().padLeft(8, '0')}',
        transactionDate: transactionDate,
        amount: _generateAmount(i),
        fromEntity: i % 3 == 0 ? 'Ministry of Finance' : state['name'],
        fromEntityId: i % 3 == 0 ? 'CENTRE001' : 'ST${stateIndex.toString().padLeft(2, '0')}',
        toEntity: i % 3 == 1 ? state['name'] : 'Project ${i % 20 + 1}',
        toEntityId: i % 3 == 1 ? 'ST${stateIndex.toString().padLeft(2, '0')}' : 'PRJ${((i % 20) + 1).toString().padLeft(5, '0')}',
        stage: stages[i % stages.length],
        status: statuses[i % statuses.length],
        component: components[i % components.length],
        fromEntityType: i % 3 == 0 ? 'centre' : 'state',
        toEntityType: i % 3 == 1 ? 'state' : 'project',
        createdBy: 'system_user',
        createdAt: transactionDate,
        updatedAt: transactionDate.add(Duration(hours: i % 24)),
        documentUrls: _generateDocumentUrls(i),
        notes: _generateRemarks(i),
        isDelayed: i % 5 == 0,
        processingDays: (i % 30) + 1,
      ));
    }
    
    return transactions;
  }

  /// Generate projects with realistic data
  static List<ProjectModel> generateProjects({int count = 50}) {
    final projects = <ProjectModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final stateIndex = i % _indianStates.length;
      final state = _indianStates[stateIndex];
      final projectName = _projectNames[i % _projectNames.length];
      final statuses = ProjectStatus.values;
      final components = ProjectComponent.values;
      
      projects.add(ProjectModel(
        id: 'PRJ${(i + 1).toString().padLeft(5, '0')}',
        name: '$projectName - ${state['name']}',
        description: 'Comprehensive development project in ${state['capital']} district',
        status: statuses[i % statuses.length],
        component: components[i % components.length],
        location: LatLng(
          state['lat'] + (i * 0.1 % 2 - 1),
          state['lng'] + (i * 0.1 % 2 - 1),
        ),
        completionPercentage: (i * 11) % 101,
        allocatedBudget: _generateBudget(i),
        beneficiariesCount: _generateBeneficiaries(i),
        startDate: now.subtract(Duration(days: (i * 30) % 730)),
        createdAt: now.subtract(Duration(days: (i * 30) % 730)),
        updatedAt: now.subtract(Duration(days: (i * 5) % 180)),
      ));
    }
    
    return projects;
  }

  /// Generate agencies with details
  static List<AgencyModel> generateAgencies({int count = 25}) {
    final agencies = <AgencyModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final stateIndex = i % _indianStates.length;
      final state = _indianStates[stateIndex];
      final agencyTypes = AgencyType.values;
      
      agencies.add(AgencyModel(
        id: 'AGY${(i + 1).toString().padLeft(4, '0')}',
        name: '${_agencyNames[i % _agencyNames.length]} - ${state['name']}',
        type: agencyTypes[i % agencyTypes.length],
        location: LatLng(state['lat'], state['lng']),
        contactPerson: 'Officer ${i + 1}',
        email: 'officer${i + 1}@${state['name'].toLowerCase().replaceAll(' ', '')}.gov.in',
        phone: '+91 ${9000000000 + i}',
        isActive: i % 10 != 0,
        createdAt: now.subtract(Duration(days: (i * 45) % 1095)),
        updatedAt: now.subtract(Duration(days: (i * 7) % 180)),
        address: '${i + 1}, Government Complex, ${state['capital']}, ${state['name']}',
      ));
    }
    
    return agencies;
  }

  /// Generate state models with comprehensive data
  static List<StateModel> generateStates() {
    final states = <StateModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < _indianStates.length; i++) {
      final state = _indianStates[i];
      
      states.add(StateModel(
        id: 'ST${(i + 1).toString().padLeft(2, '0')}',
        name: state['name'],
        code: state['name'].substring(0, 2).toUpperCase(),
        capitalLocation: LatLng(state['lat'], state['lng']),
        fundUtilizationRate: 0.5 + (i * 0.03),
        performanceScore: 60.0 + (i * 3.0),
        totalProjects: (i + 1) * 2 + 5,
        completedProjects: (i + 1) * 3,
        createdAt: now.subtract(Duration(days: 1095)),
        updatedAt: now.subtract(Duration(days: 7)),
        metadata: {
          'population': _generatePopulation(i),
          'area': _generateArea(i),
          'districts': (i + 1) * 3 + 10,
          'blocks': (i + 1) * 15 + 50,
          'villages': (i + 1) * 200 + 1000,
          'tribalPopulation': _generateTribalPopulation(i),
          'allocatedBudget': _generateStateBudget(i),
          'utilizedBudget': _generateStateBudget(i) * (0.5 + (i * 0.03)),
        },
      ));
    }
    
    return states;
  }

  // Helper methods for generating realistic values
  static double _generateAmount(int seed) {
    final amounts = [500000, 1000000, 2000000, 5000000, 10000000, 15000000];
    return amounts[seed % amounts.length].toDouble();
  }

  static double _generateBudget(int seed) {
    final budgets = [5000, 10000, 20000, 50000, 100000, 200000];
    return budgets[seed % budgets.length].toDouble();
  }

  static double _generateStateBudget(int seed) {
    return (seed + 1) * 500000000.0 + 1000000000.0;
  }

  static int _generateBeneficiaries(int seed) {
    final counts = [500, 1000, 2000, 5000, 10000, 15000, 20000];
    return counts[seed % counts.length];
  }

  static int _generatePopulation(int seed) {
    return (seed + 1) * 5000000 + 10000000;
  }

  static int _generateTribalPopulation(int seed) {
    return ((seed + 1) * 500000 + 1000000);
  }

  static double _generateArea(int seed) {
    return (seed + 1) * 10000.0 + 50000.0;
  }

  static String _generateRemarks(int seed) {
    final remarks = [
      'Transaction completed successfully',
      'Pending verification',
      'Awaiting approval from higher authority',
      'Documents submitted for review',
      'On-hold due to compliance check',
      'Processing in progress',
      'Approved and scheduled for disbursement',
      'Under financial audit review',
    ];
    return remarks[seed % remarks.length];
  }

  static List<String> _generateDocumentUrls(int seed) {
    return [
      'https://docs.pmajay.gov.in/uc/${seed + 1}/certificate.pdf',
      'https://docs.pmajay.gov.in/evidence/${seed + 1}/photo1.jpg',
      'https://docs.pmajay.gov.in/reports/${seed + 1}/progress.pdf',
    ];
  }

  // ========== COMMUNICATION HUB DEMO DATA ==========

  /// Generate channels with realistic data
  static List<Channel> generateChannels({int count = 15, required String userId}) {
    final channels = <Channel>[];
    final now = DateTime.now();
    
    final channelTypes = [
      {'name': 'Project Discussion', 'type': ChannelType.group},
      {'name': 'State Coordinators', 'type': ChannelType.group},
      {'name': 'Technical Support', 'type': ChannelType.group},
      {'name': 'Announcements', 'type': ChannelType.broadcast},
      {'name': 'Fund Approvals', 'type': ChannelType.group},
      {'name': 'Quality Assurance Team', 'type': ChannelType.group},
      {'name': 'Direct Message - Officer A', 'type': ChannelType.direct},
      {'name': 'Direct Message - Manager B', 'type': ChannelType.direct},
      {'name': 'Implementation Team', 'type': ChannelType.group},
      {'name': 'Monitoring Cell', 'type': ChannelType.group},
      {'name': 'Policy Updates', 'type': ChannelType.broadcast},
      {'name': 'Field Officers', 'type': ChannelType.group},
      {'name': 'Direct Message - Director C', 'type': ChannelType.direct},
      {'name': 'Budget Planning', 'type': ChannelType.group},
      {'name': 'Escalations', 'type': ChannelType.group},
    ];
    
    for (int i = 0; i < count && i < channelTypes.length; i++) {
      final channelInfo = channelTypes[i];
      final daysAgo = (i * 7) % 90;
      final hoursAgo = i % 24;
      
      channels.add(Channel(
        id: 'CH${(i + 1).toString().padLeft(4, '0')}',
        name: channelInfo['name'] as String,
        type: channelInfo['type'] as ChannelType,
        memberIds: _generateMemberIds(i, userId),
        createdAt: now.subtract(Duration(days: daysAgo)),
        lastMessageAt: now.subtract(Duration(hours: hoursAgo)),
        lastMessage: _generateLastMessage(i),
        unreadCount: i % 3 == 0 ? (i % 5) + 1 : 0,
        metadata: {
          'description': 'Communication channel for ${channelInfo['name']}',
          'memberCount': _generateMemberIds(i, userId).length,
        },
      ));
    }
    
    return channels;
  }

  /// Generate messages for channels
  static List<Message> generateMessages({int count = 50, required String channelId}) {
    final messages = <Message>[];
    final now = DateTime.now();
    
    final sampleUsers = [
      'Rajesh Kumar',
      'Priya Sharma',
      'Amit Patel',
      'Sneha Reddy',
      'Vikram Singh',
      'Anita Desai',
      'Rahul Verma',
      'Kavita Joshi',
    ];
    
    final messageTemplates = [
      'Meeting scheduled for tomorrow at 10 AM',
      'Please review the latest project report',
      'Fund allocation has been approved',
      'Updated the dashboard with new metrics',
      'Need clarification on the compliance requirements',
      'Site visit completed successfully',
      'Documentation uploaded to the portal',
      'Awaiting approval from higher authorities',
      'Budget utilization report submitted',
      'Quality check completed for Phase 2',
      'Training session scheduled for next week',
      'Field survey data now available',
      'Risk assessment report ready for review',
      'All milestones achieved for this quarter',
      'Beneficiary feedback collected and analyzed',
    ];
    
    for (int i = 0; i < count; i++) {
      final minutesAgo = (i * 15) % (24 * 60);
      final senderIndex = i % sampleUsers.length;
      
      messages.add(Message(
        id: 'MSG${(i + 1).toString().padLeft(6, '0')}',
        channelId: channelId,
        senderId: 'USR${(senderIndex + 1).toString().padLeft(3, '0')}',
        senderName: sampleUsers[senderIndex],
        content: messageTemplates[i % messageTemplates.length],
        timestamp: now.subtract(Duration(minutes: minutesAgo)),
        mentions: i % 5 == 0 ? ['USR001'] : [],
        isRead: i % 3 != 0,
        type: MessageType.text,
      ));
    }
    
    return messages;
  }

  /// Generate tickets with comprehensive data
  static List<Ticket> generateTickets({int count = 30}) {
    final tickets = <Ticket>[];
    final now = DateTime.now();
    
    final ticketTitles = [
      'Fund disbursement delay in Maharashtra',
      'Technical issue with project reporting',
      'Request for budget reallocation',
      'Compliance documentation missing',
      'Site access permission required',
      'Equipment procurement assistance needed',
      'Training material updates required',
      'Beneficiary data verification issue',
      'Quality audit findings resolution',
      'Inter-state coordination needed',
      'Infrastructure readiness confirmation',
      'Consultant appointment approval',
      'Environmental clearance pending',
      'Community engagement plan review',
      'Monitoring visit schedule conflict',
    ];
    
    for (int i = 0; i < count; i++) {
      final daysAgo = (i * 5) % 180;
      final createdDate = now.subtract(Duration(days: daysAgo));
      final statuses = TicketStatus.values;
      final priorities = TicketPriority.values;
      final types = TicketType.values;
      
      final status = statuses[i % statuses.length];
      final dueDate = status != TicketStatus.resolved && status != TicketStatus.closed
          ? createdDate.add(Duration(days: 7 + (i % 14)))
          : null;
      
      tickets.add(Ticket(
        id: 'TKT${(i + 1).toString().padLeft(6, '0')}',
        title: ticketTitles[i % ticketTitles.length],
        description: 'Detailed description for ${ticketTitles[i % ticketTitles.length]}. This requires immediate attention and proper resolution following standard protocols.',
        type: types[i % types.length],
        priority: priorities[i % priorities.length],
        status: status,
        creatorId: 'USR${((i % 8) + 1).toString().padLeft(3, '0')}',
        assigneeId: i % 3 != 0 ? 'USR${((i % 5) + 1).toString().padLeft(3, '0')}' : null,
        projectId: i % 2 == 0 ? 'PRJ${((i % 20) + 1).toString().padLeft(5, '0')}' : null,
        createdAt: createdDate,
        updatedAt: createdDate.add(Duration(hours: (i * 6) % 72)),
        resolvedAt: status == TicketStatus.resolved ? createdDate.add(Duration(days: i % 10)) : null,
        dueDate: dueDate,
        tags: _generateTicketTags(i),
        comments: _generateTicketComments(i, 'TKT${(i + 1).toString().padLeft(6, '0')}'),
        metadata: {
          'state': _indianStates[i % _indianStates.length]['name'],
          'component': i % 2 == 0 ? 'Adarsh Gram' : 'Tribal Hostel',
        },
      ));
    }
    
    return tickets;
  }

  /// Generate tags for categorization
  static List<Tag> generateTags({int count = 20}) {
    final tags = <Tag>[];
    final now = DateTime.now();
    
    final tagData = [
      {'name': 'Urgent', 'color': '#FF0000', 'desc': 'High priority items requiring immediate attention'},
      {'name': 'Finance', 'color': '#4CAF50', 'desc': 'Financial and budget related matters'},
      {'name': 'Technical', 'color': '#2196F3', 'desc': 'Technical issues and requirements'},
      {'name': 'Compliance', 'color': '#FF9800', 'desc': 'Compliance and regulatory matters'},
      {'name': 'Procurement', 'color': '#9C27B0', 'desc': 'Procurement and acquisition requests'},
      {'name': 'Training', 'color': '#00BCD4', 'desc': 'Training and capacity building'},
      {'name': 'Documentation', 'color': '#795548', 'desc': 'Documentation and reporting'},
      {'name': 'Infrastructure', 'color': '#607D8B', 'desc': 'Infrastructure development'},
      {'name': 'Quality', 'color': '#E91E63', 'desc': 'Quality assurance and control'},
      {'name': 'Coordination', 'color': '#3F51B5', 'desc': 'Inter-department coordination'},
      {'name': 'Monitoring', 'color': '#009688', 'desc': 'Monitoring and evaluation'},
      {'name': 'Beneficiary', 'color': '#8BC34A', 'desc': 'Beneficiary related matters'},
      {'name': 'Site Visit', 'color': '#FFC107', 'desc': 'Field visits and inspections'},
      {'name': 'Approval', 'color': '#673AB7', 'desc': 'Approval and authorization'},
      {'name': 'Escalation', 'color': '#F44336', 'desc': 'Escalated issues'},
      {'name': 'Innovation', 'color': '#00BCD4', 'desc': 'Innovative approaches and ideas'},
      {'name': 'Sustainability', 'color': '#4CAF50', 'desc': 'Sustainability initiatives'},
      {'name': 'Community', 'color': '#FF5722', 'desc': 'Community engagement'},
      {'name': 'Planning', 'color': '#9E9E9E', 'desc': 'Planning and strategy'},
      {'name': 'Review', 'color': '#607D8B', 'desc': 'Review and assessment'},
    ];
    
    for (int i = 0; i < count && i < tagData.length; i++) {
      final tag = tagData[i];
      final daysAgo = (i * 10) % 365;
      
      tags.add(Tag(
        id: 'TAG${(i + 1).toString().padLeft(4, '0')}',
        name: tag['name'] as String,
        color: tag['color'] as String,
        description: tag['desc'] as String,
        usageCount: (i * 7) % 50 + 5,
        createdAt: now.subtract(Duration(days: daysAgo)),
      ));
    }
    
    return tags;
  }

  // Helper methods for communication data
  static List<String> _generateMemberIds(int seed, String currentUserId) {
    final memberCount = (seed % 8) + 2;
    final members = <String>[currentUserId];
    
    for (int i = 0; i < memberCount; i++) {
      final memberId = 'USR${((seed + i) % 20 + 1).toString().padLeft(3, '0')}';
      if (!members.contains(memberId)) {
        members.add(memberId);
      }
    }
    
    return members;
  }

  static String _generateLastMessage(int seed) {
    final messages = [
      'Please check the latest update',
      'Meeting scheduled for tomorrow',
      'Document uploaded successfully',
      'Approval received from higher authority',
      'Need your input on this matter',
      'Task completed and verified',
      'Awaiting further instructions',
      'Review completed, looks good',
    ];
    return messages[seed % messages.length];
  }

  static List<String> _generateTicketTags(int seed) {
    final allTags = ['TAG0001', 'TAG0002', 'TAG0003', 'TAG0004', 'TAG0005', 'TAG0006'];
    final tagCount = (seed % 3) + 1;
    return allTags.sublist(0, tagCount);
  }

  static List<TicketComment> _generateTicketComments(int seed, String ticketId) {
    final comments = <TicketComment>[];
    final now = DateTime.now();
    final commentCount = (seed % 4) + 1;
    
    final commentTexts = [
      'Working on this issue, will update soon',
      'Additional documents have been requested',
      'Issue has been escalated to the relevant department',
      'Follow-up meeting scheduled for next week',
      'Resolution in progress, expecting completion by end of month',
    ];
    
    for (int i = 0; i < commentCount; i++) {
      final daysAgo = (seed * 3 + i * 2) % 30;
      comments.add(TicketComment(
        id: 'CMT${(seed * 10 + i).toString().padLeft(6, '0')}',
        ticketId: ticketId,
        userId: 'USR${((seed + i) % 8 + 1).toString().padLeft(3, '0')}',
        userName: 'User ${(seed + i) % 8 + 1}',
        content: commentTexts[i % commentTexts.length],
        createdAt: now.subtract(Duration(days: daysAgo)),
        isInternal: i % 3 == 0,
      ));
    }
    
    return comments;
  }
}