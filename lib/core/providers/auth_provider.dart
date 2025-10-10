import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

/// Authentication state containing user information and auth status
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Authentication state notifier managing user authentication
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual Supabase authentication
      // For now, create a mock user based on email domain
      final user = _createMockUser(email);
      
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = const AuthState();
  }

  /// Update user profile
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  /// Create mock user for testing (replace with actual Supabase auth)
  UserModel _createMockUser(String email) {
    final now = DateTime.now();
    
    // Determine role based on email domain
    UserRole role;
    String fullName;
    String? stateId;
    String? agencyId;
    
    if (email.contains('centre')) {
      role = UserRole.centreAdmin;
      fullName = 'Centre Administrator';
    } else if (email.contains('state')) {
      role = UserRole.stateOfficer;
      fullName = 'State Officer';
      stateId = 'state-001';
    } else if (email.contains('agency')) {
      role = UserRole.agencyUser;
      fullName = 'Agency User';
      stateId = 'state-001';
      agencyId = 'agency-001';
    } else if (email.contains('overwatch')) {
      role = UserRole.overwatch;
      fullName = 'Overwatch Monitor';
    } else {
      role = UserRole.public;
      fullName = 'Public User';
    }

    return UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      role: role,
      fullName: fullName,
      stateId: stateId,
      agencyId: agencyId,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Global auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});