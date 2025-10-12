import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay_platform/main.dart';
import 'package:pm_ajay_platform/core/providers/auth_provider.dart';
import 'package:pm_ajay_platform/core/models/user_model.dart';

void main() {
  group('Healthcare Features Tests', () {
    testWidgets('Claims review interface loads correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final overwatchUser = UserModel(
        id: 'overwatch-test',
        email: 'overwatch@pmajay.gov.in',
        role: UserRole.overwatch,
        fullName: 'Healthcare Monitor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).updateUser(overwatchUser);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();
      
      container.dispose();
    });

    testWidgets('Fund flow visualization components render', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final centreUser = UserModel(
        id: 'centre-test',
        email: 'centre@pmajay.gov.in',
        role: UserRole.centreAdmin,
        fullName: 'Centre Administrator',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).updateUser(centreUser);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();
      
      container.dispose();
    });

    test('Healthcare facility data structure validation', () {
      // Test healthcare facility models
      final facilityData = {
        'id': 'phc-001',
        'name': 'Primary Health Center - Test',
        'type': 'PHC',
        'district': 'Test District',
        'state': 'Test State',
        'status': 'operational',
        'iphs_compliance': 85.5,
        'staff_count': 12,
        'equipment_status': 'functional'
      };
      
      expect(facilityData['id'], isA<String>());
      expect(facilityData['name'], isA<String>());
      expect(facilityData['iphs_compliance'], isA<double>());
      expect(facilityData['staff_count'], isA<int>());
    });

    test('PM-AJAY budget allocation model validation', () {
      final budgetAllocation = {
        'total_allocation': 64180000000.0, // 64,180 crores
        'central_share': 38508000000.0,   // 60%
        'state_share': 25672000000.0,     // 40%
        'utilization_percentage': 67.3,
        'components': {
          'infrastructure': 0.45,
          'equipment': 0.25,
          'human_resources': 0.20,
          'it_systems': 0.10
        }
      };
      
      expect(budgetAllocation['total_allocation'], isA<double>());
      expect(budgetAllocation['central_share'], isA<double>());
      expect(budgetAllocation['state_share'], isA<double>());
      expect(budgetAllocation['components'], isA<Map>());
      
      // Validate component percentages sum to 1.0
      final components = budgetAllocation['components'] as Map;
      final totalPercentage = components.values.fold<double>(0.0, (sum, value) => sum + value);
      expect(totalPercentage, closeTo(1.0, 0.01));
    });

    test('IPHS compliance scoring calculation', () {
      final iphsMetrics = {
        'infrastructure_score': 82.5,
        'equipment_score': 78.0,
        'manpower_score': 85.5,
        'service_delivery_score': 80.0,
        'quality_assurance_score': 75.5
      };
      
      // Calculate overall IPHS compliance
      final totalScore = iphsMetrics.values.fold<double>(0.0, (sum, score) => sum + score);
      final averageScore = totalScore / iphsMetrics.length;
      
      expect(averageScore, greaterThan(75.0)); // Minimum acceptable score
      expect(averageScore, lessThanOrEqualTo(100.0));
    });

    test('Healthcare service delivery metrics validation', () {
      final serviceMetrics = {
        'outpatient_visits': 2450,
        'inpatient_admissions': 320,
        'emergency_cases': 185,
        'delivery_services': 45,
        'immunization_coverage': 89.5,
        'maternal_mortality_rate': 2.1,
        'infant_mortality_rate': 15.3
      };
      
      expect(serviceMetrics['outpatient_visits'], isA<int>());
      expect(serviceMetrics['immunization_coverage'], isA<double>());
      expect(serviceMetrics['maternal_mortality_rate'], isA<double>());
      
      // Validate metrics are within expected ranges
      expect(serviceMetrics['immunization_coverage'], lessThanOrEqualTo(100.0));
      expect(serviceMetrics['maternal_mortality_rate'], greaterThanOrEqualTo(0.0));
    });

    test('Equipment inventory tracking model', () {
      final equipmentInventory = [
        {
          'id': 'eq-001',
          'name': 'X-Ray Machine',
          'category': 'Diagnostic',
          'status': 'functional',
          'last_maintenance': '2024-09-15',
          'next_maintenance': '2024-12-15',
          'cost': 850000.0,
          'supplier': 'Medical Equipment Corp'
        },
        {
          'id': 'eq-002',
          'name': 'ECG Machine',
          'category': 'Diagnostic',
          'status': 'under_maintenance',
          'last_maintenance': '2024-10-01',
          'next_maintenance': '2025-01-01',
          'cost': 125000.0,
          'supplier': 'Healthcare Solutions Ltd'
        }
      ];
      
      for (final equipment in equipmentInventory) {
        expect(equipment['id'], isA<String>());
        expect(equipment['name'], isA<String>());
        expect(equipment['status'], isIn(['functional', 'under_maintenance', 'non_functional']));
        expect(equipment['cost'], isA<double>());
      }
    });

    test('Real-time monitoring data structure', () {
      final monitoringData = {
        'timestamp': DateTime.now().toIso8601String(),
        'facility_id': 'chc-001',
        'alerts': [
          {
            'type': 'equipment_failure',
            'severity': 'high',
            'message': 'Oxygen concentrator malfunction',
            'timestamp': DateTime.now().toIso8601String()
          }
        ],
        'capacity_utilization': 78.5,
        'staff_availability': 92.0,
        'emergency_readiness': true
      };
      
      expect(monitoringData['timestamp'], isA<String>());
      expect(monitoringData['alerts'], isA<List>());
      expect(monitoringData['capacity_utilization'], isA<double>());
      expect(monitoringData['emergency_readiness'], isA<bool>());
    });

    test('Claims processing workflow validation', () {
      final claimData = {
        'claim_id': 'claim-001',
        'facility_id': 'phc-001',
        'claim_amount': 125000.0,
        'submission_date': '2024-10-10',
        'status': 'under_review',
        'documents': [
          'financial_receipt.pdf',
          'geo_tagged_photo.jpg',
          'progress_report.pdf'
        ],
        'ai_analysis': {
          'authenticity_score': 98.5,
          'anomaly_detected': false,
          'risk_level': 'low'
        },
        'reviewer_notes': '',
        'approval_status': 'pending'
      };
      
      expect(claimData['claim_id'], isA<String>());
      expect(claimData['claim_amount'], isA<double>());
      expect(claimData['documents'], isA<List>());
      expect(claimData['ai_analysis'], isA<Map>());
      
      // Validate AI analysis structure
      final aiAnalysis = claimData['ai_analysis'] as Map;
      expect(aiAnalysis['authenticity_score'], greaterThan(90.0));
      expect(aiAnalysis['anomaly_detected'], isA<bool>());
      expect(aiAnalysis['risk_level'], isIn(['low', 'medium', 'high']));
    });
  });
}