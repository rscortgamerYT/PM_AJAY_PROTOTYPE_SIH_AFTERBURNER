import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/citizen_services_models.dart';

/// Service class for Citizen Portal API integration
class CitizenPortalService {
  final String baseUrl;
  final http.Client _client;

  CitizenPortalService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Eligibility Services
  
  /// Check eligibility for PM-AJAY schemes based on user profile
  Future<List<EligibilityCriteria>> checkEligibility(UserProfile userProfile) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/schemes/eligibility'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userProfile.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EligibilityCriteria.fromJson(json)).toList();
      } else {
        throw Exception('Failed to check eligibility: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking eligibility: $e');
    }
  }

  /// Get all available PM-AJAY schemes
  Future<List<EligibilityCriteria>> getAllSchemes() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/schemes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EligibilityCriteria.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch schemes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schemes: $e');
    }
  }

  // Notification Services
  
  /// Get notifications for a specific user
  Future<List<CitizenNotification>> getNotifications(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/notifications/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CitizenNotification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Update notification preferences
  Future<bool> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/notifications/preferences/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(preferences.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating preferences: $e');
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Subscribe to real-time notifications (WebSocket)
  Stream<CitizenNotification> subscribeToNotifications(String userId) async* {
    // WebSocket implementation would go here
    // For now, returning empty stream as placeholder
    yield* const Stream.empty();
  }

  // Application Services
  
  /// Get application status by application ID
  Future<CitizenApplication> getApplicationStatus(String applicationId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/applications/$applicationId/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return CitizenApplication.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch application status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching application status: $e');
    }
  }

  /// Get all applications for a user
  Future<List<CitizenApplication>> getUserApplications(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/applications/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CitizenApplication.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user applications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user applications: $e');
    }
  }

  /// Submit a new application
  Future<CitizenApplication> submitApplication({
    required String userId,
    required String schemeId,
    required ApplicationType type,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/applications/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'schemeId': schemeId,
          'type': type.toString().split('.').last,
          'applicationData': applicationData,
        }),
      );

      if (response.statusCode == 201) {
        return CitizenApplication.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to submit application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting application: $e');
    }
  }

  /// Upload document for an application
  Future<bool> uploadDocument({
    required String applicationId,
    required String documentType,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/applications/$applicationId/documents'),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'document',
        fileBytes,
        filename: fileName,
      ));

      request.fields['documentType'] = documentType;

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  /// Download application receipt
  Future<List<int>> downloadApplicationReceipt(String applicationId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/applications/$applicationId/receipt'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download receipt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading receipt: $e');
    }
  }

  // Infrastructure Services
  
  /// Get infrastructure projects by location
  Future<List<InfrastructureProject>> getInfrastructureProjects({
    required String location,
    ProjectCategory? category,
    ProjectStatus? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'location': location,
        if (category != null) 'category': category.toString().split('.').last,
        if (status != null) 'status': status.toString().split('.').last,
      };

      final uri = Uri.parse('$baseUrl/api/infrastructure/projects')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InfrastructureProject.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch infrastructure projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching infrastructure projects: $e');
    }
  }

  /// Get infrastructure project details
  Future<InfrastructureProject> getProjectDetails(String projectId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/infrastructure/projects/$projectId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return InfrastructureProject.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch project details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching project details: $e');
    }
  }

  /// Get social welfare schemes by location
  Future<List<SocialWelfareScheme>> getSocialWelfareSchemes(String location) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/welfare/schemes?location=$location'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SocialWelfareScheme.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch welfare schemes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching welfare schemes: $e');
    }
  }

  /// Get infrastructure statistics for a location
  Future<Map<String, dynamic>> getInfrastructureStatistics(String location) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/infrastructure/statistics?location=$location'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }

  // User Profile Services
  
  /// Create or update citizen profile
  Future<bool> updateCitizenProfile({
    required String userId,
    required UserProfile profile,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/api/citizens/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating citizen profile: $e');
    }
  }

  /// Get citizen profile
  Future<UserProfile?> getCitizenProfile(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/citizens/$userId/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return UserProfile(
          category: jsonDecode(response.body)['category'],
          annualIncome: jsonDecode(response.body)['annualIncome'],
          age: jsonDecode(response.body)['age'],
          location: jsonDecode(response.body)['location'],
          familySize: jsonDecode(response.body)['familySize'],
          educationLevel: jsonDecode(response.body)['educationLevel'],
          pincode: jsonDecode(response.body)['pincode'],
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch citizen profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching citizen profile: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Mock implementation for testing without backend
class MockCitizenPortalService extends CitizenPortalService {
  MockCitizenPortalService() : super(baseUrl: 'http://localhost:3000');

  @override
  Future<List<EligibilityCriteria>> checkEligibility(UserProfile userProfile) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data based on category
    if (userProfile.category == 'SC') {
      return [
        EligibilityCriteria(
          id: 'adarsh-gram-scholarship',
          name: 'Adarsh Gram Education Scholarship',
          description: 'Educational support for SC students in Adarsh Gram villages',
          benefits: [
            '₹5,000 annually for school students',
            'Free textbooks and uniforms',
            'Merit-based additional grants'
          ],
          requirements: EligibilityRequirements(
            category: 'SC',
            annualIncome: 300000,
            age: AgeRange(min: 6, max: 18),
            location: 'Adarsh Gram designated villages',
            educationLevel: 'School',
          ),
        ),
      ];
    }
    
    return [];
  }

  @override
  Future<List<CitizenNotification>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      CitizenNotification(
        id: '1',
        type: NotificationType.deadline,
        title: 'Scholarship Application Deadline Approaching',
        message: 'The deadline for PM-AJAY Adarsh Gram Education Scholarship is in 5 days.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        priority: NotificationPriority.high,
        location: 'Wardha, Maharashtra',
        actionRequired: true,
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<List<CitizenApplication>> getUserApplications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [];
  }

  @override
  Future<List<InfrastructureProject>> getInfrastructureProjects({
    required String location,
    ProjectCategory? category,
    ProjectStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [];
  }
}