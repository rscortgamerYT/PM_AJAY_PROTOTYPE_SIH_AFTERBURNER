import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay_platform/main.dart';
import 'package:pm_ajay_platform/core/providers/auth_provider.dart';
import 'package:pm_ajay_platform/core/models/user_model.dart';

void main() {
  group('Navigation & Dashboard Tests', () {
    testWidgets('Dashboard switcher displays for authenticated users', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      // Create authenticated user
      final testUser = UserModel(
        id: 'test-user',
        email: 'overwatch@pmajay.gov.in',
        role: UserRole.overwatch,
        fullName: 'Test Overwatch User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).updateUser(testUser);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard switcher is present
      expect(find.byType(PopupMenuButton), findsWidgets);
      
      container.dispose();
    });

    testWidgets('Bottom navigation shows 5 sections for Overwatch role', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final overwatchUser = UserModel(
        id: 'overwatch-user',
        email: 'overwatch@pmajay.gov.in',
        role: UserRole.overwatch,
        fullName: 'Overwatch Monitor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).updateUser(overwatchUser);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify 5 navigation sections are present
      expect(find.text('Overview'), findsWidgets);
      expect(find.text('Claims'), findsWidgets);
      expect(find.text('Fund Flow'), findsWidgets);
      expect(find.text('Fraud & Command'), findsWidgets);
      expect(find.text('Archive'), findsWidgets);
      
      container.dispose();
    });

    testWidgets('Navigation between sections works correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      final overwatchUser = UserModel(
        id: 'overwatch-user',
        email: 'overwatch@pmajay.gov.in',
        role: UserRole.overwatch,
        fullName: 'Overwatch Monitor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      container.read(authProvider.notifier).updateUser(overwatchUser);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test navigation to Claims section
      await tester.tap(find.text('Claims'));
      await tester.pumpAndSettle();
      
      // Test navigation to Fund Flow section
      await tester.tap(find.text('Fund Flow'));
      await tester.pumpAndSettle();
      
      // Test navigation back to Overview
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      
      container.dispose();
    });

    test('UserRole enum string conversion works correctly', () {
      expect(UserRole.centreAdmin.value, 'centre_admin');
      expect(UserRole.stateOfficer.value, 'state_officer');
      expect(UserRole.agencyUser.value, 'agency_user');
      expect(UserRole.overwatch.value, 'overwatch');
      expect(UserRole.public.value, 'public');
      
      expect(UserRole.fromString('centre_admin'), UserRole.centreAdmin);
      expect(UserRole.fromString('state_officer'), UserRole.stateOfficer);
      expect(UserRole.fromString('agency_user'), UserRole.agencyUser);
      expect(UserRole.fromString('overwatch'), UserRole.overwatch);
      expect(UserRole.fromString('public'), UserRole.public);
      expect(UserRole.fromString('invalid_role'), UserRole.public);
    });

    test('AuthState management works correctly', () {
      const initialState = AuthState();
      expect(initialState.user, null);
      expect(initialState.isAuthenticated, false);
      expect(initialState.isLoading, false);
      expect(initialState.error, null);

      final testUser = UserModel(
        id: 'test-123',
        email: 'test@pmajay.gov.in',
        role: UserRole.centreAdmin,
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final authenticatedState = initialState.copyWith(
        user: testUser,
        isAuthenticated: true,
      );

      expect(authenticatedState.user, testUser);
      expect(authenticatedState.isAuthenticated, true);
      expect(authenticatedState.isLoading, false);
      expect(authenticatedState.error, null);

      final loadingState = authenticatedState.copyWith(
        isLoading: true,
      );

      expect(loadingState.user, testUser);
      expect(loadingState.isAuthenticated, true);
      expect(loadingState.isLoading, true);
      expect(loadingState.error, null);
    });

    testWidgets('Role-based dashboard content displays correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      // Test Centre Admin dashboard
      final centreUser = UserModel(
        id: 'centre-user',
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
          child: const PMAjayApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Centre Admin specific content
      expect(find.textContaining('Centre'), findsWidgets);
      
      container.dispose();
    });
  });
}