import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/core/services/category_service.dart';
import 'package:stocked/features/stock/presentation/providers/stock_provider.dart';
import 'package:stocked/features/stock/presentation/widgets/add_item_modal.dart';
import 'package:stocked/features/stock/presentation/widgets/item_detail_modal.dart';
import 'package:stocked/features/stock/presentation/widgets/category_management_modal.dart';

class StockManagementScreen extends ConsumerStatefulWidget {
  const StockManagementScreen({super.key});

  @override
  ConsumerState<StockManagementScreen> createState() =>
      _StockManagementScreenState();
}

class _StockManagementScreenState extends ConsumerState<StockManagementScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      if (categories.isEmpty) {
        // Initialize default categories if none exist
        await CategoryService.initializeDefaultCategories();
        final defaultCategories = await CategoryService.getCategories();
        setState(() {
          _categories = ['All', ...defaultCategories];
        });
      } else {
        setState(() {
          _categories = ['All', ...categories];
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      setState(() {
        _categories = ['All', ...CategoryService.getDefaultCategories()];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockProviderNotifier);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock Management',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage inventory and track stock levels',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    onPressed: () => _showAddItemModal(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Add Item',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filter Section
            Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  CupertinoSearchTextField(
                    placeholder: 'Search items by name, category, or SKU...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: AppTheme.body1.copyWith(fontSize: 16),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
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
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        onPressed: _showManageCategoriesModal,
                        child: const Icon(
                          CupertinoIcons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stock Summary Cards
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
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
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Low Stock Items',
                      value:
                          '${stockState.items.where((item) => (item.currentStock ?? 0) <= (item.lowStockThreshold ?? 10)).length}',
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Categories',
                      value:
                          '${stockState.items.map((item) => item.category).where((cat) => cat != null).toSet().length}',
                      icon: CupertinoIcons.folder,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Items List
            stockState.isLoading
                ? Container(
                    height: 400,
                    child: const Center(child: CupertinoActivityIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildItemsList(stockState.items),
                  ),

            // Bottom padding for better scrolling experience
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme.heading2.copyWith(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.body2.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
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
      return Container(
        margin: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  CupertinoIcons.cube_box,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No items found',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add your first item to get started',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                onPressed: () => _showAddItemModal(context),
                child: const Text(
                  'Add First Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...filteredItems.map((item) {
          final isLowStock =
              (item.currentStock ?? 0) <= (item.lowStockThreshold ?? 10);

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showItemDetailModal(context, item),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Item Image or Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(
                                        CupertinoIcons.cube_box,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      child: CupertinoActivityIndicator(
                                        color: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(16),
                                child: Icon(
                                  CupertinoIcons.cube_box,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                      ),
                      const SizedBox(width: 20),

                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name ?? 'Unnamed Item',
                                    style: AppTheme.heading3.copyWith(
                                      color: AppTheme.textPrimaryColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (isLowStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'LOW STOCK',
                                      style: AppTheme.body2.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Category: ${item.category ?? 'Uncategorized'}',
                              style: AppTheme.body2.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Price: ₹${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
                                  style: AppTheme.body2.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  'Stock: ${item.currentStock ?? 0}',
                                  style: AppTheme.body2.copyWith(
                                    color: isLowStock
                                        ? AppTheme.warningColor
                                        : AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                    fontWeight: isLowStock
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            if (item.sku != null && item.sku!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${item.sku}',
                                style: AppTheme.body2.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Chevron
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddItemModal(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const AddItemModal()),
    ).then((_) => setState(_loadCategories));
  }

  void _showItemDetailModal(BuildContext context, Item item) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ItemDetailModal(item: item)),
    ).then((_) => setState(_loadCategories));
  }

  void _showManageCategoriesModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CategoryManagementModal(
        categories: _categories.where((c) => c != 'All').toList(),
        onCategoriesChanged: (newCategories) async {
          setState(() {
            _categories = ['All', ...newCategories];
          });
        },
      ),
    );
  }
}
