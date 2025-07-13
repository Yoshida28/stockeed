import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/services/database_service.dart';

final analyticsProviderNotifier =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

class AnalyticsState {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> monthlyData;
  final List<Map<String, dynamic>> categoryData;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.stats = const {},
    this.monthlyData = const [],
    this.categoryData = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? monthlyData,
    List<Map<String, dynamic>>? categoryData,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      stats: stats ?? this.stats,
      monthlyData: monthlyData ?? this.monthlyData,
      categoryData: categoryData ?? this.categoryData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState()) {
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load dashboard stats
      final stats = await DatabaseService.getDashboardStats();

      // Load monthly sales data
      final monthlyData = await _getMonthlySales();

      // Load category distribution
      final categoryData = await _getCategoryDistribution();

      state = state.copyWith(
        stats: stats,
        monthlyData: monthlyData,
        categoryData: categoryData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
                'name': entry.key,
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

  Future<void> refresh() async {
    await loadAnalyticsData();
  }
}
