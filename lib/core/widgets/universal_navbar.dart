import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:stocked/features/stock/presentation/screens/stock_management_screen.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_detail_screen.dart';
import 'package:stocked/features/orders/presentation/screens/orders_screen.dart';
import 'package:stocked/features/payments/presentation/screens/payments_screen.dart';
import 'package:stocked/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:stocked/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:stocked/features/settings/presentation/screens/settings_screen.dart';

class UniversalNavbar extends ConsumerStatefulWidget {
  final Widget child;

  const UniversalNavbar({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UniversalNavbar> createState() => _UniversalNavbarState();
}

class _UniversalNavbarState extends ConsumerState<UniversalNavbar> {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderNotifier);
    final navigationState = ref.watch(navigationProvider);
    final user = authState.user;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    if (isMobile) {
      // Mobile layout: bottom nav bar
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_navItems[navigationState.currentIndex]['label'],
              style: AppTheme.heading3.copyWith(fontSize: 18)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: widget.child),
              CupertinoTabBar(
                currentIndex: navigationState.currentIndex,
                onTap: (index) => _handleNavigation(index),
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
            width: navigationState.isNavbarCollapsed ? 80 : 250,
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
                  padding: EdgeInsets.all(
                      navigationState.isNavbarCollapsed ? 8 : 24),
                  child: Row(
                    children: [
                      Flexible(
                        child: Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppTheme.primaryColor,
                          size: navigationState.isNavbarCollapsed ? 24 : 32,
                        ),
                      ),
                      if (!navigationState.isNavbarCollapsed) ...[
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
                          ref
                              .read(navigationProvider.notifier)
                              .toggleNavbarCollapse();
                        },
                        icon: Icon(
                          navigationState.isNavbarCollapsed
                              ? CupertinoIcons.chevron_right
                              : CupertinoIcons.chevron_left,
                          color: AppTheme.textSecondaryColor,
                        ),
                        iconSize: navigationState.isNavbarCollapsed ? 18 : 22,
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
                      final isSelected = navigationState.currentIndex == index;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _handleNavigation(index),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    navigationState.isNavbarCollapsed ? 8 : 16,
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
                                      size: navigationState.isNavbarCollapsed
                                          ? 20
                                          : 24,
                                    ),
                                  ),
                                  if (!navigationState.isNavbarCollapsed) ...[
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
                  padding: EdgeInsets.all(
                      navigationState.isNavbarCollapsed ? 8 : 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: navigationState.isNavbarCollapsed ? 16 : 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppTheme.primaryColor,
                          size: navigationState.isNavbarCollapsed ? 16 : 24,
                        ),
                      ),
                      if (!navigationState.isNavbarCollapsed) ...[
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
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    final navigationState = ref.read(navigationProvider);
    if (index == navigationState.currentIndex) return; // Already on this page
    ref.read(navigationProvider.notifier).setCurrentIndex(index);
  }
}
