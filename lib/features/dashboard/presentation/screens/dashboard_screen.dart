import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/features/stock/presentation/screens/stock_management_screen.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isNavbarCollapsed = false;
  int _selectedNavIndex = 0;
  int _currentGraphIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': CupertinoIcons.home,
      'label': 'Dashboard',
      'color': AppTheme.primaryColor,
    },
    {
      'icon': CupertinoIcons.cube_box,
      'label': 'Stock',
      'color': AppTheme.successColor,
    },
    {
      'icon': CupertinoIcons.cart,
      'label': 'Orders',
      'color': AppTheme.warningColor,
    },
    {
      'icon': CupertinoIcons.creditcard,
      'label': 'Payments',
      'color': AppTheme.infoColor,
    },
    {
      'icon': CupertinoIcons.money_dollar,
      'label': 'Expenses',
      'color': AppTheme.errorColor,
    },
    {
      'icon': CupertinoIcons.chart_bar,
      'label': 'Analytics',
      'color': AppTheme.secondaryColor,
    },
    {
      'icon': CupertinoIcons.settings,
      'label': 'Settings',
      'color': AppTheme.accentColor,
    },
  ];

  final List<Map<String, dynamic>> _analyticsGraphs = [
    {
      'title': 'Most Bought Items',
      'subtitle': 'Top 5 items by purchase volume',
      'type': 'bar',
      'data': [
        {'name': 'Laptop', 'value': 45},
        {'name': 'Phone', 'value': 38},
        {'name': 'Tablet', 'value': 32},
        {'name': 'Monitor', 'value': 28},
        {'name': 'Keyboard', 'value': 25},
      ],
    },
    {
      'title': 'Top Buyers',
      'subtitle': 'Customers with highest orders',
      'type': 'bar',
      'data': [
        {'name': 'TechCorp', 'value': 120},
        {'name': 'OfficePlus', 'value': 95},
        {'name': 'DigitalHub', 'value': 78},
        {'name': 'SmartStore', 'value': 65},
        {'name': 'InnovateCo', 'value': 52},
      ],
    },
    {
      'title': 'Monthly Sales',
      'subtitle': 'Revenue trend over 6 months',
      'type': 'line',
      'data': [
        {'month': 'Jan', 'value': 45000},
        {'month': 'Feb', 'value': 52000},
        {'month': 'Mar', 'value': 48000},
        {'month': 'Apr', 'value': 61000},
        {'month': 'May', 'value': 58000},
        {'month': 'Jun', 'value': 67000},
      ],
    },
    {
      'title': 'Category Distribution',
      'subtitle': 'Sales by product category',
      'type': 'pie',
      'data': [
        {'category': 'Electronics', 'value': 40},
        {'category': 'Office', 'value': 25},
        {'category': 'Accessories', 'value': 20},
        {'category': 'Software', 'value': 15},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderNotifier);
    final user = authState.user;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          // Collapsible Navigation Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isNavbarCollapsed ? 80 : 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(_isNavbarCollapsed ? 16 : 24),
                  child: Row(
                    children: [
                      if (!_isNavbarCollapsed) ...[
                        Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Stocked',
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ] else ...[
                        Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ],
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isNavbarCollapsed = !_isNavbarCollapsed;
                          });
                        },
                        icon: Icon(
                          _isNavbarCollapsed
                              ? CupertinoIcons.chevron_right
                              : CupertinoIcons.chevron_left,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = _selectedNavIndex == index;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedNavIndex = index;
                              });
                              _handleNavigation(index);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isNavbarCollapsed ? 16 : 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item['color'].withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: item['color'],
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    color: isSelected
                                        ? item['color']
                                        : AppTheme.textSecondaryColor,
                                    size: 24,
                                  ),
                                  if (!_isNavbarCollapsed) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item['label'],
                                        style: AppTheme.body1.copyWith(
                                          color: isSelected
                                              ? item['color']
                                              : AppTheme.textPrimaryColor,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // User Profile Section
                Container(
                  padding: EdgeInsets.all(_isNavbarCollapsed ? 16 : 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: _isNavbarCollapsed ? 20 : 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppTheme.primaryColor,
                          size: _isNavbarCollapsed ? 20 : 24,
                        ),
                      ),
                      if (!_isNavbarCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'User',
                                style: AppTheme.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user?.role ?? 'User',
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              ref.read(authProviderNotifier.notifier).signOut(),
                          icon: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _analyticsGraphs[_currentGraphIndex]
                                            ['title'],
                                        style: AppTheme.heading3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _analyticsGraphs[_currentGraphIndex]
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
                                      icon: const Icon(
                                          CupertinoIcons.chevron_left),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${_currentGraphIndex + 1} / ${_analyticsGraphs.length}',
                                        style: AppTheme.body2.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _currentGraphIndex <
                                              _analyticsGraphs.length - 1
                                          ? () {
                                              setState(() {
                                                _currentGraphIndex++;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(
                                          CupertinoIcons.chevron_right),
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
                                  _analyticsGraphs[_currentGraphIndex]),
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
                                      graphData:
                                          _analyticsGraphs[_currentGraphIndex],
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
                      style: AppTheme.heading2,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Items',
                            '1,234',
                            CupertinoIcons.cube_box,
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Low Stock',
                            '23',
                            CupertinoIcons.exclamationmark_triangle,
                            AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Pending Orders',
                            '45',
                            CupertinoIcons.cart,
                            AppTheme.infoColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Monthly Revenue',
                            '₹2.5M',
                            CupertinoIcons.money_dollar,
                            AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _buildGlassmorphicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                color: AppTheme.textSecondaryColor,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTheme.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.body2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        // Already on dashboard
        break;
      case 1: // Stock
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const StockManagementScreen(),
          ),
        );
        break;
      case 2: // Orders
        _showComingSoon(context, 'Order Management');
        break;
      case 3: // Payments
        _showComingSoon(context, 'Payment Management');
        break;
      case 4: // Expenses
        _showComingSoon(context, 'Expense Management');
        break;
      case 5: // Analytics
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AnalyticsDetailScreen(
              graphData: _analyticsGraphs[_currentGraphIndex],
            ),
          ),
        );
        break;
      case 6: // Settings
        _showComingSoon(context, 'Settings');
        break;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available in the next update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
