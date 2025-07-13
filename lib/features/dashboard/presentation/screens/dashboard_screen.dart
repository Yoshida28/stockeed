import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentGraphIndex = 0;

  // Analytics graphs will be loaded from the provider

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderNotifier);
    final dashboardState = ref.watch(dashboardProviderNotifier);
    final user = authState.user;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: _buildMainContent(context, user, isMobile, dashboardState),
    );
  }

  Widget _buildMainContent(BuildContext context, user, bool isMobile,
      DashboardState dashboardState) {
    // Use real data from provider
    final bool isOnline = true; // For now, always online since it's local
    final double moneyToBeReceived =
        dashboardState.stats['today_payments']?.toDouble() ?? 0.0;
    final List<Map<String, String>> pendingPayments =
        dashboardState.pendingPayments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Section
        Container(
          padding: const EdgeInsets.all(32),
          decoration: _buildGlassmorphicDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.name ?? 'User',
                      style: AppTheme.heading1.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.companyName ?? 'Company',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Analytics Dashboard Section
        Text(
          'Analytics Dashboard',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 16),

        // Analytics Carousel
        Container(
          height: 400,
          decoration: _buildGlassmorphicDecoration(),
          child: Column(
            children: [
              // Carousel Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dashboardState.analyticsGraphs[_currentGraphIndex]
                                ['title'],
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dashboardState.analyticsGraphs[_currentGraphIndex]
                                ['subtitle'],
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentGraphIndex > 0
                              ? () {
                                  setState(() {
                                    _currentGraphIndex--;
                                  });
                                }
                              : null,
                          icon: const Icon(CupertinoIcons.chevron_left),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentGraphIndex + 1} / ${dashboardState.analyticsGraphs.length}',
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _currentGraphIndex <
                                  dashboardState.analyticsGraphs.length - 1
                              ? () {
                                  setState(() {
                                    _currentGraphIndex++;
                                  });
                                }
                              : null,
                          icon: const Icon(CupertinoIcons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Graph Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: _buildAnalyticsGraph(
                      dashboardState.analyticsGraphs[_currentGraphIndex]),
                ),
              ),

              // View Details Button
              Container(
                padding: const EdgeInsets.all(24),
                child: CupertinoButton.filled(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AnalyticsDetailScreen(
                          graphData: dashboardState
                              .analyticsGraphs[_currentGraphIndex],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Text('View Detailed Report'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Quick Stats Section
        Text(
          'Quick Stats',
          style: isMobile ? AppTheme.heading3 : AppTheme.heading2,
        ),
        SizedBox(height: isMobile ? 8 : 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...[
                _buildStatCard(
                    'Total Items',
                    '${dashboardState.stats['total_items'] ?? 0}',
                    CupertinoIcons.cube_box,
                    AppTheme.primaryColor,
                    isMobile),
                _buildStatCard(
                    'Low Stock',
                    '${dashboardState.stats['low_stock_items'] ?? 0}',
                    CupertinoIcons.exclamationmark_triangle,
                    AppTheme.warningColor,
                    isMobile),
                _buildStatCard(
                    'Pending Orders',
                    '${dashboardState.stats['pending_orders'] ?? 0}',
                    CupertinoIcons.cart,
                    AppTheme.infoColor,
                    isMobile),
                _buildStatCard(
                    'Today Sales',
                    '₹${(dashboardState.stats['today_sales'] ?? 0.0).toStringAsFixed(0)}',
                    CupertinoIcons.money_dollar,
                    AppTheme.successColor,
                    isMobile),
                _buildStatCard(
                    'Network',
                    isOnline ? 'Online' : 'Offline',
                    isOnline ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                    isOnline ? AppTheme.successColor : AppTheme.errorColor,
                    isMobile,
                    trailing: isOnline
                        ? Icon(CupertinoIcons.check_mark_circled_solid,
                            color: AppTheme.successColor,
                            size: isMobile ? 16 : 20)
                        : Icon(CupertinoIcons.xmark_circle_fill,
                            color: AppTheme.errorColor,
                            size: isMobile ? 16 : 20)),
                _buildStatCard(
                    'To be Received',
                    '₹${moneyToBeReceived.toStringAsFixed(0)}',
                    CupertinoIcons.arrow_down_circle,
                    AppTheme.secondaryColor,
                    isMobile),
              ].map((card) => Padding(
                    padding: EdgeInsets.only(right: isMobile ? 10 : 18),
                    child: card,
                  )),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 32),
        // Pending Payments Section
        Text(
          'Pending Payments',
          style: isMobile ? AppTheme.heading3 : AppTheme.heading2,
        ),
        SizedBox(height: isMobile ? 8 : 16),
        SizedBox(
          height: isMobile ? 130 : 160,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
            child: PageView.builder(
              controller: PageController(
                viewportFraction: isMobile ? 0.7 : 0.45,
                initialPage: 1,
              ),
              itemCount: pendingPayments.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                final pay = pendingPayments[i];
                return Container(
                  constraints: BoxConstraints(
                    minWidth: isMobile ? 180 : 220,
                    maxWidth: isMobile ? 220 : 260,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    backgroundBlendMode: BlendMode.overlay,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.creditcard,
                              color: AppTheme.infoColor,
                              size: isMobile ? 18 : 22),
                          SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(pay['client']!,
                                  style: AppTheme.body1.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 14 : 16)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(pay['amount']!,
                            style: AppTheme.heading3.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: isMobile ? 18 : 22)),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              size: isMobile ? 14 : 16,
                              color: AppTheme.textSecondaryColor),
                          SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text('Due: ${pay['due']!}',
                                  style: AppTheme.caption
                                      .copyWith(fontSize: isMobile ? 11 : 13)),
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(pay['status']!,
                                  style: AppTheme.caption.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 11 : 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 32),
      ],
    );
  }

  BoxDecoration _buildGlassmorphicDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGraph(Map<String, dynamic> graphData) {
    final type = graphData['type'];
    final data = graphData['data'];

    switch (type) {
      case 'bar':
        return _buildBarChart(data);
      case 'line':
        return _buildLineChart(data);
      case 'pie':
        return _buildPieChart(data);
      default:
        return _buildBarChart(data);
    }
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold<double>(
                0,
                (max, item) =>
                    item['value'] > max ? item['value'].toDouble() : max) *
            1.2,
        barTouchData: BarTouchData(enabled: false),
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
                      data[value.toInt()]['name'],
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
                return Text(
                  value.toInt().toString(),
                  style: AppTheme.caption,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item['value'].toDouble(),
                color: AppTheme.primaryColor,
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
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
                      data[value.toInt()]['month'],
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
                return Text(
                  '₹${(value / 1000).toInt()}K',
                  style: AppTheme.caption,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value['value'].toDouble());
            }).toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((item) {
          final total = data.fold<double>(0, (sum, d) => sum + d['value']);
          final percentage = (item['value'] / total) * 100;

          return PieChartSectionData(
            color: _getColorForIndex(data.indexOf(item)),
            value: item['value'].toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: AppTheme.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isMobile,
      {Widget? trailing}) {
    return Container(
      constraints: BoxConstraints(
        minWidth: isMobile ? 90 : 120,
        maxWidth: isMobile ? 130 : 180,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 18 : 24),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: isMobile ? 8 : 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTheme.heading2
                  .copyWith(color: color, fontSize: isMobile ? 18 : 22),
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: AppTheme.body2.copyWith(
                color: AppTheme.textSecondaryColor,
                fontSize: isMobile ? 11 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
