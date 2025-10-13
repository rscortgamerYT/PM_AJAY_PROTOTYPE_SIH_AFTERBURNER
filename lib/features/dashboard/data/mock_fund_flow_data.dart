import '../../../core/models/fund_flow_models.dart';
import '../../../core/theme/app_design_system.dart';

/// Mock data generator for testing the interactive Sankey widget
class MockFundFlowData {
  /// Generates fund flow data showing Centre → States → Agencies hierarchy
  /// Optimized for centre admin dashboard view
  static SankeyFlowData generateCentreToAgenciesData() {
    final now = DateTime.now();
    
    // Level 0: Centre Treasury
    final centreNode = FundFlowNode(
      id: 'centre_treasury',
      name: 'Central Treasury (PM-AJAY)',
      level: 0,
      amount: 15000000000, // 1500 Cr total budget
      allocatedAmount: 15000000000,
      utilizedAmount: 11250000000, // 75% utilized
      remainingAmount: 3750000000,
      color: AppDesignSystem.deepIndigo,
      allocatedDate: now.subtract(const Duration(days: 180)),
      responsibleOfficer: 'Secretary, MoSJE',
      contact: 'secretary.mosje@gov.in',
      performanceScore: 8.7,
      status: FundFlowStatus.active,
    );
    
    // Level 1: States (expanded list)
    final states = [
      FundFlowNode(
        id: 'state_maharashtra',
        name: 'Maharashtra',
        level: 1,
        amount: 1200000000, // 120 Cr
        allocatedAmount: 1200000000,
        utilizedAmount: 900000000,
        remainingAmount: 300000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 150)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.mh@gov.in',
        utilizationRate: 75.0,
        performanceScore: 8.2,
        status: FundFlowStatus.active,
        evidenceDocuments: ['UC-MAH-Q1.pdf', 'UC-MAH-Q2.pdf'],
      ),
      FundFlowNode(
        id: 'state_karnataka',
        name: 'Karnataka',
        level: 1,
        amount: 980000000, // 98 Cr
        allocatedAmount: 980000000,
        utilizedAmount: 784000000,
        remainingAmount: 196000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 145)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.ka@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.8,
        status: FundFlowStatus.active,
        evidenceDocuments: ['UC-KA-Q1.pdf'],
      ),
      FundFlowNode(
        id: 'state_rajasthan',
        name: 'Rajasthan',
        level: 1,
        amount: 850000000, // 85 Cr
        allocatedAmount: 850000000,
        utilizedAmount: 595000000,
        remainingAmount: 255000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 140)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.rj@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.5,
        status: FundFlowStatus.delayed,
        evidenceDocuments: ['UC-RJ-Q1.pdf'],
      ),
      FundFlowNode(
        id: 'state_gujarat',
        name: 'Gujarat',
        level: 1,
        amount: 920000000, // 92 Cr
        allocatedAmount: 920000000,
        utilizedAmount: 736000000,
        remainingAmount: 184000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 135)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.gj@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.5,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'state_tamilnadu',
        name: 'Tamil Nadu',
        level: 1,
        amount: 890000000, // 89 Cr
        allocatedAmount: 890000000,
        utilizedAmount: 712000000,
        remainingAmount: 178000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 130)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.tn@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.3,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'state_uttarpradesh',
        name: 'Uttar Pradesh',
        level: 1,
        amount: 1100000000, // 110 Cr
        allocatedAmount: 1100000000,
        utilizedAmount: 825000000,
        remainingAmount: 275000000,
        color: AppDesignSystem.vibrantTeal,
        allocatedDate: now.subtract(const Duration(days: 148)),
        responsibleOfficer: 'State Commissioner',
        contact: 'commissioner.up@gov.in',
        utilizationRate: 75.0,
        performanceScore: 7.8,
        status: FundFlowStatus.active,
      ),
    ];
    
    // Level 2: Agencies under each state
    final agencies = [
      // Maharashtra Agencies
      FundFlowNode(
        id: 'agency_mh_001',
        name: 'Mumbai Development Agency',
        level: 2,
        amount: 350000000, // 35 Cr
        allocatedAmount: 350000000,
        utilizedAmount: 280000000,
        remainingAmount: 70000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 120)),
        responsibleOfficer: 'Director, MDA',
        contact: 'director.mda@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.5,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_mh_002',
        name: 'Pune Rural Agency',
        level: 2,
        amount: 280000000, // 28 Cr
        allocatedAmount: 280000000,
        utilizedAmount: 196000000,
        remainingAmount: 84000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 115)),
        responsibleOfficer: 'Director, PRA',
        contact: 'director.pra@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.8,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_mh_003',
        name: 'Nagpur Tribal Development',
        level: 2,
        amount: 270000000, // 27 Cr
        allocatedAmount: 270000000,
        utilizedAmount: 202500000,
        remainingAmount: 67500000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 110)),
        responsibleOfficer: 'Director, NTD',
        contact: 'director.ntd@gov.in',
        utilizationRate: 75.0,
        performanceScore: 8.0,
        status: FundFlowStatus.active,
      ),
      
      // Karnataka Agencies
      FundFlowNode(
        id: 'agency_ka_001',
        name: 'Bangalore Urban Agency',
        level: 2,
        amount: 320000000, // 32 Cr
        allocatedAmount: 320000000,
        utilizedAmount: 256000000,
        remainingAmount: 64000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 118)),
        responsibleOfficer: 'Director, BUA',
        contact: 'director.bua@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.7,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_ka_002',
        name: 'Mysore Welfare Agency',
        level: 2,
        amount: 330000000, // 33 Cr
        allocatedAmount: 330000000,
        utilizedAmount: 264000000,
        remainingAmount: 66000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 113)),
        responsibleOfficer: 'Director, MWA',
        contact: 'director.mwa@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.9,
        status: FundFlowStatus.active,
      ),
      
      // Rajasthan Agencies
      FundFlowNode(
        id: 'agency_rj_001',
        name: 'Jaipur Development Corp',
        level: 2,
        amount: 290000000, // 29 Cr
        allocatedAmount: 290000000,
        utilizedAmount: 203000000,
        remainingAmount: 87000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 108)),
        responsibleOfficer: 'CEO, JDC',
        contact: 'ceo.jdc@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.6,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_rj_002',
        name: 'Udaipur Tribal Agency',
        level: 2,
        amount: 260000000, // 26 Cr
        allocatedAmount: 260000000,
        utilizedAmount: 182000000,
        remainingAmount: 78000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 105)),
        responsibleOfficer: 'Director, UTA',
        contact: 'director.uta@gov.in',
        utilizationRate: 70.0,
        performanceScore: 7.4,
        status: FundFlowStatus.delayed,
      ),
      
      // Gujarat Agencies
      FundFlowNode(
        id: 'agency_gj_001',
        name: 'Ahmedabad Development',
        level: 2,
        amount: 340000000, // 34 Cr
        allocatedAmount: 340000000,
        utilizedAmount: 272000000,
        remainingAmount: 68000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 102)),
        responsibleOfficer: 'Director, AD',
        contact: 'director.ad@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.6,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_gj_002',
        name: 'Surat Welfare Board',
        level: 2,
        amount: 290000000, // 29 Cr
        allocatedAmount: 290000000,
        utilizedAmount: 232000000,
        remainingAmount: 58000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 100)),
        responsibleOfficer: 'Chairman, SWB',
        contact: 'chairman.swb@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.4,
        status: FundFlowStatus.active,
      ),
      
      // Tamil Nadu Agencies
      FundFlowNode(
        id: 'agency_tn_001',
        name: 'Chennai Development Corp',
        level: 2,
        amount: 310000000, // 31 Cr
        allocatedAmount: 310000000,
        utilizedAmount: 248000000,
        remainingAmount: 62000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 98)),
        responsibleOfficer: 'MD, CDC',
        contact: 'md.cdc@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.3,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_tn_002',
        name: 'Madurai Tribal Welfare',
        level: 2,
        amount: 290000000, // 29 Cr
        allocatedAmount: 290000000,
        utilizedAmount: 232000000,
        remainingAmount: 58000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 95)),
        responsibleOfficer: 'Director, MTW',
        contact: 'director.mtw@gov.in',
        utilizationRate: 80.0,
        performanceScore: 8.3,
        status: FundFlowStatus.active,
      ),
      
      // Uttar Pradesh Agencies
      FundFlowNode(
        id: 'agency_up_001',
        name: 'Lucknow Development Agency',
        level: 2,
        amount: 380000000, // 38 Cr
        allocatedAmount: 380000000,
        utilizedAmount: 285000000,
        remainingAmount: 95000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 115)),
        responsibleOfficer: 'Director, LDA',
        contact: 'director.lda@gov.in',
        utilizationRate: 75.0,
        performanceScore: 7.9,
        status: FundFlowStatus.active,
      ),
      FundFlowNode(
        id: 'agency_up_002',
        name: 'Varanasi Welfare Board',
        level: 2,
        amount: 340000000, // 34 Cr
        allocatedAmount: 340000000,
        utilizedAmount: 255000000,
        remainingAmount: 85000000,
        color: AppDesignSystem.royalPurple,
        allocatedDate: now.subtract(const Duration(days: 110)),
        responsibleOfficer: 'Chairman, VWB',
        contact: 'chairman.vwb@gov.in',
        utilizationRate: 75.0,
        performanceScore: 7.7,
        status: FundFlowStatus.active,
      ),
    ];
    
    // Create links: Centre → States → Agencies
    final links = [
      // Centre to Maharashtra
      FundFlowLink(
        id: 'link_centre_mh',
        sourceId: 'centre_treasury',
        targetId: 'state_maharashtra',
        value: 1200000000,
        pfmsId: 'PFMS-2025-MH-001',
        transferDate: now.subtract(const Duration(days: 150)),
        initiationDate: now.subtract(const Duration(days: 153)),
        completionDate: now.subtract(const Duration(days: 150)),
        status: FundFlowStatus.completed,
        processingDays: 3,
        intermediaryBanks: ['RBI', 'State Bank of India'],
        evidenceDocuments: ['sanction-order-mh.pdf', 'transfer-receipt-mh.pdf'],
        approvedBy: 'Finance Secretary',
        approvalDate: now.subtract(const Duration(days: 153)),
        ucStatus: 'Submitted',
      ),
      
      // Centre to Karnataka
      FundFlowLink(
        id: 'link_centre_ka',
        sourceId: 'centre_treasury',
        targetId: 'state_karnataka',
        value: 980000000,
        pfmsId: 'PFMS-2025-KA-001',
        transferDate: now.subtract(const Duration(days: 145)),
        status: FundFlowStatus.completed,
        processingDays: 2,
      ),
      
      // Centre to Rajasthan
      FundFlowLink(
        id: 'link_centre_rj',
        sourceId: 'centre_treasury',
        targetId: 'state_rajasthan',
        value: 850000000,
        pfmsId: 'PFMS-2025-RJ-001',
        transferDate: now.subtract(const Duration(days: 140)),
        status: FundFlowStatus.completed,
        processingDays: 4,
        flags: ['Delayed processing'],
      ),
      
      // Centre to Gujarat
      FundFlowLink(
        id: 'link_centre_gj',
        sourceId: 'centre_treasury',
        targetId: 'state_gujarat',
        value: 920000000,
        pfmsId: 'PFMS-2025-GJ-001',
        transferDate: now.subtract(const Duration(days: 135)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Centre to Tamil Nadu
      FundFlowLink(
        id: 'link_centre_tn',
        sourceId: 'centre_treasury',
        targetId: 'state_tamilnadu',
        value: 890000000,
        pfmsId: 'PFMS-2025-TN-001',
        transferDate: now.subtract(const Duration(days: 130)),
        status: FundFlowStatus.completed,
        processingDays: 2,
      ),
      
      // Centre to Uttar Pradesh
      FundFlowLink(
        id: 'link_centre_up',
        sourceId: 'centre_treasury',
        targetId: 'state_uttarpradesh',
        value: 1100000000,
        pfmsId: 'PFMS-2025-UP-001',
        transferDate: now.subtract(const Duration(days: 148)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Maharashtra to Agencies
      FundFlowLink(
        id: 'link_mh_agency1',
        sourceId: 'state_maharashtra',
        targetId: 'agency_mh_001',
        value: 350000000,
        pfmsId: 'PFMS-MH-AGY-001',
        transferDate: now.subtract(const Duration(days: 120)),
        status: FundFlowStatus.completed,
        processingDays: 5,
      ),
      FundFlowLink(
        id: 'link_mh_agency2',
        sourceId: 'state_maharashtra',
        targetId: 'agency_mh_002',
        value: 280000000,
        pfmsId: 'PFMS-MH-AGY-002',
        transferDate: now.subtract(const Duration(days: 115)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
      FundFlowLink(
        id: 'link_mh_agency3',
        sourceId: 'state_maharashtra',
        targetId: 'agency_mh_003',
        value: 270000000,
        pfmsId: 'PFMS-MH-AGY-003',
        transferDate: now.subtract(const Duration(days: 110)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Karnataka to Agencies
      FundFlowLink(
        id: 'link_ka_agency1',
        sourceId: 'state_karnataka',
        targetId: 'agency_ka_001',
        value: 320000000,
        pfmsId: 'PFMS-KA-AGY-001',
        transferDate: now.subtract(const Duration(days: 118)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
      FundFlowLink(
        id: 'link_ka_agency2',
        sourceId: 'state_karnataka',
        targetId: 'agency_ka_002',
        value: 330000000,
        pfmsId: 'PFMS-KA-AGY-002',
        transferDate: now.subtract(const Duration(days: 113)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      
      // Rajasthan to Agencies
      FundFlowLink(
        id: 'link_rj_agency1',
        sourceId: 'state_rajasthan',
        targetId: 'agency_rj_001',
        value: 290000000,
        pfmsId: 'PFMS-RJ-AGY-001',
        transferDate: now.subtract(const Duration(days: 108)),
        status: FundFlowStatus.completed,
        processingDays: 5,
      ),
      FundFlowLink(
        id: 'link_rj_agency2',
        sourceId: 'state_rajasthan',
        targetId: 'agency_rj_002',
        value: 260000000,
        pfmsId: 'PFMS-RJ-AGY-002',
        transferDate: now.subtract(const Duration(days: 105)),
        status: FundFlowStatus.completed,
        processingDays: 6,
      ),
      
      // Gujarat to Agencies
      FundFlowLink(
        id: 'link_gj_agency1',
        sourceId: 'state_gujarat',
        targetId: 'agency_gj_001',
        value: 340000000,
        pfmsId: 'PFMS-GJ-AGY-001',
        transferDate: now.subtract(const Duration(days: 102)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      FundFlowLink(
        id: 'link_gj_agency2',
        sourceId: 'state_gujarat',
        targetId: 'agency_gj_002',
        value: 290000000,
        pfmsId: 'PFMS-GJ-AGY-002',
        transferDate: now.subtract(const Duration(days: 100)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
      
      // Tamil Nadu to Agencies
      FundFlowLink(
        id: 'link_tn_agency1',
        sourceId: 'state_tamilnadu',
        targetId: 'agency_tn_001',
        value: 310000000,
        pfmsId: 'PFMS-TN-AGY-001',
        transferDate: now.subtract(const Duration(days: 98)),
        status: FundFlowStatus.completed,
        processingDays: 3,
      ),
      FundFlowLink(
        id: 'link_tn_agency2',
        sourceId: 'state_tamilnadu',
        targetId: 'agency_tn_002',
        value: 290000000,
        pfmsId: 'PFMS-TN-AGY-002',
        transferDate: now.subtract(const Duration(days: 95)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
      
      // Uttar Pradesh to Agencies
      FundFlowLink(
        id: 'link_up_agency1',
        sourceId: 'state_uttarpradesh',
        targetId: 'agency_up_001',
        value: 380000000,
        pfmsId: 'PFMS-UP-AGY-001',
        transferDate: now.subtract(const Duration(days: 115)),
        status: FundFlowStatus.completed,
        processingDays: 5,
      ),
      FundFlowLink(
        id: 'link_up_agency2',
        sourceId: 'state_uttarpradesh',
        targetId: 'agency_up_002',
        value: 340000000,
        pfmsId: 'PFMS-UP-AGY-002',
        transferDate: now.subtract(const Duration(days: 110)),
        status: FundFlowStatus.completed,
        processingDays: 4,
      ),
    ];
    
    return SankeyFlowData(
      nodes: [centreNode, ...states, ...agencies],
      links: links,
      expenditures: {},
      generatedAt: now,
    );
  }
}