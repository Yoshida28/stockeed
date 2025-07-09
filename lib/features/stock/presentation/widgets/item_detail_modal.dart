import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/features/stock/presentation/providers/stock_provider.dart';

class ItemDetailModal extends ConsumerStatefulWidget {
  final Item item;

  const ItemDetailModal({super.key, required this.item});

  @override
  ConsumerState<ItemDetailModal> createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends ConsumerState<ItemDetailModal> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _gstController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.item.name ?? '';
    _unitPriceController.text = widget.item.unitPrice?.toString() ?? '';
    _gstController.text = widget.item.gstPercentage?.toString() ?? '';
    _currentStockController.text = widget.item.currentStock?.toString() ?? '';
    _lowStockThresholdController.text =
        widget.item.lowStockThreshold?.toString() ?? '';
    _descriptionController.text = widget.item.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitPriceController.dispose();
    _gstController.dispose();
    _currentStockController.dispose();
    _lowStockThresholdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isLowStock =
        (item.currentStock ?? 0) <= (item.lowStockThreshold ?? 10);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                  child: const Text('Close'),
                ),
                const Spacer(),
                Text(
                  _isEditing ? 'Edit Item' : 'Item Details',
                  style: AppTheme.heading3,
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  child: Text(_isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stock Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassmorphicDecoration,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.cube_box,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name ?? 'Unnamed Item',
                                style: AppTheme.heading3,
                              ),
                            ),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'LOW STOCK',
                                  style: AppTheme.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusItem(
                                'Current Stock',
                                '${item.currentStock ?? 0}',
                                CupertinoIcons.number,
                                isLowStock
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatusItem(
                                'Unit Price',
                                '₹${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}',
                                CupertinoIcons.money_dollar,
                                AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassmorphicDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Details', style: AppTheme.heading4),
                        const SizedBox(height: 16),

                        // Category
                        _buildDetailRow(
                          'Category',
                          item.category ?? 'Uncategorized',
                        ),
                        const SizedBox(height: 8),

                        // SKU
                        if (item.sku?.isNotEmpty == true)
                          _buildDetailRow('SKU', item.sku!),
                        if (item.sku?.isNotEmpty == true)
                          const SizedBox(height: 8),

                        // Barcode
                        if (item.barcode?.isNotEmpty == true)
                          _buildDetailRow('Barcode', item.barcode!),
                        if (item.barcode?.isNotEmpty == true)
                          const SizedBox(height: 8),

                        // GST
                        _buildDetailRow(
                          'GST Rate',
                          '${item.gstPercentage?.toStringAsFixed(1) ?? '0.0'}%',
                        ),
                        const SizedBox(height: 8),

                        // Low Stock Threshold
                        _buildDetailRow(
                          'Low Stock Alert',
                          '${item.lowStockThreshold ?? 10} units',
                        ),
                        const SizedBox(height: 8),

                        // Description
                        if (item.description?.isNotEmpty == true) ...[
                          _buildDetailRow('Description', item.description!),
                          const SizedBox(height: 8),
                        ],

                        // Created Date
                        _buildDetailRow('Created', _formatDate(item.createdAt)),
                        const SizedBox(height: 8),

                        // Last Updated
                        _buildDetailRow(
                          'Last Updated',
                          _formatDate(item.updatedAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions Section
                  if (_isEditing) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassmorphicDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Item', style: AppTheme.heading4),
                          const SizedBox(height: 16),

                          // Name
                          _buildEditField(
                            controller: _nameController,
                            label: 'Item Name',
                            icon: CupertinoIcons.cube_box,
                          ),
                          const SizedBox(height: 16),

                          // Price and GST Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditField(
                                  controller: _unitPriceController,
                                  label: 'Unit Price (₹)',
                                  icon: CupertinoIcons.money_dollar,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEditField(
                                  controller: _gstController,
                                  label: 'GST (%)',
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
                                child: _buildEditField(
                                  controller: _currentStockController,
                                  label: 'Current Stock',
                                  icon: CupertinoIcons.number,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEditField(
                                  controller: _lowStockThresholdController,
                                  label: 'Low Stock Alert',
                                  icon: CupertinoIcons.exclamationmark_triangle,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          _buildEditField(
                            controller: _descriptionController,
                            label: 'Description',
                            icon: CupertinoIcons.text_quote,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton.filled(
                              onPressed: _handleSave,
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: AppTheme.primaryColor,
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text('Edit Item'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                            color: AppTheme.errorColor,
                            onPressed: _handleDelete,
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.heading4.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        Expanded(child: Text(value, style: AppTheme.body1)),
      ],
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(fontWeight: FontWeight.w600),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleSave() async {
    try {
      final updatedItem = widget.item.copyWith(
        name: _nameController.text.trim(),
        unitPrice:
            double.tryParse(_unitPriceController.text) ?? widget.item.unitPrice,
        gstPercentage:
            double.tryParse(_gstController.text) ?? widget.item.gstPercentage,
        currentStock:
            int.tryParse(_currentStockController.text) ??
            widget.item.currentStock,
        lowStockThreshold:
            int.tryParse(_lowStockThresholdController.text) ??
            widget.item.lowStockThreshold,
        description: _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending_sync',
      );

      // Update item using provider
      await ref.read(stockProviderNotifier.notifier).updateItem(updatedItem);

      setState(() {
        _isEditing = false;
      });

      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${widget.item.name}"? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete item using provider
        await ref.read(stockProviderNotifier.notifier).deleteItem(widget.item.id);
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog(e.toString());
      }
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
