// Citizen Services Models for PM-AJAY Public Dashboard

/// Eligibility Models
class EligibilityCriteria {
  final String id;
  final String name;
  final String description;
  final List<String> benefits;
  final EligibilityRequirements requirements;

  EligibilityCriteria({
    required this.id,
    required this.name,
    required this.description,
    required this.benefits,
    required this.requirements,
  });

  factory EligibilityCriteria.fromJson(Map<String, dynamic> json) {
    return EligibilityCriteria(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      benefits: (json['benefits'] as List).map((e) => e as String).toList(),
      requirements: EligibilityRequirements.fromJson(json['requirements'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'benefits': benefits,
      'requirements': requirements.toJson(),
    };
  }
}

class EligibilityRequirements {
  final String category; // SC, ST, OBC, General
  final int annualIncome;
  final AgeRange? age;
  final String location;
  final int? familySize;
  final String? educationLevel;

  EligibilityRequirements({
    required this.category,
    required this.annualIncome,
    this.age,
    required this.location,
    this.familySize,
    this.educationLevel,
  });

  factory EligibilityRequirements.fromJson(Map<String, dynamic> json) {
    return EligibilityRequirements(
      category: json['category'] as String,
      annualIncome: json['annualIncome'] as int,
      age: json['age'] != null ? AgeRange.fromJson(json['age'] as Map<String, dynamic>) : null,
      location: json['location'] as String,
      familySize: json['familySize'] as int?,
      educationLevel: json['educationLevel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'annualIncome': annualIncome,
      if (age != null) 'age': age!.toJson(),
      'location': location,
      if (familySize != null) 'familySize': familySize,
      if (educationLevel != null) 'educationLevel': educationLevel,
    };
  }
}

class AgeRange {
  final int min;
  final int max;

  AgeRange({required this.min, required this.max});

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      min: json['min'] as int,
      max: json['max'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

class UserProfile {
  final String category;
  final int annualIncome;
  final int age;
  final String location;
  final int familySize;
  final String educationLevel;
  final String pincode;

  UserProfile({
    required this.category,
    required this.annualIncome,
    required this.age,
    required this.location,
    required this.familySize,
    required this.educationLevel,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'annualIncome': annualIncome,
      'age': age,
      'location': location,
      'familySize': familySize,
      'educationLevel': educationLevel,
      'pincode': pincode,
    };
  }
}

/// Notification Models
class CitizenNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationPriority priority;
  final String? location;
  final bool actionRequired;
  final DateTime? expiryDate;
  final bool read;

  CitizenNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.priority,
    this.location,
    this.actionRequired = false,
    this.expiryDate,
    this.read = false,
  });

  factory CitizenNotification.fromJson(Map<String, dynamic> json) {
    return CitizenNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      location: json['location'] as String?,
      actionRequired: json['actionRequired'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.toString().split('.').last,
      if (location != null) 'location': location,
      'actionRequired': actionRequired,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'read': read,
    };
  }
}

enum NotificationType {
  deadline,
  fundRelease,
  projectUpdate,
  newScheme,
  localEvent
}

enum NotificationPriority {
  high,
  medium,
  low
}

class NotificationPreferences {
  final bool sms;
  final bool email;
  final bool whatsapp;
  final bool push;
  final NotificationCategories categories;

  NotificationPreferences({
    required this.sms,
    required this.email,
    required this.whatsapp,
    required this.push,
    required this.categories,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      sms: json['sms'] as bool,
      email: json['email'] as bool,
      whatsapp: json['whatsapp'] as bool,
      push: json['push'] as bool,
      categories: NotificationCategories.fromJson(json['categories'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sms': sms,
      'email': email,
      'whatsapp': whatsapp,
      'push': push,
      'categories': categories.toJson(),
    };
  }
}

class NotificationCategories {
  final bool deadlines;
  final bool fundReleases;
  final bool projectUpdates;
  final bool newSchemes;
  final bool localEvents;

  NotificationCategories({
    required this.deadlines,
    required this.fundReleases,
    required this.projectUpdates,
    required this.newSchemes,
    required this.localEvents,
  });

  factory NotificationCategories.fromJson(Map<String, dynamic> json) {
    return NotificationCategories(
      deadlines: json['deadlines'] as bool,
      fundReleases: json['fundReleases'] as bool,
      projectUpdates: json['projectUpdates'] as bool,
      newSchemes: json['newSchemes'] as bool,
      localEvents: json['localEvents'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deadlines': deadlines,
      'fundReleases': fundReleases,
      'projectUpdates': projectUpdates,
      'newSchemes': newSchemes,
      'localEvents': localEvents,
    };
  }
}

/// Application Models
class CitizenApplication {
  final String id;
  final ApplicationType type;
  final String schemeName;
  final DateTime submissionDate;
  final ApplicationStatus status;
  final int currentStage;
  final int totalStages;
  final DateTime lastUpdateDate;
  final DateTime estimatedCompletionDate;
  final ContactPerson? contactPerson;
  final List<ApplicationDocument> documents;
  final DisbursementDetails? disbursementDetails;
  final List<TimelineEvent> timeline;

  CitizenApplication({
    required this.id,
    required this.type,
    required this.schemeName,
    required this.submissionDate,
    required this.status,
    required this.currentStage,
    required this.totalStages,
    required this.lastUpdateDate,
    required this.estimatedCompletionDate,
    this.contactPerson,
    required this.documents,
    this.disbursementDetails,
    required this.timeline,
  });

  factory CitizenApplication.fromJson(Map<String, dynamic> json) {
    return CitizenApplication(
      id: json['id'] as String,
      type: ApplicationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      schemeName: json['schemeName'] as String,
      submissionDate: DateTime.parse(json['submissionDate'] as String),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      currentStage: json['currentStage'] as int,
      totalStages: json['totalStages'] as int,
      lastUpdateDate: DateTime.parse(json['lastUpdateDate'] as String),
      estimatedCompletionDate: DateTime.parse(json['estimatedCompletionDate'] as String),
      contactPerson: json['contactPerson'] != null
          ? ContactPerson.fromJson(json['contactPerson'] as Map<String, dynamic>)
          : null,
      documents: (json['documents'] as List)
          .map((e) => ApplicationDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      disbursementDetails: json['disbursementDetails'] != null
          ? DisbursementDetails.fromJson(json['disbursementDetails'] as Map<String, dynamic>)
          : null,
      timeline: (json['timeline'] as List)
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'schemeName': schemeName,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'currentStage': currentStage,
      'totalStages': totalStages,
      'lastUpdateDate': lastUpdateDate.toIso8601String(),
      'estimatedCompletionDate': estimatedCompletionDate.toIso8601String(),
      if (contactPerson != null) 'contactPerson': contactPerson!.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
      if (disbursementDetails != null) 'disbursementDetails': disbursementDetails!.toJson(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}

enum ApplicationType {
  scholarship,
  hostel,
  skillTraining,
  businessGrant
}

enum ApplicationStatus {
  submitted,
  underReview,
  documentsRequired,
  approved,
  rejected,
  disbursed
}

class ContactPerson {
  final String name;
  final String designation;
  final String phone;
  final String email;

  ContactPerson({
    required this.name,
    required this.designation,
    required this.phone,
    required this.email,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      name: json['name'] as String,
      designation: json['designation'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'phone': phone,
      'email': email,
    };
  }
}

class ApplicationDocument {
  final String name;
  final DocumentStatus status;
  final String? rejectionReason;

  ApplicationDocument({
    required this.name,
    required this.status,
    this.rejectionReason,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      name: json['name'] as String,
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status.toString().split('.').last,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}

enum DocumentStatus {
  pending,
  submitted,
  verified,
  rejected
}

class DisbursementDetails {
  final int amount;
  final List<Installment> installments;

  DisbursementDetails({
    required this.amount,
    required this.installments,
  });

  factory DisbursementDetails.fromJson(Map<String, dynamic> json) {
    return DisbursementDetails(
      amount: json['amount'] as int,
      installments: (json['installments'] as List)
          .map((e) => Installment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'installments': installments.map((e) => e.toJson()).toList(),
    };
  }
}

class Installment {
  final int installmentNumber;
  final int amount;
  final DateTime dueDate;
  final InstallmentStatus status;
  final DateTime? disbursedDate;
  final String? transactionId;

  Installment({
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.disbursedDate,
    this.transactionId,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      installmentNumber: json['installmentNumber'] as int,
      amount: json['amount'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: InstallmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      disbursedDate: json['disbursedDate'] != null
          ? DateTime.parse(json['disbursedDate'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      if (disbursedDate != null) 'disbursedDate': disbursedDate!.toIso8601String(),
      if (transactionId != null) 'transactionId': transactionId,
    };
  }
}

enum InstallmentStatus {
  pending,
  disbursed
}

class TimelineEvent {
  final String stage;
  final DateTime? date;
  final TimelineStatus status;
  final String? comments;

  TimelineEvent({
    required this.stage,
    this.date,
    required this.status,
    this.comments,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      stage: json['stage'] as String,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      status: TimelineStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      if (date != null) 'date': date!.toIso8601String(),
      'status': status.toString().split('.').last,
      if (comments != null) 'comments': comments,
    };
  }
}

enum TimelineStatus {
  completed,
  current,
  pending
}

/// Infrastructure Models
class InfrastructureProject {
  final String id;
  final ProjectCategory category;
  final String name;
  final String description;
  final ProjectStatus status;
  final int progress;
  final ProjectBudget budget;
  final ProjectTimeline timeline;
  final int beneficiaries;
  final String? contractor;
  final List<String> images;

  InfrastructureProject({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.status,
    required this.progress,
    required this.budget,
    required this.timeline,
    required this.beneficiaries,
    this.contractor,
    this.images = const [],
  });

  factory InfrastructureProject.fromJson(Map<String, dynamic> json) {
    return InfrastructureProject(
      id: json['id'] as String,
      category: ProjectCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      progress: json['progress'] as int,
      budget: ProjectBudget.fromJson(json['budget'] as Map<String, dynamic>),
      timeline: ProjectTimeline.fromJson(json['timeline'] as Map<String, dynamic>),
      beneficiaries: json['beneficiaries'] as int,
      contractor: json['contractor'] as String?,
      images: (json['images'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toString().split('.').last,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'progress': progress,
      'budget': budget.toJson(),
      'timeline': timeline.toJson(),
      'beneficiaries': beneficiaries,
      if (contractor != null) 'contractor': contractor,
      'images': images,
    };
  }
}

enum ProjectCategory {
  sanitation,
  water,
  roads,
  electricity,
  healthcare,
  education
}

enum ProjectStatus {
  planning,
  ongoing,
  completed,
  delayed
}

class ProjectBudget {
  final int allocated;
  final int utilized;

  ProjectBudget({
    required this.allocated,
    required this.utilized,
  });

  factory ProjectBudget.fromJson(Map<String, dynamic> json) {
    return ProjectBudget(
      allocated: json['allocated'] as int,
      utilized: json['utilized'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'allocated': allocated,
        'utilized': utilized,
      };
}

class ProjectTimeline {
  final DateTime startDate;
  final DateTime expectedEndDate;
  final DateTime? actualEndDate;

  ProjectTimeline({
    required this.startDate,
    required this.expectedEndDate,
    this.actualEndDate,
  });

  factory ProjectTimeline.fromJson(Map<String, dynamic> json) {
    return ProjectTimeline(
      startDate: DateTime.parse(json['startDate'] as String),
      expectedEndDate: DateTime.parse(json['expectedEndDate'] as String),
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.parse(json['actualEndDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      if (actualEndDate != null) 'actualEndDate': actualEndDate!.toIso8601String(),
    };
  }
}

class SocialWelfareScheme {
  final String id;
  final String name;
  final WelfareType type;
  final Beneficiaries beneficiaries;
  final WelfareBudget budget;
  final DateTime lastUpdate;

  SocialWelfareScheme({
    required this.id,
    required this.name,
    required this.type,
    required this.beneficiaries,
    required this.budget,
    required this.lastUpdate,
  });

  factory SocialWelfareScheme.fromJson(Map<String, dynamic> json) {
    return SocialWelfareScheme(
      id: json['id'] as String,
      name: json['name'] as String,
      type: WelfareType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      beneficiaries: Beneficiaries.fromJson(json['beneficiaries'] as Map<String, dynamic>),
      budget: WelfareBudget.fromJson(json['budget'] as Map<String, dynamic>),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'beneficiaries': beneficiaries.toJson(),
      'budget': budget.toJson(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

enum WelfareType {
  pension,
  healthcare,
  foodSecurity,
  housing,
  employment
}

class Beneficiaries {
  final int target;
  final int enrolled;
  final int active;

  Beneficiaries({
    required this.target,
    required this.enrolled,
    required this.active,
  });

  factory Beneficiaries.fromJson(Map<String, dynamic> json) {
    return Beneficiaries(
      target: json['target'] as int,
      enrolled: json['enrolled'] as int,
      active: json['active'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'target': target,
        'enrolled': enrolled,
        'active': active,
      };
}

class WelfareBudget {
  final int allocated;
  final int disbursed;

  WelfareBudget({
    required this.allocated,
    required this.disbursed,
  });

  factory WelfareBudget.fromJson(Map<String, dynamic> json) {
    return WelfareBudget(
      allocated: json['allocated'] as int,
      disbursed: json['disbursed'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'allocated': allocated,
        'disbursed': disbursed,
      };
}