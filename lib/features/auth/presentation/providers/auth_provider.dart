import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stocked/core/models/user_model.dart' as app_user;
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/constants/app_constants.dart';

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
  AuthNotifier() : super(AuthState());

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user data from local database
        final user = await DatabaseService.getUserByEmail(email);
        if (user != null) {
          state = state.copyWith(user: user, isLoading: false);
        } else {
          // User not found locally, create from Supabase data
          final newUser = app_user.User(
            email: email,
            cloudId: response.user!.id,
            syncStatus: AppConstants.syncStatusSynced,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await DatabaseService.saveUser(newUser);
          state = state.copyWith(user: newUser, isLoading: false);
        }
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
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Don't create local user yet - wait for OTP verification
        // The trigger will create the user in public.users table
        // We'll create local user after OTP verification
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String name,
    required String phone,
    required String companyName,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Verify OTP with Supabase
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      if (response.user != null) {
        // Now create user in local database
        final user = app_user.User(
          email: email,
          name: name,
          phone: phone,
          companyName: companyName,
          role: role,
          cloudId: response.user!.id,
          syncStatus: AppConstants.syncStatusSynced,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await DatabaseService.saveUser(user);
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
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
        syncStatus: AppConstants.syncStatusPending,
      );

      await DatabaseService.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final user = await DatabaseService.getUserByEmail(session.user.email!);
      if (user != null) {
        state = state.copyWith(user: user);
      }
    }
  }
}
