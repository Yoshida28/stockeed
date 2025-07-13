import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/services/config_service.dart';
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
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    try {
      final categories = ConfigService.get<List<String>>('item_categories');
      setState(() {
        _categories = ['All', ...categories];
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      setState(() {
        _categories = [
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockProviderNotifier);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Stock Management',
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 140),
                child: CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                  onPressed: () => _showAddItemModal(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                          child: Text('Add Item',
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassmorphicDecoration,
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                prefixIcon:
                    Icon(CupertinoIcons.search, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),

              // Category Filter
              Row(
                children: [
                  Flexible(
                    child: SizedBox(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 44),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      onPressed: _showManageCategoriesModal,
                      child: const Icon(CupertinoIcons.settings,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
                        fontWeight:
                            isLowStock ? FontWeight.w600 : FontWeight.normal,
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
      builder: (context) => _ManageCategoriesModal(
        categories: _categories.where((c) => c != 'All').toList(),
        onCategoriesChanged: (newCategories) async {
          await ConfigService.set('item_categories', newCategories);
          _loadCategories();
        },
      ),
    );
  }
}

class _ManageCategoriesModal extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<List<String>> onCategoriesChanged;
  const _ManageCategoriesModal({
    required this.categories,
    required this.onCategoriesChanged,
  });
  @override
  State<_ManageCategoriesModal> createState() => _ManageCategoriesModalState();
}

class _ManageCategoriesModalState extends State<_ManageCategoriesModal> {
  late List<String> _categories;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Manage Categories'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'New category',
                      style: AppTheme.body1,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton.filled(
                    onPressed: () {
                      final newCat = _controller.text.trim();
                      if (newCat.isNotEmpty && !_categories.contains(newCat)) {
                        setState(() {
                          _categories.add(newCat);
                          _controller.clear();
                        });
                        widget.onCategoriesChanged(_categories);
                      }
                    },
                    child: const Icon(CupertinoIcons.add),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppTheme.glassmorphicDecoration,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Text(cat, style: AppTheme.body1),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                _categories.removeAt(index);
                              });
                              widget.onCategoriesChanged(_categories);
                            },
                            child: const Icon(CupertinoIcons.delete,
                                color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
