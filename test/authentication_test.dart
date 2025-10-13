import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay_platform/main.dart';
import 'package:pm_ajay_platform/core/providers/auth_provider.dart';
import 'package:pm_ajay_platform/core/models/user_model.dart';

void main() {
  group('Authentication Tests', () {
    testWidgets('Login page loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );
      
      // Verify login page elements
      expect(find.text('PM-AJAY Dashboard'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Authentication with valid Centre Admin credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      // Enter Centre Admin credentials
      await tester.enterText(find.byType(TextFormField).first, 'centre@pmajay.gov.in');
      await tester.enterText(find.byType(TextFormField).last, 'centre123');
      
      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify navigation to Centre Dashboard
      expect(find.text('Centre Admin Portal'), findsOneWidget);
    });

    testWidgets('Authentication with valid State Admin credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'state@pmajay.gov.in');
      await tester.enterText(find.byType(TextFormField).last, 'state123');
      
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('State Admin Portal'), findsOneWidget);
    });

    testWidgets('Authentication with valid Agency Admin credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'agency@pmajay.gov.in');
      await tester.enterText(find.byType(TextFormField).last, 'agency123');
      
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Agency Admin Portal'), findsOneWidget);
    });

    testWidgets('Authentication with valid Overwatch credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'overwatch@pmajay.gov.in');
      await tester.enterText(find.byType(TextFormField).last, 'overwatch123');
      
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Overwatch Portal'), findsOneWidget);
    });

    testWidgets('Authentication with invalid credentials shows error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalid@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Empty email field validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Empty password field validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PMAjayApp(),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    test('AuthProvider state management', () {
      final container = ProviderContainer();
      
      // Test initial state
      final initialState = container.read(authProvider);
      expect(initialState.user, null);
      expect(initialState.isAuthenticated, false);
      
      // Test setting user via sign in
      container.read(authProvider.notifier).signIn('centre@pmajay.gov.in', 'centre123');
      
      container.dispose();
    });

    test('User role validation', () {
      final centreUser = UserModel(
        id: '1',
        email: 'centre@pmajay.gov.in',
        role: UserRole.centreAdmin,
        fullName: 'Centre Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(centreUser.role, UserRole.centreAdmin);
      expect(centreUser.email, 'centre@pmajay.gov.in');
      
      final stateUser = UserModel(
        id: '2',
        email: 'state@pmajay.gov.in',
        role: UserRole.stateOfficer,
        fullName: 'State Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(stateUser.role, UserRole.stateOfficer);
      expect(stateUser.email, 'state@pmajay.gov.in');
    });

    test('UserRole enum validation', () {
      expect(UserRole.centreAdmin.value, 'centre_admin');
      expect(UserRole.stateOfficer.value, 'state_officer');
      expect(UserRole.agencyUser.value, 'agency_user');
      expect(UserRole.overwatch.value, 'overwatch');
      expect(UserRole.public.value, 'public');
      
      expect(UserRole.fromString('centre_admin'), UserRole.centreAdmin);
      expect(UserRole.fromString('invalid_role'), UserRole.public);
    });
  });
}