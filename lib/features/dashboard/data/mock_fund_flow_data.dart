import '../../../core/models/fund_flow_models.dart';
import '../../../core/theme/app_design_system.dart';

/// Mock data generator for testing the interactive Sankey widget
class MockFundFlowData {
  static SankeyFlowData generateMockData() {
    final now = DateTime.now();
    
    // Level 0: Centre
    final centreNode = FundFlowNode(
      id: 'centre',
      name: 'Centre (MoSJE)',
      level: 0,
      amount: 10000000000, // 1000 Cr
      allocatedAmount: 10000000000,
      utilizedAmount: 7500000000,
      remainingAmount: 2500000000,
      color: AppDesignSystem.deepIndigo,
      allocatedDate: now.subtract(const Duration(days: 180)),
      responsibleOfficer: 'Joint Secretary, MoSJE',
      contact: 'js.mosje@gov.in',
      performanceScore: 8.5,
      status: FundFlowStatus.active,
    );
    
    // Level 1: States
    final states = [
      FundFlowNode(
        id: 'state_maharashtra',
        name: 'Maharashtra',
        level: 1,
        amount: 500000000, // 50 Cr
        allocatedAmount: 500000000,
        utilizedAmount: 375000000,
        remainingAmount: 125000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 150)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.mh@gov.in',
        utilizationRate: 75.0,
        performanceScore: 8.2,
        status: FundFlowStatus.active,
        evidenceDocuments: ['UC-MAH-001.pdf', 'sanction-letter.pdf'],
      ),
      FundFlowNode(
        id: 'state_karnataka',
        name: 'Karnataka',
        level: 1,
        amount: 450000000, // 45 Cr
        allocatedAmount: 450000000,
        utilizedAmount: 360000000,
        remainingAmount: 90000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 145)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.ka@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.8,
        status: FundFlowStatus.active,
        evidenceDocuments: ['UC-KA-001.pdf'],
      ),
      FundFlowNode(
        id: 'state_rajasthan',
        name: 'Rajasthan',
        level: 1,
        amount: 400000000, // 40 Cr
        allocatedAmount: 400000000,
        utilizedAmount: 280000000,
        remainingAmount: 120000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 140)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.rj@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.5,
        status: FundFlowStatus.delayed,
        evidenceDocuments: ['UC-RJ-001.pdf'],
      ),
    ];
    
    // Level 2: Agencies (Maharashtra)
    final agencies = [
      FundFlowNode(
        id: 'agency_mh_001',
        name: 'Mumbai Development Agency',
        level: 2,
        amount: 200000000, // 20 Cr
        allocatedAmount: 200000000,
        utilizedAmount: 160000000,
        remainingAmount: 40000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 120)),
        responsibleOfficer: 'Agency Director',
        contact: 'director.mda@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.5,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_mh_002',
        name: 'Pune Rural Agency',
        level: 2,
        amount: 150000000, // 15 Cr
        allocatedAmount: 150000000,
        utilizedAmount: 105000000,
        remainingAmount: 45000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 115)),
        responsibleOfficer: 'Agency Director',
        contact: 'director.pra@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.8,
        status: FundFlowStatus.active,
      ),
    ];
    
    // Level 3: Projects
    final projects = [
      FundFlowNode(
        id: 'project_mh_001',
        name: 'Adarsh Gram - Village A',
        level: 3,
        amount: 80000000, // 8 Cr
        allocatedAmount: 80000000,
        utilizedAmount: 68000000,
        remainingAmount: 12000000,
        color: AppDesignSystem.forestGreen,
        allocatedDate: now.subtract(const Duration(days: 90)),
        utilizationStartDate: now.subtract(const Duration(days: 85)),
        utilizationEndDate: now.add(const Duration(days: 30)),
        responsibleOfficer: 'Project Manager',
        contact: 'pm.village-a@gov.in',
        utilizationRate: 85.0,
        performanceScore: 8.9,
        status: FundFlowStatus.active,
        evidenceDocuments: ['progress-report.pdf', 'milestone-1.pdf'],
      ),
      FundFlowNode(
        id: 'project_mh_002',
        name: 'Hostel Construction',
        level: 3,
        amount: 60000000, // 6 Cr
        allocatedAmount: 60000000,
        utilizedAmount: 48000000,
        remainingAmount: 12000000,
        color: AppDesignSystem.forestGreen,
        allocatedDate: now.subtract(const Duration(days: 85)),
        utilizationStartDate: now.subtract(const Duration(days: 80)),
        utilizationEndDate: now.add(const Duration(days: 45)),
        responsibleOfficer: 'Project Manager',
        contact: 'pm.hostel@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.3,
        status: FundFlowStatus.active,
      ),
    ];
    
    // Level 4: Milestones
    final milestones = [
      FundFlowNode(
        id: 'milestone_001_land',
        name: 'Land Acquisition',
        level: 4,
        amount: 15000000, // 1.5 Cr
        allocatedAmount: 15000000,
        utilizedAmount: 15000000,
        remainingAmount: 0,
        color: AppDesignSystem.amber,
        allocatedDate: now.subtract(const Duration(days: 85)),
        utilizationStartDate: now.subtract(const Duration(days: 85)),
        utilizationEndDate: now.subtract(const Duration(days: 70)),
        status: FundFlowStatus.completed,
        evidenceDocuments: ['land-deed.pdf', 'registry.pdf'],
      ),
      FundFlowNode(
        id: 'milestone_001_foundation',
        name: 'Foundation Work',
        level: 4,
        amount: 25000000, // 2.5 Cr
        allocatedAmount: 25000000,
        utilizedAmount: 23000000,
        remainingAmount: 2000000,
        color: AppDesignSystem.amber,
        allocatedDate: now.subtract(const Duration(days: 70)),
        utilizationStartDate: now.subtract(const Duration(days: 70)),
        utilizationEndDate: now.subtract(const Duration(days: 40)),
        status: FundFlowStatus.active,
        evidenceDocuments: ['foundation-photos.pdf', 'quality-cert.pdf'],
      ),
      FundFlowNode(
        id: 'milestone_001_construction',
        name: 'Main Construction',
        level: 4,
        amount: 28000000, // 2.8 Cr
        allocatedAmount: 28000000,
        utilizedAmount: 20000000,
        remainingAmount: 8000000,
        color: AppDesignSystem.amber,
        allocatedDate: now.subtract(const Duration(days: 40)),
        utilizationStartDate: now.subtract(const Duration(days: 40)),
        utilizationEndDate: now.add(const Duration(days: 30)),
        status: FundFlowStatus.active,
      ),
    ];
    
    // Create links
    final links = [
      // Centre to States
      FundFlowLink(
        id: 'link_centre_mh',
        sourceId: 'centre',
        targetId: 'state_maharashtra',
        value: 500000000,
        pfmsId: 'PFMS-2025-001234',
        transferDate: now.subtract(const Duration(days: 150)),
        initiationDate: now.subtract(const Duration(days: 153)),
        completionDate: now.subtract(const Duration(days: 150)),
        status: FundFlowStatus.completed,
        processingDays: 3,
        intermediaryBanks: ['RBI', 'State Bank'],
        evidenceDocuments: ['sanction-order.pdf', 'transfer-receipt.pdf'],
        approvedBy: 'Joint Secretary',
        approvalDate: now.subtract(const Duration(days: 153)),
        ucStatus: 'Submitted',
        auditTrail: [
          AuditLogEntry(
            id: 'audit_001',
            timestamp: now.subtract(const Duration(days: 153)),
            action: 'Sanction Approved',
            performedBy: 'Joint Secretary',
            comments: 'Approved for Q1 disbursement',
          ),
          AuditLogEntry(
            id: 'audit_002',
            timestamp: now.subtract(const Duration(days: 150)),
            action: 'Funds Transferred',
            performedBy: 'Finance Division',
          ),
        ],
      ),
      FundFlowLink(
        id: 'link_centre_ka',
        sourceId: 'centre',
        targetId: 'state_karnataka',
        value: 450000000,
        pfmsId: 'PFMS-2025-001235',
        transferDate: now.subtract(const Duration(days: 145)),
        status: FundFlowStatus.completed,
        processingDays: 2,
      ),
      FundFlowLink(
        id: 'link_centre_rj',
        sourceId: 'centre',
        targetId: 'state_rajasthan',
        value: 400000000,
        pfmsId: 'PFMS-2025-001236',
        transferDate: now.subtract(const Duration(days: 140)),
        status: FundFlowStatus.completed,
        processingDays: 4,
        flags: ['Delayed processing'],
      ),
      
      // Maharashtra to Agencies
      FundFlowLink(
        id: 'link_mh_agency1',
        sourceId: 'state_maharashtra',
        targetId: 'agency_mh_001',
        value: 200000000,
        pfmsId: 'PFMS-2025-MH-001',
        transferDate: now.subtract(const Duration(days: 120)),
        status: FundFlowStatus.completed,
        processingDays: 5,
      ),
      FundFlowLink(
        id: 'link_mh_agency2',
        sourceId: 'state_maharashtra',
        targetId: 'agency_mh_002',
        value: 150000000,
        pfmsId: 'PFMS-2025-MH-002',
        transferDate: now.subtract(const Duration(days: 115)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Agency to Projects
      FundFlowLink(
        id: 'link_agency1_proj1',
        sourceId: 'agency_mh_001',
        targetId: 'project_mh_001',
        value: 80000000,
        pfmsId: 'PFMS-2025-MDA-001',
        transferDate: now.subtract(const Duration(days: 90)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
      FundFlowLink(
        id: 'link_agency1_proj2',
        sourceId: 'agency_mh_001',
        targetId: 'project_mh_002',
        value: 60000000,
        pfmsId: 'PFMS-2025-MDA-002',
        transferDate: now.subtract(const Duration(days: 85)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Project to Milestones
      FundFlowLink(
        id: 'link_proj1_m1',
        sourceId: 'project_mh_001',
        targetId: 'milestone_001_land',
        value: 15000000,
        transferDate: now.subtract(const Duration(days: 85)),
        status: FundFlowStatus.completed,
        processingDays: 1,
      ),
      FundFlowLink(
        id: 'link_proj1_m2',
        sourceId: 'project_mh_001',
        targetId: 'milestone_001_foundation',
        value: 25000000,
        transferDate: now.subtract(const Duration(days: 70)),
        status: FundFlowStatus.active,
        processingDays: 2,
      ),
      FundFlowLink(
        id: 'link_proj1_m3',
        sourceId: 'project_mh_001',
        targetId: 'milestone_001_construction',
        value: 28000000,
        transferDate: now.subtract(const Duration(days: 40)),
        status: FundFlowStatus.active,
        processingDays: 1,
      ),
    ];
    
    // Create expenditure details for milestones
    final expenditures = {
      'milestone_001_land': [
        ExpenditureDetail(
          id: 'exp_land_001',
          category: 'Land Purchase',
          description: 'Agricultural land acquisition - 5 acres',
          amount: 5000000,
          date: now.subtract(const Duration(days: 82)),
          vendor: 'Land Owner Association',
          invoices: ['invoice-001.pdf'],
          receipts: ['receipt-001.pdf'],
          photos: ['land-photo-1.jpg', 'land-photo-2.jpg'],
          geoLocation: '19.0760° N, 72.8777° E',
          verificationStatus: FundFlowStatus.completed,
        ),
        ExpenditureDetail(
          id: 'exp_land_002',
          category: 'Registration Fees',
          description: 'Government registration and stamp duty',
          amount: 250000,
          date: now.subtract(const Duration(days: 80)),
          vendor: 'Sub-Registrar Office',
          invoices: ['registration-invoice.pdf'],
          receipts: ['registration-receipt.pdf'],
          verificationStatus: FundFlowStatus.completed,
        ),
        ExpenditureDetail(
          id: 'exp_land_003',
          category: 'Legal Charges',
          description: 'Legal consultation and documentation',
          amount: 150000,
          date: now.subtract(const Duration(days: 78)),
          vendor: 'Legal Services Firm',
          invoices: ['legal-invoice.pdf'],
          receipts: ['legal-receipt.pdf'],
          verificationStatus: FundFlowStatus.completed,
        ),
      ],
      'milestone_001_foundation': [
        ExpenditureDetail(
          id: 'exp_found_001',
          category: 'Excavation',
          description: 'Site excavation and leveling',
          amount: 1500000,
          date: now.subtract(const Duration(days: 68)),
          vendor: 'Excavation Contractor',
          invoices: ['excavation-invoice.pdf'],
          photos: ['excavation-1.jpg', 'excavation-2.jpg'],
          verificationStatus: FundFlowStatus.completed,
        ),
        ExpenditureDetail(
          id: 'exp_found_002',
          category: 'Cement',
          description: 'Portland cement - 500 bags',
          amount: 2500000,
          date: now.subtract(const Duration(days: 65)),
          vendor: 'Cement Supplier Ltd',
          invoices: ['cement-invoice.pdf'],
          receipts: ['cement-receipt.pdf'],
          qualityCertificates: ['cement-quality-cert.pdf'],
          verificationStatus: FundFlowStatus.completed,
        ),
        ExpenditureDetail(
          id: 'exp_found_003',
          category: 'Steel',
          description: 'TMT steel bars - various grades',
          amount: 1800000,
          date: now.subtract(const Duration(days: 63)),
          vendor: 'Steel Distributors',
          invoices: ['steel-invoice.pdf'],
          receipts: ['steel-receipt.pdf'],
          qualityCertificates: ['steel-quality-cert.pdf'],
          verificationStatus: FundFlowStatus.completed,
        ),
        ExpenditureDetail(
          id: 'exp_found_004',
          category: 'Labor',
          description: 'Foundation construction labor',
          amount: 1200000,
          date: now.subtract(const Duration(days: 60)),
          vendor: 'Labor Contractor',
          invoices: ['labor-invoice.pdf'],
          receipts: ['labor-receipt.pdf'],
          verificationStatus: FundFlowStatus.active,
        ),
      ],
    };
    
    return SankeyFlowData(
      nodes: [centreNode, ...states, ...agencies, ...projects, ...milestones],
      links: links,
      expenditures: expenditures,
      generatedAt: now,
    );
  }
}