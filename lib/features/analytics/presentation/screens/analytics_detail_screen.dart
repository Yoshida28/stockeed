import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocked/core/theme/app_theme.dart';

class AnalyticsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> graphData;

  const AnalyticsDetailScreen({
    super.key,
    required this.graphData,
  });

  @override
  State<AnalyticsDetailScreen> createState() => _AnalyticsDetailScreenState();
}

class _AnalyticsDetailScreenState extends State<AnalyticsDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.graphData['title']),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.graphData['title'],
                      style: AppTheme.heading1
                          .copyWith(color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.graphData['subtitle'],
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildMetricCard(
                          'Total Items',
                          widget.graphData['data'].length.toString(),
                          CupertinoIcons.number,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          'Total Value',
                          _calculateTotalValue().toString(),
                          CupertinoIcons.chart_bar,
                        ),
                        const SizedBox(width: 16),
                        _buildMetricCard(
                          'Average',
                          _calculateAverage().toStringAsFixed(1),
                          CupertinoIcons.chart_bar,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Detailed Chart
              Container(
                height: 400,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Analysis',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildDetailedChart(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Data Table
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Breakdown',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 16),
                    _buildDataTable(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Insights Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Insights',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTheme.body2.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.heading3.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedChart() {
    final type = widget.graphData['type'];
    final data = widget.graphData['data'];

    switch (type) {
      case 'bar':
        return _buildDetailedBarChart(data);
      case 'line':
        return _buildDetailedLineChart(data);
      case 'pie':
        return _buildDetailedPieChart(data);
      default:
        return _buildDetailedBarChart(data);
    }
  }

  Widget _buildDetailedBarChart(List<Map<String, dynamic>> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.fold<double>(
                0,
                (max, item) =>
                    item['value'] > max ? item['value'].toDouble() : max) *
            1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x]['name']}\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
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
                color: _getColorForIndex(index),
                width: 30,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedLineChart(List<Map<String, dynamic>> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
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
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPieChart(List<Map<String, dynamic>> data) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              sections: data.map((item) {
                final total =
                    data.fold<double>(0, (sum, d) => sum + d['value']);
                final percentage = (item['value'] / total) * 100;

                return PieChartSectionData(
                  color: _getColorForIndex(data.indexOf(item)),
                  value: item['value'].toDouble(),
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: AppTheme.body2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              final total = data.fold<double>(0, (sum, d) => sum + d['value']);
              final percentage = (item['value'] / total) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorForIndex(data.indexOf(item)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['category'] ?? item['name'],
                            style: AppTheme.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}% (${item['value']})',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    final data = widget.graphData['data'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Rank',
                style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Name',
                style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Value',
                style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Percentage',
                style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
        rows: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final total = data.fold<double>(0, (sum, d) => sum + d['value']);
          final percentage = (item['value'] / total) * 100;

          return DataRow(
            cells: [
              DataCell(Text('${index + 1}', style: AppTheme.body2)),
              DataCell(Text(item['name'] ?? item['category'] ?? item['month'],
                  style: AppTheme.body2)),
              DataCell(Text(item['value'].toString(), style: AppTheme.body2)),
              DataCell(Text('${percentage.toStringAsFixed(1)}%',
                  style: AppTheme.body2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsList() {
    final data = widget.graphData['data'];
    final insights = <String>[];

    // Generate insights based on data
    if (data.isNotEmpty) {
      final maxValue = data.fold<double>(0,
          (max, item) => item['value'] > max ? item['value'].toDouble() : max);
      final minValue = data.fold<double>(double.infinity,
          (min, item) => item['value'] < min ? item['value'].toDouble() : min);
      final total = data.fold<double>(0, (sum, item) => sum + item['value']);

      final topItem = data.firstWhere((item) => item['value'] == maxValue);
      final bottomItem = data.firstWhere((item) => item['value'] == minValue);

      insights.addAll([
        'Top performer: ${topItem['name'] ?? topItem['category'] ?? topItem['month']} with ${maxValue} units',
        'Lowest performer: ${bottomItem['name'] ?? bottomItem['category'] ?? bottomItem['month']} with ${minValue} units',
        'Total volume: ${total} units across all categories',
        'Performance gap: ${((maxValue - minValue) / maxValue * 100).toStringAsFixed(1)}% difference between top and bottom',
      ]);
    }

    return Column(
      children: insights.map((insight) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight,
                  style: AppTheme.body2,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      AppTheme.infoColor,
    ];
    return colors[index % colors.length];
  }

  int _calculateTotalValue() {
    return widget.graphData['data']
        .fold<int>(0, (sum, item) => sum + item['value']);
  }

  double _calculateAverage() {
    final data = widget.graphData['data'];
    if (data.isEmpty) return 0;
    return data.fold<int>(0, (sum, item) => sum + item['value']) / data.length;
  }
}
