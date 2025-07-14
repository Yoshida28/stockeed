import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/core/services/image_upload_service.dart';
import 'package:stocked/core/services/category_service.dart';
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
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

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
          _categories = defaultCategories;
          _selectedCategory =
              defaultCategories.isNotEmpty ? defaultCategories.first : '';
        });
      } else {
        setState(() {
          _categories = categories;
          _selectedCategory = categories.isNotEmpty ? categories.first : '';
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories
      setState(() {
        _categories = CategoryService.getDefaultCategories();
        _selectedCategory = 'Electronics';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final File? image = await ImageUploadService.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String? imageUrl =
          await ImageUploadService.uploadImageToBucket(_selectedImage!);
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
      } else {
        _showErrorDialog('Failed to upload image');
      }
    } catch (e) {
      _showErrorDialog('Error uploading image: $e');
    } finally {
      setState(() {
        _isUploadingImage = false;
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

                    // Image Upload
                    _buildImageUploadSection(),
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Image',
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Image Preview
        if (_selectedImage != null)
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Upload Controls
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: CupertinoTextField(
                  controller:
                      TextEditingController(text: _uploadedImageUrl ?? ''),
                  placeholder: 'No image selected',
                  placeholderStyle: AppTheme.body2.copyWith(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                  style: AppTheme.body1,
                  readOnly: true,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(CupertinoIcons.photo,
                        color: AppTheme.primaryColor, size: 20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              onPressed:
                  _isUploadingImage ? null : () => _showImageSourceDialog(),
              child: Icon(
                CupertinoIcons.plus,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),

        // Upload Button
        if (_selectedImage != null && _uploadedImageUrl == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                onPressed: _isUploadingImage ? null : _uploadImage,
                child: _isUploadingImage
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text('Upload Image'),
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected but not yet uploaded
      String? finalImageUrl = _uploadedImageUrl;
      if (_selectedImage != null && _uploadedImageUrl == null) {
        finalImageUrl =
            await ImageUploadService.uploadImageToBucket(_selectedImage!);
        if (finalImageUrl == null) {
          throw Exception('Failed to upload image');
        }
      }

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
        imageUrl: finalImageUrl,
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
