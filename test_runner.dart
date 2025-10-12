import 'dart:io';

/// Comprehensive test runner for PM-AJAY Dashboard
/// Executes all test suites and generates consolidated report
void main() async {
  print('\n🏥 PM-AJAY Dashboard Testing Framework');
  print('=' * 50);
  
  final testResults = <String, TestResult>{};
  
  // Test suites to execute
  final testSuites = [
    'test/authentication_test.dart',
    'test/navigation_test.dart', 
    'test/healthcare_features_test.dart',
  ];
  
  for (final suite in testSuites) {
    print('\n📋 Running: ${suite.split('/').last}');
    print('-' * 30);
    
    final result = await runTestSuite(suite);
    testResults[suite] = result;
    
    print('Status: ${result.success ? "✅ PASSED" : "❌ FAILED"}');
    print('Tests: ${result.passed}/${result.total}');
    if (result.errors.isNotEmpty) {
      print('Errors: ${result.errors.length}');
    }
  }
  
  // Generate summary report
  generateSummaryReport(testResults);
}

Future<TestResult> runTestSuite(String suitePath) async {
  try {
    final result = await Process.run(
      'flutter',
      ['test', suitePath],
      workingDirectory: '.',
    );
    
    return parseTestOutput(result.stdout.toString(), result.stderr.toString());
  } catch (e) {
    return TestResult(
      total: 0,
      passed: 0,
      failed: 0,
      success: false,
      errors: ['Failed to execute test: $e'],
    );
  }
}

TestResult parseTestOutput(String stdout, String stderr) {
  final lines = stdout.split('\n');
  int total = 0;
  int passed = 0;
  int failed = 0;
  final errors = <String>[];
  
  for (final line in lines) {
    if (line.contains('+') && line.contains('-')) {
      // Parse Flutter test result line like "00:27 +3 -8:"
      final match = RegExp(r'\+(\d+)\s+-(\d+)').firstMatch(line);
      if (match != null) {
        passed = int.parse(match.group(1) ?? '0');
        failed = int.parse(match.group(2) ?? '0');
        total = passed + failed;
      }
    }
    
    if (line.contains('Error:') || line.contains('Exception:')) {
      errors.add(line.trim());
    }
  }
  
  if (stderr.isNotEmpty) {
    errors.addAll(stderr.split('\n').where((line) => line.trim().isNotEmpty));
  }
  
  return TestResult(
    total: total,
    passed: passed,
    failed: failed,
    success: failed == 0 && total > 0,
    errors: errors,
  );
}

void generateSummaryReport(Map<String, TestResult> results) {
  print('\n📊 TESTING SUMMARY REPORT');
  print('=' * 50);
  
  int totalTests = 0;
  int totalPassed = 0;
  int totalFailed = 0;
  int totalErrors = 0;
  
  for (final entry in results.entries) {
    final suiteName = entry.key.split('/').last;
    final result = entry.value;
    
    totalTests += result.total;
    totalPassed += result.passed;
    totalFailed += result.failed;
    totalErrors += result.errors.length;
    
    print('\n📁 $suiteName');
    print('   Tests: ${result.passed}/${result.total} passed');
    print('   Status: ${result.success ? "✅ PASSED" : "❌ FAILED"}');
    
    if (result.errors.isNotEmpty) {
      print('   Errors: ${result.errors.length}');
    }
  }
  
  print('\n🎯 OVERALL RESULTS');
  print('-' * 30);
  print('Total Tests: $totalTests');
  print('Passed: $totalPassed');
  print('Failed: $totalFailed');
  print('Success Rate: ${totalTests > 0 ? ((totalPassed / totalTests) * 100).toStringAsFixed(1) : "0.0"}%');
  
  if (totalErrors > 0) {
    print('Total Errors: $totalErrors');
  }
  
  print('\n📋 MANUAL TESTING REQUIRED');
  print('-' * 30);
  print('• Authentication with test credentials');
  print('• 5-section Overwatch navigation');
  print('• Claims review workflow');
  print('• Fund flow visualization');
  print('• Healthcare facility monitoring');
  print('• Cross-device responsiveness');
  
  print('\n🌐 ACCESS APPLICATION');
  print('-' * 30);
  print('Primary: http://localhost:8080');
  print('Secondary: http://localhost:8081');
  
  print('\n🔑 TEST CREDENTIALS');
  print('-' * 30);
  print('Centre: centre@pmajay.gov.in / centre123');
  print('State: state@pmajay.gov.in / state123');
  print('Agency: agency@pmajay.gov.in / agency123');
  print('Overwatch: overwatch@pmajay.gov.in / overwatch123');
  print('Public: public@pmajay.gov.in / public123');
  
  print('\n📖 TESTING DOCUMENTATION');
  print('-' * 30);
  print('• PM_AJAY_COMPREHENSIVE_TESTING_PLAN.md');
  print('• PM_AJAY_TESTING_EXECUTION_REPORT.md');
  
  final overallSuccess = totalFailed == 0 && totalTests > 0;
  print('\n${overallSuccess ? "🎉" : "⚠️"} TESTING ${overallSuccess ? "COMPLETED SUCCESSFULLY" : "REQUIRES ATTENTION"}');
}

class TestResult {
  final int total;
  final int passed;
  final int failed;
  final bool success;
  final List<String> errors;
  
  TestResult({
    required this.total,
    required this.passed,
    required this.failed,
    required this.success,
    required this.errors,
  });
}