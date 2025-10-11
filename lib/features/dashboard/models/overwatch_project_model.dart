import 'package:flutter/material.dart';

/// Project status for Overwatch dashboard
enum OverwatchProjectStatus {
  active,
  completed,
  delayed,
  flagged;

  String get label {
    switch (this) {
      case OverwatchProjectStatus.active:
        return 'Active';
      case OverwatchProjectStatus.completed:
        return 'Completed';
      case OverwatchProjectStatus.delayed:
        return 'Delayed';
      case OverwatchProjectStatus.flagged:
        return 'Flagged';
    }
  }

  Color get color {
    switch (this) {
      case OverwatchProjectStatus.active:
        return const Color(0xFF10B981); // Green
      case OverwatchProjectStatus.completed:
        return const Color(0xFF3B82F6); // Blue
      case OverwatchProjectStatus.delayed:
        return const Color(0xFFF59E0B); // Yellow
      case OverwatchProjectStatus.flagged:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case OverwatchProjectStatus.active:
        return Icons.play_circle_outline;
      case OverwatchProjectStatus.completed:
        return Icons.check_circle_outline;
      case OverwatchProjectStatus.delayed:
        return Icons.access_time;
      case OverwatchProjectStatus.flagged:
        return Icons.flag_outlined;
    }
  }
}

/// Project component type
enum ProjectComponentType {
  adarshGram('adarsh_gram', 'Adarsh Gram'),
  gia('gia', 'GIA'),
  hostel('hostel', 'Hostel');

  final String value;
  final String label;
  const ProjectComponentType(this.value, this.label);

  static ProjectComponentType fromString(String value) {
    return ProjectComponentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProjectComponentType.adarshGram,
    );
  }
}

/// Risk level for project assessment
enum RiskLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return const Color(0xFF10B981); // Green
      case RiskLevel.medium:
        return const Color(0xFFF59E0B); // Yellow
      case RiskLevel.high:
        return const Color(0xFFEF4444); // Red
    }
  }

  int get barCount {
    switch (this) {
      case RiskLevel.low:
        return 1;
      case RiskLevel.medium:
        return 2;
      case RiskLevel.high:
        return 3;
    }
  }
}

/// Responsible person details
class ResponsiblePerson {
  final String name;
  final String designation;
  final String contact;
  final String empId;
  final String? email;
  final String? department;

  ResponsiblePerson({
    required this.name,
    required this.designation,
    required this.contact,
    required this.empId,
    this.email,
    this.department,
  });

  factory ResponsiblePerson.fromJson(Map<String, dynamic> json) {
    return ResponsiblePerson(
      name: json['name'] as String,
      designation: json['designation'] as String,
      contact: json['contact'] as String,
      empId: json['emp_id'] as String,
      email: json['email'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'contact': contact,
      'emp_id': empId,
      'email': email,
      'department': department,
    };
  }
}

/// Enhanced project model for Overwatch dashboard
class OverwatchProject {
  final String id;
  final String name;
  final String agency;
  final String state;
  final String? district;
  final ProjectComponentType component;
  final double totalFunds;
  final double utilizedFunds;
  final double allocatedFunds;
  final OverwatchProjectStatus status;
  final double riskScore;
  final RiskLevel riskLevel;
  final double progress;
  final String? location;
  final String? timeline;
  final ResponsiblePerson? responsiblePerson;
  final DateTime? lastUpdate;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> flags;
  final Map<String, dynamic> metadata;

  OverwatchProject({
    required this.id,
    required this.name,
    required this.agency,
    required this.state,
    this.district,
    required this.component,
    required this.totalFunds,
    required this.utilizedFunds,
    required this.allocatedFunds,
    required this.status,
    required this.riskScore,
    required this.riskLevel,
    required this.progress,
    this.location,
    this.timeline,
    this.responsiblePerson,
    this.lastUpdate,
    this.startDate,
    this.endDate,
    this.flags = const [],
    this.metadata = const {},
  });

  double get utilizationPercentage => 
      totalFunds > 0 ? (utilizedFunds / totalFunds) * 100 : 0;

  double get remainingFunds => totalFunds - utilizedFunds;

  bool get isCritical => riskLevel == RiskLevel.high || status == OverwatchProjectStatus.flagged;

  factory OverwatchProject.fromJson(Map<String, dynamic> json) {
    final riskScore = (json['risk_score'] as num?)?.toDouble() ?? 0.0;
    final riskLevel = riskScore >= 8.0
        ? RiskLevel.high
        : riskScore >= 5.0
            ? RiskLevel.medium
            : RiskLevel.low;

    return OverwatchProject(
      id: json['id'] as String,
      name: json['name'] as String,
      agency: json['agency'] as String,
      state: json['state'] as String,
      district: json['district'] as String?,
      component: ProjectComponentType.fromString(json['component'] as String),
      totalFunds: (json['total_funds'] as num).toDouble(),
      utilizedFunds: (json['utilized_funds'] as num).toDouble(),
      allocatedFunds: (json['allocated_funds'] as num?)?.toDouble() ?? 
          (json['total_funds'] as num).toDouble(),
      status: OverwatchProjectStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OverwatchProjectStatus.active,
      ),
      riskScore: riskScore,
      riskLevel: riskLevel,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String?,
      timeline: json['timeline'] as String?,
      responsiblePerson: json['responsible_person'] != null
          ? ResponsiblePerson.fromJson(json['responsible_person'] as Map<String, dynamic>)
          : null,
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      flags: json['flags'] != null
          ? List<String>.from(json['flags'] as List)
          : [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'agency': agency,
      'state': state,
      'district': district,
      'component': component.value,
      'total_funds': totalFunds,
      'utilized_funds': utilizedFunds,
      'allocated_funds': allocatedFunds,
      'status': status.name,
      'risk_score': riskScore,
      'progress': progress,
      'location': location,
      'timeline': timeline,
      'responsible_person': responsiblePerson?.toJson(),
      'last_update': lastUpdate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'flags': flags,
      'metadata': metadata,
    };
  }

  OverwatchProject copyWith({
    String? id,
    String? name,
    String? agency,
    String? state,
    String? district,
    ProjectComponentType? component,
    double? totalFunds,
    double? utilizedFunds,
    double? allocatedFunds,
    OverwatchProjectStatus? status,
    double? riskScore,
    RiskLevel? riskLevel,
    double? progress,
    String? location,
    String? timeline,
    ResponsiblePerson? responsiblePerson,
    DateTime? lastUpdate,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? flags,
    Map<String, dynamic>? metadata,
  }) {
    return OverwatchProject(
      id: id ?? this.id,
      name: name ?? this.name,
      agency: agency ?? this.agency,
      state: state ?? this.state,
      district: district ?? this.district,
      component: component ?? this.component,
      totalFunds: totalFunds ?? this.totalFunds,
      utilizedFunds: utilizedFunds ?? this.utilizedFunds,
      allocatedFunds: allocatedFunds ?? this.allocatedFunds,
      status: status ?? this.status,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      progress: progress ?? this.progress,
      location: location ?? this.location,
      timeline: timeline ?? this.timeline,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flags: flags ?? this.flags,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Project filter criteria
class ProjectFilterCriteria {
  final String? searchTerm;
  final List<OverwatchProjectStatus>? statuses;
  final List<ProjectComponentType>? components;
  final List<String>? states;
  final RiskLevel? minRiskLevel;
  final double? minProgress;
  final double? maxProgress;

  ProjectFilterCriteria({
    this.searchTerm,
    this.statuses,
    this.components,
    this.states,
    this.minRiskLevel,
    this.minProgress,
    this.maxProgress,
  });

  bool matches(OverwatchProject project) {
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      final term = searchTerm!.toLowerCase();
      if (!project.name.toLowerCase().contains(term) &&
          !project.agency.toLowerCase().contains(term) &&
          !project.state.toLowerCase().contains(term)) {
        return false;
      }
    }

    if (statuses != null && statuses!.isNotEmpty) {
      if (!statuses!.contains(project.status)) return false;
    }

    if (components != null && components!.isNotEmpty) {
      if (!components!.contains(project.component)) return false;
    }

    if (states != null && states!.isNotEmpty) {
      if (!states!.contains(project.state)) return false;
    }

    if (minRiskLevel != null) {
      if (project.riskLevel.index < minRiskLevel!.index) return false;
    }

    if (minProgress != null && project.progress < minProgress!) {
      return false;
    }

    if (maxProgress != null && project.progress > maxProgress!) {
      return false;
    }

    return true;
  }
}