import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/models/user_model.dart' as app_user;
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/services/config_service.dart';

final authProviderNotifier = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier();
});

class AuthState {
  final app_user.User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({app_user.User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check if there's a current user stored in settings
      final currentUserEmail =
          await DatabaseService.getSetting('current_user_email');
      if (currentUserEmail != null) {
        final user = await DatabaseService.getUserByEmail(currentUserEmail);
        if (user != null) {
          state = state.copyWith(user: user, isLoading: false);
          return;
        }
      }

      // If no current user, check if there's an admin user
      final adminUser =
          await DatabaseService.getUserByEmail('admin@stocked.com');
      if (adminUser != null) {
        await _setCurrentUser(adminUser);
        state = state.copyWith(user: adminUser, isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _setCurrentUser(app_user.User user) async {
    await DatabaseService.setSetting('current_user_email', user.email ?? '');
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get user from local database
      final user = await DatabaseService.getUserByEmail(email);

      if (user != null) {
        // For demo purposes, accept any password
        // In a real app, you'd hash and verify the password
        await _setCurrentUser(user);
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(
            isLoading: false, error: 'User not found. Please sign up first.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String companyName,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if user already exists
      final existingUser = await DatabaseService.getUserByEmail(email);
      if (existingUser != null) {
        state = state.copyWith(
            isLoading: false, error: 'User with this email already exists.');
        return;
      }

      // Create new user
      final user = app_user.User(
        email: email,
        name: name,
        phone: phone,
        companyName: companyName,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DatabaseService.saveUser(user);
      await _setCurrentUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await DatabaseService.setSetting('current_user_email', '');
      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? companyName,
    String? gstNumber,
    String? panNumber,
  }) async {
    if (state.user == null) return;

    try {
      final updatedUser = state.user!.copyWith(
        name: name,
        phone: phone,
        address: address,
        companyName: companyName,
        gstNumber: gstNumber,
        panNumber: panNumber,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadUser() async {
    await _loadCurrentUser();
  }
}
