import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/features/stock/presentation/screens/stock_management_screen.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_detail_screen.dart';
import 'package:stocked/features/orders/presentation/screens/orders_screen.dart';
import 'package:stocked/features/payments/presentation/screens/payments_screen.dart';
import 'package:stocked/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:stocked/features/settings/presentation/screens/settings_screen.dart';

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
    final isMobile = screenSize.width < 600;

    if (isMobile) {
      // Mobile layout: bottom nav bar
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_navItems[_selectedNavIndex]['label'],
              style: AppTheme.heading3.copyWith(fontSize: 18)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: _buildMainContent(context, user, isMobile),
                ),
              ),
              CupertinoTabBar(
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                  _handleNavigation(index);
                },
                items: _navItems
                    .map((item) => BottomNavigationBarItem(
                          icon: Icon(item['icon'],
                              size: 22, color: item['color']),
                          label: item['label'],
                        ))
                    .toList(),
                backgroundColor: Colors.white.withOpacity(0.9),
                activeColor: AppTheme.primaryColor,
                inactiveColor: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      );
    }

    // Desktop layout: sidebar
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
                  padding: EdgeInsets.all(_isNavbarCollapsed ? 8 : 24),
                  child: Row(
                    children: [
                      Flexible(
                        child: Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppTheme.primaryColor,
                          size: _isNavbarCollapsed ? 24 : 32,
                        ),
                      ),
                      if (!_isNavbarCollapsed) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Stocked',
                              style: AppTheme.heading3.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
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
                        iconSize: _isNavbarCollapsed ? 18 : 22,
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
                          horizontal: 4,
                          vertical: 2,
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
                                horizontal: _isNavbarCollapsed ? 8 : 16,
                                vertical: 12,
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
                                  Flexible(
                                    child: Icon(
                                      item['icon'],
                                      color: isSelected
                                          ? item['color']
                                          : AppTheme.textSecondaryColor,
                                      size: _isNavbarCollapsed ? 20 : 24,
                                    ),
                                  ),
                                  if (!_isNavbarCollapsed) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          item['label'],
                                          style: AppTheme.body1.copyWith(
                                            color: isSelected
                                                ? item['color']
                                                : AppTheme.textPrimaryColor,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 15,
                                          ),
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
                  padding: EdgeInsets.all(_isNavbarCollapsed ? 8 : 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: _isNavbarCollapsed ? 16 : 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppTheme.primaryColor,
                          size: _isNavbarCollapsed ? 16 : 24,
                        ),
                      ),
                      if (!_isNavbarCollapsed) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'User',
                                  style: AppTheme.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user?.role ?? 'User',
                                  style:
                                      AppTheme.caption.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              ref.read(authProviderNotifier.notifier).signOut(),
                          icon: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: AppTheme.errorColor,
                          ),
                          iconSize: 18,
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
                child: _buildMainContent(context, user, false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, user, bool isMobile) {
    // Example provider data (replace with real providers when available)
    final bool isOnline = true; // Replace with real network provider
    final double moneyToBeReceived =
        25000.0; // Replace with real calculation from payments/orders
    final List<Map<String, String>> pendingPayments = [
      {
        'client': 'TechCorp',
        'amount': '₹5,000',
        'due': '2024-07-15',
        'status': 'Pending'
      },
      {
        'client': 'OfficePlus',
        'amount': '₹3,200',
        'due': '2024-07-18',
        'status': 'Pending'
      },
      {
        'client': 'SmartStore',
        'amount': '₹7,800',
        'due': '2024-07-20',
        'status': 'Pending'
      },
      {
        'client': 'DigitalHub',
        'amount': '₹2,500',
        'due': '2024-07-22',
        'status': 'Pending'
      },
    ];
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
                            _analyticsGraphs[_currentGraphIndex]['title'],
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _analyticsGraphs[_currentGraphIndex]['subtitle'],
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
                            '${_currentGraphIndex + 1} / ${_analyticsGraphs.length}',
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _currentGraphIndex < _analyticsGraphs.length - 1
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
                          graphData: _analyticsGraphs[_currentGraphIndex],
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
                _buildStatCard('Total Items', '1,234', CupertinoIcons.cube_box,
                    AppTheme.primaryColor, isMobile),
                _buildStatCard(
                    'Low Stock',
                    '23',
                    CupertinoIcons.exclamationmark_triangle,
                    AppTheme.warningColor,
                    isMobile),
                _buildStatCard('Pending Orders', '45', CupertinoIcons.cart,
                    AppTheme.infoColor, isMobile),
                _buildStatCard(
                    'Monthly Revenue',
                    '₹2.5M',
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
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const OrdersScreen(),
          ),
        );
        break;
      case 3: // Payments
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const PaymentsScreen(),
          ),
        );
        break;
      case 4: // Expenses
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const ExpensesScreen(),
          ),
        );
        break;
      case 5: // Analytics
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const AnalyticsScreen(),
          ),
        );
        break;
      case 6: // Settings
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
    }
  }
}
