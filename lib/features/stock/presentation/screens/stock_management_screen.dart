import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/features/stock/presentation/providers/stock_provider.dart';
import 'package:stocked/features/stock/presentation/widgets/add_item_modal.dart';
import 'package:stocked/features/stock/presentation/widgets/item_detail_modal.dart';

class StockManagementScreen extends ConsumerStatefulWidget {
  const StockManagementScreen({super.key});

  @override
  ConsumerState<StockManagementScreen> createState() =>
      _StockManagementScreenState();
}

class _StockManagementScreenState extends ConsumerState<StockManagementScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Home & Garden',
    'Sports',
    'Books',
    'Automotive',
    'Health & Beauty',
    'Toys & Games',
  ];

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockProviderNotifier);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Stock Management'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showAddItemModal(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassmorphicDecoration,
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  CupertinoSearchTextField(
                    placeholder: 'Search items...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: AppTheme.body1,
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  Container(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            onPressed: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Text(
                              category,
                              style: AppTheme.body2.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Stock Summary Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Items',
                      value: '${stockState.items.length}',
                      icon: CupertinoIcons.cube_box,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Low Stock',
                      value:
                          '${stockState.items.where((item) => (item.currentStock ?? 0) <= (item.lowStockThreshold ?? 10)).length}',
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: stockState.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _buildItemsList(stockState.items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
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

  Widget _buildItemsList(List<Item> items) {
    final filteredItems = items.where((item) {
      final matchesSearch =
          item.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.cube_box,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Add your first item to get started', style: AppTheme.body2),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final isLowStock =
            (item.currentStock ?? 0) <= (item.lowStockThreshold ?? 10);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.glassmorphicDecoration,
          child: CupertinoListTile(
            title: Text(
              item.name ?? 'Unnamed Item',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Category: ${item.category ?? 'Uncategorized'}',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  'Price: ₹${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Stock: ${item.currentStock ?? 0}',
                      style: AppTheme.caption.copyWith(
                        color: isLowStock
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                        fontWeight: isLowStock
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (isLowStock) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LOW',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showItemDetailModal(context, item),
              child: const Icon(CupertinoIcons.chevron_right),
            ),
            onTap: () => _showItemDetailModal(context, item),
          ),
        );
      },
    );
  }

  void _showAddItemModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const AddItemModal(),
    );
  }

  void _showItemDetailModal(BuildContext context, Item item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ItemDetailModal(item: item),
    );
  }
}

// Stock management screen implementation
