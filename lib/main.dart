import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/features/auth/presentation/screens/auth_screen.dart';
import 'package:stocked/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize local database
  await DatabaseService.initialize();

  // Initialize sync service
  await SyncService.initialize();

  runApp(const ProviderScope(child: StockedApp()));
}

class StockedApp extends ConsumerWidget {
  const StockedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoApp(
      title: 'Stocked',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return const DashboardScreen();
          }
        }
        return const AuthScreen();
      },
    );
  }
}
