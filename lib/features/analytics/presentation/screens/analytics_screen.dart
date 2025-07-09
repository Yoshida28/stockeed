import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockData = [
      {
        'label': 'Total Sales',
        'value': '₹1.2M',
        'icon': CupertinoIcons.money_dollar
      },
      {'label': 'Orders', 'value': '320', 'icon': CupertinoIcons.cart},
      {'label': 'Clients', 'value': '58', 'icon': CupertinoIcons.person_2},
      {
        'label': 'Top Category',
        'value': 'Electronics',
        'icon': CupertinoIcons.cube_box
      },
    ];
    final List<Map<String, dynamic>> barData = [
      {'name': 'Jan', 'value': 12000},
      {'name': 'Feb', 'value': 18000},
      {'name': 'Mar', 'value': 15000},
      {'name': 'Apr', 'value': 22000},
      {'name': 'May', 'value': 20000},
      {'name': 'Jun', 'value': 25000},
    ];
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Analytics'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.chart_bar,
                      color: AppTheme.primaryColor, size: 32),
                  const SizedBox(width: 12),
                  Text('Analytics', style: AppTheme.heading2),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: mockData
                    .map((stat) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.glassmorphicDecoration,
                            child: Column(
                              children: [
                                Icon(stat['icon'] as IconData,
                                    color: AppTheme.primaryColor, size: 28),
                                const SizedBox(height: 8),
                                Text(stat['value'] as String,
                                    style: AppTheme.heading3),
                                const SizedBox(height: 4),
                                Text(stat['label'] as String,
                                    style: AppTheme.caption),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Container(
                height: 300,
                decoration: AppTheme.glassmorphicDecoration,
                padding: const EdgeInsets.all(24),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 30000,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < barData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                    barData[value.toInt()]['name'] as String,
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
                            return Text(value.toInt().toString(),
                                style: AppTheme.caption);
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: (item['value'] as int).toDouble(),
                            color: AppTheme.primaryColor,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
