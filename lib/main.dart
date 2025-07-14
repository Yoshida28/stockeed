import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/features/auth/presentation/screens/auth_screen.dart';
import 'package:stocked/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/core/services/category_service.dart';
import 'package:stocked/core/services/expense_category_service.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  await DatabaseService.initialize();

  // Initialize config service
  await ConfigService.initialize();

  // Initialize default categories
  await CategoryService.initializeDefaultCategories();
  await ExpenseCategoryService.resetToDefaults();

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
    final authState = ref.watch(authProviderNotifier);

    if (authState.isLoading) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (authState.user != null) {
      return const HomeShell();
    }

    return const AuthScreen();
  }
}
