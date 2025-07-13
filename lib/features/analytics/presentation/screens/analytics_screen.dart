import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedSection = 0;
  // Store the selected date range in state
  DateTimeRange? _selectedRange;
  final List<String> _sections = [
    'Overview',
    'Sales',
    'Stock',
    'Clients',
    'Categories',
    'Expenses',
    'Income vs Expenses',
    'Trends',
  ];

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProviderNotifier);
    final isWide = MediaQuery.of(context).size.width > 900;
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Container(
              width: 220,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                border: Border(
                  right: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Analytics',
                        style: AppTheme.heading2
                            .copyWith(color: AppTheme.primaryColor)),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(
                      _sections.length,
                      (i) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: Material(
                              color: i == _selectedSection
                                  ? AppTheme.primaryColor.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () =>
                                    setState(() => _selectedSection = i),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: Text(
                                    _sections[i],
                                    style: AppTheme.body1.copyWith(
                                      color: i == _selectedSection
                                          ? AppTheme.primaryColor
                                          : AppTheme.textSecondaryColor,
                                      fontWeight: i == _selectedSection
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 32,
                horizontal: isWide ? 48 : 16,
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Header and Time Frame Selector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                      Text(_sections[_selectedSection],
                          style: AppTheme.heading1
                              .copyWith(color: AppTheme.primaryColor)),
                      const Spacer(),
                      _buildTimeFrameSelector(context),
                      const SizedBox(width: 12),
                      _buildExportButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Section Content Placeholder
                  _buildSectionContent(_selectedSection, analyticsState),
                                    ],
                                  ),
                                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(BuildContext context) {
    final now = DateTime.now();
    final defaultRange =
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final range = _selectedRange ?? defaultRange;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
      onPressed: () async {
        DateTime tempStart = range.start;
        DateTime tempEnd = range.end;
        await showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Container(
              color: Colors.white,
              height: 400,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Select Time Frame', style: AppTheme.heading3),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Start',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: tempStart,
                                  maximumDate: tempEnd,
                                  minimumDate: DateTime(now.year - 5),
                                  onDateTimeChanged: (date) {
                                    tempStart = date;
                                    if (tempStart.isAfter(tempEnd))
                                      tempEnd = tempStart;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('End',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: tempEnd,
                                  minimumDate: tempStart,
                                  maximumDate: now,
                                  onDateTimeChanged: (date) {
                                    tempEnd = date;
                                    if (tempEnd.isBefore(tempStart))
                                      tempStart = tempEnd;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoButton.filled(
                        child: const Text('OK'),
                        onPressed: () {
                          setState(() {
                            _selectedRange =
                                DateTimeRange(start: tempStart, end: tempEnd);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          const Icon(CupertinoIcons.calendar, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.infoColor,
      borderRadius: BorderRadius.circular(20),
      onPressed: () {
        // TODO: Implement export logic
      },
      child: Row(
        children: const [
          Icon(CupertinoIcons.share, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Text('Export',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionContent(int section, analyticsState) {
    final now = DateTime.now();
    final defaultRange =
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final range = _selectedRange ?? defaultRange;
    switch (section) {
      case 0: // Overview
        return _buildOverviewSection(range);
      case 1: // Sales
        return _buildSalesSection(range);
      case 2: // Stock
        return _buildStockSection(range);
      case 3: // Clients
        return _buildClientsSection(range);
      case 4: // Categories
        return _buildCategoriesSection(range);
      case 5: // Expenses
        return _buildExpensesSection(range);
      case 6: // Income vs Expenses
        return _buildIncomeVsExpensesSection(range);
      case 7: // Trends
        return _buildTrendsSection(range);
      default:
        return Container();
    }
  }

  // --- SECTION BUILDERS WITH HARDCODED DATA ---

  Widget _buildOverviewSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final totalSales = isThisMonth ? 12000 : 8000;
    final totalOrders = isThisMonth ? 320 : 210;
    final lowStock = isThisMonth ? 5 : 8;
    final expenses = isThisMonth ? 4000 : 3000;
    final profit = isThisMonth ? 8000 : 5000;
    final trendData = [
      {'month': 'Jan', 'value': 12000},
      {'month': 'Feb', 'value': 15000},
      {'month': 'Mar', 'value': 18000},
      {'month': 'Apr', 'value': 20000},
      {'month': 'May', 'value': 25000},
      {'month': 'Jun', 'value': 28000},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            _buildInfoCard('Total Sales', '₹$totalSales'),
            _buildInfoCard('Total Orders', '$totalOrders'),
            _buildInfoCard('Total Items', '150'),
            _buildInfoCard('Low Stock', '$lowStock'),
            _buildInfoCard('Expenses', '₹$expenses'),
            _buildInfoCard('Profit', '₹$profit'),
          ],
        ),
        const SizedBox(height: 32),
        Text('Business Trend', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildLineChart(trendData, xKey: 'month', yKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'Steady growth in sales over the last 6 months.',
          'Profit margin is healthy.'
        ]),
        const SizedBox(height: 24),
        _buildSampleTable([
          'Metric',
          'Value'
        ], [
          ['Total Sales', '₹$totalSales'],
          ['Total Orders', '$totalOrders'],
          ['Total Items', '150'],
          ['Low Stock', '$lowStock'],
          ['Expenses', '₹$expenses'],
          ['Profit', '₹$profit']
        ]),
      ],
    );
  }

  Widget _buildSalesSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final salesData = isThisMonth
        ? [
            {'month': 'Mon', 'value': 1000},
            {'month': 'Tue', 'value': 1200},
            {'month': 'Wed', 'value': 900},
            {'month': 'Thu', 'value': 1500},
            {'month': 'Fri', 'value': 1100},
            {'month': 'Sat', 'value': 1300},
            {'month': 'Sun', 'value': 1200},
          ]
        : [
            {'month': 'Mon', 'value': 700},
            {'month': 'Tue', 'value': 800},
            {'month': 'Wed', 'value': 600},
            {'month': 'Thu', 'value': 900},
            {'month': 'Fri', 'value': 750},
            {'month': 'Sat', 'value': 850},
            {'month': 'Sun', 'value': 800},
          ];
    final topProducts = [
      {'name': 'Printer Paper A4', 'value': 216},
      {'name': 'Wireless Mouse', 'value': 98},
      {'name': 'Laptop Dell', 'value': 45},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales Over Time', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildLineChart(salesData, xKey: 'month', yKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'Sales are increasing month over month.',
          'May and June are peak months.'
        ]),
        const SizedBox(height: 32),
        Text('Top Products', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildBarChart(topProducts, xKey: 'name', yKey: 'value')),
        const SizedBox(height: 16),
        _buildSampleTable([
          'Product',
          'Units Sold'
        ], topProducts.map((p) => [p['name'], p['value'].toString()]).toList()),
      ],
    );
  }

  Widget _buildStockSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final stockData = isThisMonth
        ? [
            {'name': 'Printer Paper A4', 'value': 50},
            {'name': 'Wireless Mouse', 'value': 40},
            {'name': 'Laptop Dell', 'value': 30},
            {'name': 'Office Chair', 'value': 20},
            {'name': 'Desk Lamp', 'value': 10},
          ]
        : [
            {'name': 'Printer Paper A4', 'value': 60},
            {'name': 'Wireless Mouse', 'value': 55},
            {'name': 'Laptop Dell', 'value': 45},
            {'name': 'Office Chair', 'value': 35},
            {'name': 'Desk Lamp', 'value': 25},
          ];
    final categoryData = [
      {'category': 'Electronics', 'value': 143},
      {'category': 'Office', 'value': 241},
      {'category': 'Other', 'value': 12},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Stock Items', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildBarChart(stockData, xKey: 'name', yKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'Printer Paper A4 is the most stocked item.',
          'Low stock alert for Office Chair.'
        ]),
        const SizedBox(height: 32),
        Text('Stock by Category', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildPieChart(categoryData,
                labelKey: 'category', valueKey: 'value')),
        const SizedBox(height: 16),
        _buildSampleTable(
            ['Category', 'Stock'],
            categoryData
                .map((c) => [c['category'], c['value'].toString()])
                .toList()),
      ],
    );
  }

  Widget _buildClientsSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final clientsData =
        isThisMonth ? ["Alice", "Bob", "Charlie"] : ["David", "Eve", "Frank"];
    final clientData = [
      {'name': 'TechCorp Solutions', 'value': 32},
      {'name': 'OfficePlus Store', 'value': 28},
      {'name': 'RetailMart', 'value': 19},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Clients by Orders', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildBarChart(clientData, xKey: 'name', yKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'TechCorp Solutions is your top client.',
          'Client base is growing steadily.'
        ]),
        const SizedBox(height: 24),
        _buildSampleTable(['Client', 'Orders'],
            clientData.map((c) => [c['name'], c['value'].toString()]).toList()),
      ],
    );
  }

  Widget _buildCategoriesSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final categoriesData = isThisMonth
        ? {"Electronics": 40, "Clothing": 30, "Food": 30}
        : {"Electronics": 25, "Clothing": 35, "Food": 40};
    final categoryData = [
      {'category': 'Electronics', 'value': 143},
      {'category': 'Office', 'value': 241},
      {'category': 'Other', 'value': 12},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items by Category', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildPieChart(categoryData,
                labelKey: 'category', valueKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'Office category has the most items.',
          'Other category is underutilized.'
        ]),
        const SizedBox(height: 24),
        _buildSampleTable(
            ['Category', 'Items'],
            categoryData
                .map((c) => [c['category'], c['value'].toString()])
                .toList()),
      ],
    );
  }

  Widget _buildExpensesSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final expensesData = isThisMonth
        ? [
            {'month': 'Jan', 'value': 500},
            {'month': 'Feb', 'value': 600},
            {'month': 'Mar', 'value': 700},
            {'month': 'Apr', 'value': 800},
            {'month': 'May', 'value': 900},
          ]
        : [
            {'month': 'Jan', 'value': 300},
            {'month': 'Feb', 'value': 400},
            {'month': 'Mar', 'value': 500},
            {'month': 'Apr', 'value': 600},
            {'month': 'May', 'value': 700},
          ];
    final categoryData = [
      {'category': 'Office Supplies', 'value': 12000},
      {'category': 'Travel', 'value': 8000},
      {'category': 'Utilities', 'value': 6000},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses Over Time', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildLineChart(expensesData, xKey: 'month', yKey: 'value')),
        const SizedBox(height: 16),
        _buildInsights([
          'Expenses are rising, especially in May and June.',
          'Office Supplies is the biggest expense category.'
        ]),
        const SizedBox(height: 32),
        Text('Expenses by Category', style: AppTheme.heading3),
        const SizedBox(height: 12),
        SizedBox(
            height: 220,
            child: _buildPieChart(categoryData,
                labelKey: 'category', valueKey: 'value')),
        const SizedBox(height: 16),
        _buildSampleTable([
          'Category',
          'Amount'
        ], categoryData.map((c) => [c['category'], '₹${c['value']}']).toList()),
      ],
    );
  }

  Widget _buildIncomeVsExpensesSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final incomeVsExpensesData = isThisMonth
        ? [
            {'month': 'Jan', 'income': 4000, 'expenses': 2000},
            {'month': 'Feb', 'income': 4200, 'expenses': 2200},
            {'month': 'Mar', 'income': 4100, 'expenses': 2100},
            {'month': 'Apr', 'income': 4300, 'expenses': 2300},
            {'month': 'May', 'income': 4400, 'expenses': 2400},
          ]
        : [
            {'month': 'Jan', 'income': 3000, 'expenses': 1500},
            {'month': 'Feb', 'income': 3100, 'expenses': 1600},
            {'month': 'Mar', 'income': 3200, 'expenses': 1700},
            {'month': 'Apr', 'income': 3300, 'expenses': 1800},
            {'month': 'May', 'income': 3400, 'expenses': 1900},
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income vs Expenses',
          style: AppTheme.heading2.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        Text(
          'Track your income and expenses over time to understand your cash flow.',
          style: AppTheme.body1.copyWith(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Income vs Expenses Trend',
                style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _buildMultiLineChart(incomeVsExpensesData),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsights([
          'Income is consistently higher than expenses, indicating positive cash flow.',
          'Expenses show a steady increase trend.',
          'Consider optimizing expense categories to improve profitability.',
        ]),
        const SizedBox(height: 24),
        _buildSampleTable(
          ['Month', 'Income', 'Expenses', 'Net'],
          incomeVsExpensesData
              .map((data) => [
                    data['month'].toString(),
                    '₹${data['income']}',
                    '₹${data['expenses']}',
                    '₹${(data['income'] as int) - (data['expenses'] as int)}',
                  ])
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTrendsSection(DateTimeRange range) {
    final isThisMonth = DateTime.now().difference(range.start).inDays < 32;
    final trendsData = isThisMonth
        ? [
            {'month': 'Jan', 'value': 1100.0},
            {'month': 'Feb', 'value': 1200.0},
            {'month': 'Mar', 'value': 1300.0},
            {'month': 'Apr', 'value': 1400.0},
            {'month': 'May', 'value': 1500.0},
          ]
        : [
            {'month': 'Jan', 'value': 900.0},
            {'month': 'Feb', 'value': 1000.0},
            {'month': 'Mar', 'value': 1050.0},
            {'month': 'Apr', 'value': 1100.0},
            {'month': 'May', 'value': 1150.0},
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Trends',
          style: AppTheme.heading2.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        Text(
          'Track key performance indicators and business trends over time.',
          style: AppTheme.body1.copyWith(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Growth Trend',
                style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child:
                    _buildLineChart(trendsData, xKey: 'month', yKey: 'value'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsights([
          'Business is showing consistent growth trend.',
          'Performance metrics are improving month over month.',
          'Consider scaling operations based on positive trends.',
        ]),
        const SizedBox(height: 24),
        _buildSampleTable(
          ['Month', 'Growth Rate'],
          trendsData
              .map((data) => [
                    data['month'].toString(),
                    '${data['value']}%',
                  ])
              .toList(),
        ),
      ],
    );
  }

  // --- CHART WIDGETS ---

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTheme.body2.copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Text(value,
              style: AppTheme.heading2.copyWith(color: AppTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data,
      {required String xKey, required String yKey}) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold<double>(0,
                (max, item) => item[yKey] > max ? item[yKey].toDouble() : max) *
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
                    child: Text(data[value.toInt()][xKey].toString(),
                        style: AppTheme.caption),
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
                return Text(value.toInt().toString(), style: AppTheme.caption);
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
                toY: item[yKey].toDouble(),
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

  Widget _buildLineChart(List<Map<String, dynamic>> data,
      {required String xKey, required String yKey}) {
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
                    child: Text(data[value.toInt()][xKey].toString(),
                        style: AppTheme.caption),
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
                return Text('₹${(value / 1000).toInt()}K',
                    style: AppTheme.caption);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value[yKey].toDouble());
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

  Widget _buildPieChart(List<Map<String, dynamic>> data,
      {required String labelKey, required String valueKey}) {
    final total =
        data.fold<double>(0, (sum, d) => sum + (d[valueKey] as num).toDouble());
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.infoColor,
      AppTheme.secondaryColor
    ];
      return PieChart(
        PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final percentage = total > 0 ? (item[valueKey] / total) * 100 : 0;
            return PieChartSectionData(
            color: colors[index % colors.length],
            value: (item[valueKey] as num).toDouble(),
              title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
              titleStyle: AppTheme.caption
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
      );
    }

  Widget _buildMultiLineChart(List<Map<String, dynamic>> data,
      {List<Map<String, dynamic>>? keys}) {
    final colors = [
      AppTheme.primaryColor,
      Colors.red,
      Colors.green,
      Colors.orange,
    ];
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Text(
                    data[value.toInt()]['month'].toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: (keys ??
                [
                  {'key': 'income', 'color': Colors.green, 'label': 'Income'},
                  {'key': 'expenses', 'color': Colors.red, 'label': 'Expenses'},
                ])
            .asMap()
            .entries
            .map((entry) {
          final color =
              entry.value['color'] ?? colors[entry.key % colors.length];
          final key = entry.value['key'];
          return LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), (e.value[key] ?? 0).toDouble());
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSampleTable(List<String> columns, List<List<dynamic>> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((c) => DataColumn(
                label: Text(c,
                    style:
                        AppTheme.body2.copyWith(fontWeight: FontWeight.w600))))
            .toList(),
        rows: rows
            .map((row) => DataRow(
                cells: row
                    .map((cell) =>
                        DataCell(Text(cell.toString(), style: AppTheme.body2)))
                    .toList()))
            .toList(),
      ),
    );
  }

  Widget _buildInsights(List<String> insights) {
    return Column(
      children: insights.map((insight) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.lightbulb,
                  color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(insight, style: AppTheme.body2)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
