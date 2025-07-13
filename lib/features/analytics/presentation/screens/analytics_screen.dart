import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_detail_screen.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProviderNotifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Analytics',
            style: AppTheme.heading1.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your business performance and insights',
            style: AppTheme.body2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Analytics Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildAnalyticsCard(
                title: 'Sales Analytics',
                description: 'Track sales performance and trends',
                icon: CupertinoIcons.chart_bar_alt_fill,
                color: AppTheme.primaryColor,
                onTap: () => _navigateToDetail('sales', analyticsState),
              ),
              _buildAnalyticsCard(
                title: 'Inventory Analytics',
                description: 'Monitor stock levels and movements',
                icon: CupertinoIcons.cube_box_fill,
                color: AppTheme.successColor,
                onTap: () => _navigateToDetail('inventory', analyticsState),
              ),
              _buildAnalyticsCard(
                title: 'Financial Analytics',
                description: 'Analyze revenue and expenses',
                icon: CupertinoIcons.money_dollar_circle_fill,
                color: AppTheme.warningColor,
                onTap: () => _navigateToDetail('financial', analyticsState),
              ),
              _buildAnalyticsCard(
                title: 'Customer Analytics',
                description: 'Understand customer behavior',
                icon: CupertinoIcons.person_2_fill,
                color: AppTheme.infoColor,
                onTap: () => _navigateToDetail('customers', analyticsState),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Stats Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassmorphicDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Stats',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        title: 'Total Sales',
                        value:
                            '₹${(analyticsState.stats['today_sales'] ?? 0.0).toStringAsFixed(0)}',
                        icon: CupertinoIcons.money_dollar,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        title: 'Total Orders',
                        value: '${analyticsState.stats['today_orders'] ?? 0}',
                        icon: CupertinoIcons.cart,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        title: 'Total Items',
                        value: '${analyticsState.stats['total_items'] ?? 0}',
                        icon: CupertinoIcons.cube_box,
                        color: AppTheme.infoColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        title: 'Low Stock Items',
                        value:
                            '${analyticsState.stats['low_stock_items'] ?? 0}',
                        icon: CupertinoIcons.exclamationmark_triangle,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, dynamic> chartInfo) {
    final data = chartInfo['data'] as List<Map<String, dynamic>>;
    final type = chartInfo['type'] as String;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.chart_bar,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('No data available',
                style: AppTheme.heading3
                    .copyWith(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 8),
            Text('Add some data to see analytics',
                style: AppTheme.body2
                    .copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    if (type == 'line') {
      return LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data[value.toInt()]['name'] as String,
                        style: AppTheme.caption,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(_formatAmount(value), style: AppTheme.caption);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return FlSpot(
                    index.toDouble(), (item['value'] as num).toDouble());
              }).toList(),
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      );
    } else if (type == 'pie') {
      return PieChart(
        PieChartData(
          sections: data.map((item) {
            final value = (item['value'] as num).toDouble();
            final total = data.fold<double>(
                0, (sum, item) => sum + (item['value'] as num));
            final percentage = total > 0 ? (value / total) * 100 : 0;

            return PieChartSectionData(
              value: value,
              title: '${percentage.toStringAsFixed(1)}%',
              color: _getRandomColor(data.indexOf(item)),
              radius: 80,
              titleStyle: AppTheme.caption
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }).toList(),
          centerSpaceRadius: 40,
        ),
      );
    }

    return const Center(child: Text('Chart type not supported'));
  }

  Widget _buildAdditionalAnalytics(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Summary', style: AppTheme.heading2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payments',
                        style: AppTheme.body1
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_formatAmount(stats['today_payments'] ?? 0.0)}',
                      style: AppTheme.heading3
                          .copyWith(color: AppTheme.successColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expenses',
                        style: AppTheme.body1
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_formatAmount(stats['today_expenses'] ?? 0.0)}',
                      style: AppTheme.heading3
                          .copyWith(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassmorphicDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pending Orders',
                  style: AppTheme.body1.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${stats['pending_orders'] ?? 0}',
                style: AppTheme.heading3.copyWith(color: AppTheme.warningColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRandomColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      AppTheme.infoColor,
      AppTheme.secondaryColor,
    ];
    return colors[index % colors.length];
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.heading3.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(String type, AnalyticsState analyticsState) {
    Map<String, dynamic> graphData;

    switch (type) {
      case 'sales':
        graphData = {
          'title': 'Sales Analytics',
          'subtitle': 'Track sales performance and trends',
          'data': analyticsState.monthlyData,
        };
        break;
      case 'inventory':
        graphData = {
          'title': 'Inventory Analytics',
          'subtitle': 'Monitor stock levels and movements',
          'data': analyticsState.categoryData,
        };
        break;
      case 'financial':
        graphData = {
          'title': 'Financial Analytics',
          'subtitle': 'Analyze revenue and expenses',
          'data': analyticsState.monthlyData,
        };
        break;
      case 'customers':
        graphData = {
          'title': 'Customer Analytics',
          'subtitle': 'Understand customer behavior',
          'data': analyticsState.categoryData,
        };
        break;
      default:
        graphData = {
          'title': 'Analytics',
          'subtitle': 'Data analysis',
          'data': [],
        };
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsDetailScreen(graphData: graphData),
      ),
    );
  }
}
