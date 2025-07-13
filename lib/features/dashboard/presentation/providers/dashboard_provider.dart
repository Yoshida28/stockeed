import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/services/database_service.dart';

final dashboardProviderNotifier =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> analyticsGraphs;
  final List<Map<String, String>> pendingPayments;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats = const {},
    this.analyticsGraphs = const [],
    this.pendingPayments = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? analyticsGraphs,
    List<Map<String, String>>? pendingPayments,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      analyticsGraphs: analyticsGraphs ?? this.analyticsGraphs,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load dashboard stats
      final stats = await DatabaseService.getDashboardStats();

      // Load analytics data
      final analyticsGraphs = await _loadAnalyticsData();

      // Load pending payments
      final pendingPayments = await _loadPendingPayments();

      state = state.copyWith(
        stats: stats,
        analyticsGraphs: analyticsGraphs,
        pendingPayments: pendingPayments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> _loadAnalyticsData() async {
    try {
      // Get top items by stock
      final items = await DatabaseService.getAllItems();
      final topItems = items
          .where((item) => item.currentStock != null && item.currentStock! > 0)
          .toList()
        ..sort((a, b) => (b.currentStock ?? 0).compareTo(a.currentStock ?? 0));

      final topItemsData = topItems
          .take(5)
          .map((item) => {
                'name': item.name ?? 'Unknown',
                'value': item.currentStock ?? 0,
              })
          .toList();

      // Get top clients by orders
      final orders = await DatabaseService.getAllOrders();
      final clientOrders = <String, int>{};
      for (final order in orders) {
        if (order.clientName != null) {
          clientOrders[order.clientName!] =
              (clientOrders[order.clientName!] ?? 0) + 1;
        }
      }

      final topClients = clientOrders.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topClientsData = topClients
          .take(5)
          .map((entry) => {
                'name': entry.key,
                'value': entry.value,
              })
          .toList();

      // Get monthly sales data (last 6 months)
      final monthlySales = await _getMonthlySales();

      // Get category distribution
      final categoryData = await _getCategoryDistribution();

      return [
        {
          'title': 'Top Stock Items',
          'subtitle': 'Items with highest stock levels',
          'type': 'bar',
          'data': topItemsData,
        },
        {
          'title': 'Top Clients',
          'subtitle': 'Clients with most orders',
          'type': 'bar',
          'data': topClientsData,
        },
        {
          'title': 'Monthly Sales',
          'subtitle': 'Revenue trend over 6 months',
          'type': 'line',
          'data': monthlySales,
        },
        {
          'title': 'Category Distribution',
          'subtitle': 'Items by category',
          'type': 'pie',
          'data': categoryData,
        },
      ];
    } catch (e) {
      print('Error loading analytics data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getMonthlySales() async {
    try {
      final orders = await DatabaseService.getAllOrders();
      final now = DateTime.now();
      final monthlyData = <String, double>{};

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i);
        final monthName = _getMonthName(month.month);
        monthlyData[monthName] = 0.0;
      }

      for (final order in orders) {
        if (order.orderDate != null && order.totalAmount != null) {
          final orderMonth =
              DateTime(order.orderDate!.year, order.orderDate!.month);
          final now = DateTime.now();
          final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

          if (orderMonth.isAfter(sixMonthsAgo) ||
              orderMonth.isAtSameMomentAs(sixMonthsAgo)) {
            final monthName = _getMonthName(orderMonth.month);
            monthlyData[monthName] =
                (monthlyData[monthName] ?? 0.0) + order.totalAmount!;
          }
        }
      }

      return monthlyData.entries
          .map((entry) => {
                'month': entry.key,
                'value': entry.value,
              })
          .toList();
    } catch (e) {
      print('Error getting monthly sales: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getCategoryDistribution() async {
    try {
      final items = await DatabaseService.getAllItems();
      final categoryCounts = <String, int>{};

      for (final item in items) {
        if (item.category != null) {
          categoryCounts[item.category!] =
              (categoryCounts[item.category!] ?? 0) + 1;
        }
      }

      return categoryCounts.entries
          .map((entry) => {
                'category': entry.key,
                'value': entry.value,
              })
          .toList();
    } catch (e) {
      print('Error getting category distribution: $e');
      return [];
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<List<Map<String, String>>> _loadPendingPayments() async {
    try {
      final orders = await DatabaseService.getAllOrders();
      final pendingPayments = <Map<String, String>>[];

      for (final order in orders) {
        if (order.paymentStatus == 'pending' &&
            order.clientName != null &&
            order.totalAmount != null &&
            order.paidAmount != null) {
          final pendingAmount = order.totalAmount! - order.paidAmount!;
          if (pendingAmount > 0) {
            pendingPayments.add({
              'client': order.clientName!,
              'amount': '₹${pendingAmount.toStringAsFixed(2)}',
              'due': order.orderDate?.toString().split(' ')[0] ?? 'N/A',
              'status': 'Pending',
            });
          }
        }
      }

      // Sort by due date and take top 4
      pendingPayments.sort((a, b) => a['due']!.compareTo(b['due']!));
      return pendingPayments.take(4).toList();
    } catch (e) {
      print('Error loading pending payments: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
