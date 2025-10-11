import 'dart:math';
import '../models/evidence_models.dart';

class MockEvidenceData {
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
  
  static final List<String> _userNames = [
    'Rajesh Kumar',
    'Priya Sharma',
    'Amit Patel',
    'Sneha Reddy',
    'Vikram Singh',
    'Anita Desai',
    'Rahul Gupta',
    'Deepa Iyer',
  ];
  
  static final List<String> _fileNames = [
    'Construction_Site_Photo',
    'Invoice_Payment_Receipt',
    'Quality_Inspection_Report',
    'Material_Delivery_Document',
    'Safety_Compliance_Certificate',
    'Project_Progress_Video',
    'Contractor_Agreement',
    'Fund_Utilization_Statement',
  ];
  
  static final List<String> _descriptions = [
    'Foundation work completed as per specifications',
    'Material procurement invoice for cement and steel',
    'Monthly progress report with quality checks',
    'Delivery challan for construction materials',
    'Safety audit certificate from authorized inspector',
    'Time-lapse video of construction progress',
    'Signed contractor agreement with terms',
    'Quarterly fund utilization report',
  ];
  
  static final List<String> _tags = [
    'construction',
    'invoice',
    'inspection',
    'quality',
    'safety',
    'progress',
    'materials',
    'compliance',
    'payment',
    'documentation',
  ];

  static List<Evidence> generateMockEvidence(int count) {
    final List<Evidence> evidenceList = [];
    
    for (int i = 0; i < count; i++) {
      final projectName = _projectNames[_random.nextInt(_projectNames.length)];
      final type = EvidenceType.values[_random.nextInt(EvidenceType.values.length)];
      final status = _getWeightedStatus();
      final uploadedBy = _userNames[_random.nextInt(_userNames.length)];
      final fileName = '${_fileNames[_random.nextInt(_fileNames.length)]}_${i + 1}.${_getFileExtension(type)}';
      
      final hasLocation = _random.nextDouble() > 0.3;
      final hasBlockchain = _random.nextDouble() > 0.6;
      final qualityScore = _generateQualityScore(status);
      
      final evidence = Evidence(
        id: 'EV${(i + 1).toString().padLeft(6, '0')}',
        type: type,
        projectId: 'PRJ${_random.nextInt(100).toString().padLeft(3, '0')}',
        projectName: projectName,
        fileName: fileName,
        fileUrl: 'https://storage.example.com/evidence/$fileName',
        uploadedAt: DateTime.now().subtract(Duration(days: _random.nextInt(180))),
        uploadedBy: uploadedBy,
        status: status,
        qualityScore: qualityScore,
        location: hasLocation ? _generateLocation() : null,
        metadata: _generateMetadata(type),
        tags: _generateTags(),
        description: _descriptions[_random.nextInt(_descriptions.length)],
        relatedEvidenceIds: _generateRelatedIds(i),
        blockchainAnchor: hasBlockchain ? _generateBlockchainAnchor() : null,
        suspiciousFlags: _generateSuspiciousFlags(status),
        verifiedAt: status == VerificationStatus.verified 
            ? DateTime.now().subtract(Duration(days: _random.nextInt(30)))
            : null,
        verifiedBy: status == VerificationStatus.verified ? uploadedBy : null,
        versions: [],
      );
      
      evidenceList.add(evidence);
    }
    
    return evidenceList;
  }
  
  static VerificationStatus _getWeightedStatus() {
    final rand = _random.nextDouble();
    if (rand < 0.15) return VerificationStatus.pending;
    if (rand < 0.70) return VerificationStatus.verified;
    if (rand < 0.85) return VerificationStatus.rejected;
    return VerificationStatus.flagged;
  }
  
  static double _generateQualityScore(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 0.7 + _random.nextDouble() * 0.3; // 0.7-1.0
      case VerificationStatus.pending:
        return 0.5 + _random.nextDouble() * 0.4; // 0.5-0.9
      case VerificationStatus.rejected:
        return 0.2 + _random.nextDouble() * 0.4; // 0.2-0.6
      case VerificationStatus.flagged:
        return 0.1 + _random.nextDouble() * 0.5; // 0.1-0.6
    }
  }
  
  static GeoLocation? _generateLocation() {
    final latitude = 20.5937 + (_random.nextDouble() - 0.5) * 10; // Around India
    final longitude = 78.9629 + (_random.nextDouble() - 0.5) * 10;
    
    return GeoLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: _random.nextDouble() * 50,
      address: _generateAddress(),
    );
  }
  
  static String _generateAddress() {
    final cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad'];
    final city = cities[_random.nextInt(cities.length)];
    return 'Site ${_random.nextInt(100)}, Sector ${_random.nextInt(50)}, $city';
  }
  
  static EvidenceMetadata _generateMetadata(EvidenceType type) {
    return EvidenceMetadata(
      cameraModel: type == EvidenceType.photo ? 'Canon EOS 5D' : null,
      capturedBy: _userNames[_random.nextInt(_userNames.length)],
      originalTimestamp: DateTime.now().subtract(Duration(days: _random.nextInt(200))),
      exifData: type == EvidenceType.photo ? {
        'iso': '400',
        'aperture': 'f/2.8',
        'shutterSpeed': '1/250',
      } : null,
      fileHash: _generateHash(),
      fileSize: _random.nextInt(10000000) + 100000,
      mimeType: _getMimeType(type),
    );
  }
  
  static String _generateHash() {
    const chars = '0123456789abcdef';
    return List.generate(64, (_) => chars[_random.nextInt(chars.length)]).join();
  }
  
  static String _getMimeType(EvidenceType type) {
    switch (type) {
      case EvidenceType.photo:
        return 'image/jpeg';
      case EvidenceType.video:
        return 'video/mp4';
      case EvidenceType.document:
      case EvidenceType.invoice:
      case EvidenceType.receipt:
      case EvidenceType.report:
      case EvidenceType.certificate:
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
  
  static String _getFileExtension(EvidenceType type) {
    switch (type) {
      case EvidenceType.photo:
        return 'jpg';
      case EvidenceType.video:
        return 'mp4';
      case EvidenceType.document:
      case EvidenceType.invoice:
      case EvidenceType.receipt:
      case EvidenceType.report:
      case EvidenceType.certificate:
        return 'pdf';
      default:
        return 'dat';
    }
  }
  
  static List<String> _generateTags() {
    final numTags = _random.nextInt(4) + 1;
    final selectedTags = <String>[];
    
    for (int i = 0; i < numTags; i++) {
      final tag = _tags[_random.nextInt(_tags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }
  
  static List<String> _generateRelatedIds(int currentIndex) {
    if (_random.nextDouble() > 0.3) return [];
    
    final numRelated = _random.nextInt(3) + 1;
    return List.generate(
      numRelated,
      (i) => 'EV${((currentIndex + i + 1) % 50 + 1).toString().padLeft(6, '0')}',
    );
  }
  
  static BlockchainAnchor _generateBlockchainAnchor() {
    return BlockchainAnchor(
      transactionHash: '0x${_generateHash().substring(0, 40)}',
      timestamp: DateTime.now().subtract(Duration(minutes: _random.nextInt(10000))),
      blockNumber: (15000000 + _random.nextInt(1000000)).toString(),
      network: 'Ethereum',
    );
  }
  
  static List<String> _generateSuspiciousFlags(VerificationStatus status) {
    if (status != VerificationStatus.flagged) return [];
    
    final flags = [
      'Metadata inconsistency detected',
      'Possible timestamp manipulation',
      'Duplicate content found',
      'Location data mismatch',
      'File hash collision',
      'Unusual upload pattern',
    ];
    
    final numFlags = _random.nextInt(3) + 1;
    final selectedFlags = <String>[];
    
    for (int i = 0; i < numFlags; i++) {
      final flag = flags[_random.nextInt(flags.length)];
      if (!selectedFlags.contains(flag)) {
        selectedFlags.add(flag);
      }
    }
    
    return selectedFlags;
  }
}