import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/centre_review_panel_widget.dart';
import '../widgets/state_review_panel_widget.dart';
import '../widgets/agency_review_panel_widget.dart';

/// Unified Review & Approval page that displays appropriate panel based on user role
/// 
/// Role-based panel routing:
/// - Centre Officials (UserRole.centreAdmin): Centre Review Panel for State participation requests
/// - State Officials (UserRole.stateOfficer): State Review Panel for Agency onboarding requests
/// - Agency Officials (UserRole.agencyUser): Agency Review Panel for task assignments
class ReviewApprovalPage extends ConsumerWidget {
  const ReviewApprovalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(authState.user?.role)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          _buildNotificationBadge(authState.user?.role),
          const SizedBox(width: 8),
          _buildRoleIndicator(context, authState.user?.role),
          const SizedBox(width: 16),
        ],
      ),
      body: authState.user == null
          ? _buildUnauthorizedView()
          : _buildPanelForRole(authState.user!.role),
    );
  }

  /// Get page title based on user role
  String _getPageTitle(UserRole? role) {
    switch (role) {
      case UserRole.centreAdmin:
        return 'Centre Review & Approval';
      case UserRole.stateOfficer:
        return 'State Review & Approval';
      case UserRole.agencyUser:
        return 'Agency Review & Approval';
      default:
        return 'Review & Approval';
    }
  }

  /// Build notification badge showing pending count
  Widget _buildNotificationBadge(UserRole? role) {
    final pendingCount = _getPendingCount(role);
    
    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications page
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              pendingCount > 99 ? '99+' : pendingCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// Get pending request count based on role
  int _getPendingCount(UserRole? role) {
    // Mock data - replace with actual queries
    switch (role) {
      case UserRole.centreAdmin:
        return 5; // Pending State participation requests
      case UserRole.stateOfficer:
        return 3; // Pending Agency onboarding requests
      case UserRole.agencyUser:
        return 8; // Pending task assignments
      default:
        return 0;
    }
  }

  /// Build role indicator chip
  Widget _buildRoleIndicator(BuildContext context, UserRole? role) {
    if (role == null) return const SizedBox.shrink();

    Color roleColor;
    IconData roleIcon;
    String roleText;

    switch (role) {
      case UserRole.centreAdmin:
        roleColor = Colors.purple;
        roleIcon = Icons.account_balance;
        roleText = 'Centre';
        break;
      case UserRole.stateOfficer:
        roleColor = Colors.blue;
        roleIcon = Icons.location_city;
        roleText = 'State';
        break;
      case UserRole.agencyUser:
        roleColor = Colors.green;
        roleIcon = Icons.business;
        roleText = 'Agency';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: roleColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon, size: 16, color: roleColor),
          const SizedBox(width: 6),
          Text(
            roleText,
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build appropriate panel based on user role
  Widget _buildPanelForRole(UserRole role) {
    switch (role) {
      case UserRole.centreAdmin:
        return const CentreReviewPanelWidget();
      
      case UserRole.stateOfficer:
        return const StateReviewPanelWidget();
      
      case UserRole.agencyUser:
        return const AgencyReviewPanelWidget();
      
      default:
        return _buildUnauthorizedView();
    }
  }

  /// Build unauthorized access view
  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Access Restricted',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You do not have permission to access this page.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator for access.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate back to dashboard
            },
            icon: const Icon(Icons.home),
            label: const Text('Return to Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}