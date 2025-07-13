import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/features/stock/presentation/providers/stock_provider.dart';

class AddItemModal extends ConsumerStatefulWidget {
  const AddItemModal({super.key});

  @override
  ConsumerState<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends ConsumerState<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _gstController = TextEditingController();
  final _openingStockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();

  String _selectedCategory = '';
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    try {
      final categories = ConfigService.get<List<String>>('item_categories');
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : '';
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      setState(() {
        _categories = [
          'Electronics',
          'Clothing',
          'Food & Beverages',
          'Home & Garden',
          'Sports',
          'Books',
          'Automotive',
          'Health & Beauty',
          'Toys & Games',
          'Other',
        ];
        _selectedCategory = 'Electronics';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _gstController.dispose();
    _openingStockController.dispose();
    _lowStockThresholdController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                Text('Add New Item', style: AppTheme.heading3),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('Save'),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Item Name *',
                      placeholder: 'Enter item name',
                      icon: CupertinoIcons.cube_box,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    _buildCategoryPicker(),
                    const SizedBox(height: 16),

                    // Price and GST Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _unitPriceController,
                            label: 'Unit Price (₹) *',
                            placeholder: '0.00',
                            icon: CupertinoIcons.money_dollar,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _gstController,
                            label: 'GST (%)',
                            placeholder: '18',
                            icon: CupertinoIcons.percent,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _openingStockController,
                            label: 'Opening Stock *',
                            placeholder: '0',
                            icon: CupertinoIcons.number,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _lowStockThresholdController,
                            label: 'Low Stock Alert',
                            placeholder: '10',
                            icon: CupertinoIcons.exclamationmark_triangle,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SKU and Barcode Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _skuController,
                            label: 'SKU',
                            placeholder: 'Enter SKU',
                            icon: CupertinoIcons.tag,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _barcodeController,
                            label: 'Barcode',
                            placeholder: 'Enter barcode',
                            icon: CupertinoIcons.barcode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      placeholder: 'Enter item description',
                      icon: CupertinoIcons.text_quote,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassmorphicDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.info_circle,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Item Information',
                                style: AppTheme.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Item name and unit price are required fields\n'
                            '• Opening stock will be set as current stock\n'
                            '• Low stock alerts will notify when stock falls below threshold\n'
                            '• GST percentage is optional but recommended for tax compliance\n'
                            '• SKU and barcode help with inventory tracking',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: AppTheme.body2.copyWith(
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            style: AppTheme.body1,
            keyboardType: keyboardType,
            maxLines: maxLines,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.folder,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                  },
                  children: _categories.map((category) {
                    return Center(child: Text(category, style: AppTheme.body1));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final item = Item(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0.0,
        gstPercentage: double.tryParse(_gstController.text) ??
            ConfigService.get<double>('default_gst_rate'),
        openingStock: int.tryParse(_openingStockController.text) ?? 0,
        currentStock: int.tryParse(_openingStockController.text) ?? 0,
        lowStockThreshold: int.tryParse(_lowStockThresholdController.text) ??
            ConfigService.get<int>('default_low_stock_threshold'),
        description: _descriptionController.text.trim(),
        barcode: _barcodeController.text.trim(),
        sku: _skuController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add item using provider
      await ref.read(stockProviderNotifier.notifier).addItem(item);

      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
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
