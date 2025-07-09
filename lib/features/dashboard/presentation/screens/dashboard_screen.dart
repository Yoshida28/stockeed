import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/features/stock/presentation/screens/stock_management_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProviderNotifier);
    final user = authState.user;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => ref.read(authProviderNotifier.notifier).signOut(),
          child: const Icon(CupertinoIcons.square_arrow_right),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassmorphicDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Today\'s Sales',
                      value: '₹12,450',
                      icon: CupertinoIcons.chart_bar,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Today\'s Profit',
                      value: '₹5,200',
                      icon: CupertinoIcons.chart_bar,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pending Orders',
                      value: '8',
                      icon: CupertinoIcons.clock,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Low Stock Items',
                      value: '3',
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text('Quick Actions', style: AppTheme.heading2),
              const SizedBox(height: 16),

              // Action Grid
              _buildActionGrid(context),
              const SizedBox(height: 32),

              // Recent Activity
              Text('Recent Activity', style: AppTheme.heading2),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassmorphicDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(value, style: AppTheme.heading2.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {
        'title': 'Stock Management',
        'icon': CupertinoIcons.cube_box,
        'color': AppTheme.primaryColor,
        'onTap': () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const StockManagementScreen(),
          ),
        ),
      },
      {
        'title': 'Orders',
        'icon': CupertinoIcons.shopping_cart,
        'color': AppTheme.successColor,
        'onTap': () => _showComingSoon(context, 'Orders Management'),
      },
      {
        'title': 'Vouchers',
        'icon': CupertinoIcons.ticket,
        'color': AppTheme.warningColor,
        'onTap': () => _showComingSoon(context, 'Voucher Management'),
      },
      {
        'title': 'Payments',
        'icon': CupertinoIcons.creditcard,
        'color': AppTheme.infoColor,
        'onTap': () => _showComingSoon(context, 'Payment Management'),
      },
      {
        'title': 'Expenses',
        'icon': CupertinoIcons.money_dollar_circle,
        'color': AppTheme.errorColor,
        'onTap': () => _showComingSoon(context, 'Expense Management'),
      },
      {
        'title': 'Analytics',
        'icon': CupertinoIcons.chart_bar_alt_fill,
        'color': AppTheme.secondaryColor,
        'onTap': () => _showComingSoon(context, 'Analytics Dashboard'),
      },
      {
        'title': 'Clients',
        'icon': CupertinoIcons.person_2,
        'color': AppTheme.accentColor,
        'onTap': () => _showComingSoon(context, 'Client Management'),
      },
      {
        'title': 'Settings',
        'icon': CupertinoIcons.settings,
        'color': AppTheme.textSecondaryColor,
        'onTap': () => _showComingSoon(context, 'Settings'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: action['onTap'] as VoidCallback,
          child: Container(
            decoration: AppTheme.glassmorphicDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  action['title'] as String,
                  style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'New order #ORD-001 created',
        'time': '2 minutes ago',
        'icon': CupertinoIcons.shopping_cart,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Payment received for #PAY-005',
        'time': '15 minutes ago',
        'icon': CupertinoIcons.creditcard,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Low stock alert: iPhone 13',
        'time': '1 hour ago',
        'icon': CupertinoIcons.exclamationmark_triangle,
        'color': AppTheme.warningColor,
      },
      {
        'title': 'New client registered',
        'time': '2 hours ago',
        'icon': CupertinoIcons.person_add,
        'color': AppTheme.infoColor,
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassmorphicDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: activity['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity['title'] as String, style: AppTheme.body1),
                    const SizedBox(height: 4),
                    Text(activity['time'] as String, style: AppTheme.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
