import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/widgets/universal_navbar.dart';
import 'core/providers/navigation_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/stock/presentation/screens/stock_management_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/payments/presentation/screens/payments_screen.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    return UniversalNavbar(
      child: IndexedStack(
        index: navState.currentIndex,
        children: const [
          DashboardScreen(),
          StockManagementScreen(),
          OrdersScreen(),
          PaymentsScreen(),
          ExpensesScreen(),
          AnalyticsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
