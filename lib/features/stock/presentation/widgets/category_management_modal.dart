import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/services/category_service.dart';

class CategoryManagementModal extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<List<String>> onCategoriesChanged;

  const CategoryManagementModal({
    super.key,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  State<CategoryManagementModal> createState() =>
      _CategoryManagementModalState();
}

class _CategoryManagementModalState extends State<CategoryManagementModal> {
  final _newCategoryController = TextEditingController();
  final _editCategoryController = TextEditingController();
  List<String> _categories = [];
  bool _isLoading = false;
  String? _editingCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    _editCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await CategoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading categories: $e');
    }
  }

  Future<void> _addCategory() async {
    final categoryName = _newCategoryController.text.trim();
    if (categoryName.isEmpty) {
      _showErrorDialog('Please enter a category name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await CategoryService.addCategory(categoryName);
      if (success) {
        _newCategoryController.clear();
        await _loadCategories();
        widget.onCategoriesChanged(_categories);
        _showSuccessDialog('Category added successfully');
      } else {
        _showErrorDialog('Category already exists');
      }
    } catch (e) {
      _showErrorDialog('Error adding category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editCategory(String oldName) async {
    _editCategoryController.text = oldName;
    setState(() {
      _editingCategory = oldName;
    });
  }

  Future<void> _saveEditCategory() async {
    final newName = _editCategoryController.text.trim();
    if (newName.isEmpty) {
      _showErrorDialog('Please enter a category name');
      return;
    }

    if (_editingCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await CategoryService.updateCategory(_editingCategory!, newName);
      if (success) {
        setState(() {
          _editingCategory = null;
        });
        _editCategoryController.clear();
        await _loadCategories();
        widget.onCategoriesChanged(_categories);
        _showSuccessDialog('Category updated successfully');
      } else {
        _showErrorDialog('Category name already exists');
      }
    } catch (e) {
      _showErrorDialog('Error updating category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory(String categoryName) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "$categoryName"?\n\nAll items in this category will be moved to "Uncategorized".'),
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

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await CategoryService.deleteCategory(categoryName);
      if (success) {
        await _loadCategories();
        widget.onCategoriesChanged(_categories);
        _showSuccessDialog('Category deleted successfully');
      } else {
        _showErrorDialog('Error deleting category');
      }
    } catch (e) {
      _showErrorDialog('Error deleting category: $e');
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

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
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

  @override
  Widget build(BuildContext context) {
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
                Text('Manage Categories', style: AppTheme.heading3),
                const Spacer(),
                const SizedBox(width: 60), // Balance the header
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : Column(
                    children: [
                      // Add Category Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add New Category',
                              style: AppTheme.heading4,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: _newCategoryController,
                                    placeholder: 'Enter category name',
                                    style: AppTheme.body1,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CupertinoButton(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  onPressed: _addCategory,
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      // Categories List
                      Expanded(
                        child: _categories.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.folder,
                                      size: 64,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No categories yet',
                                      style: AppTheme.heading3.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add your first category to get started',
                                      style: AppTheme.body2.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  final isEditing =
                                      _editingCategory == category;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: Icon(
                                        CupertinoIcons.folder,
                                        color: AppTheme.primaryColor,
                                      ),
                                      title: isEditing
                                          ? CupertinoTextField(
                                              controller:
                                                  _editCategoryController,
                                              style: AppTheme.body1,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            )
                                          : Text(
                                              category,
                                              style: AppTheme.body1,
                                            ),
                                      trailing: isEditing
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: _saveEditCategory,
                                                  child: const Icon(
                                                    CupertinoIcons.check_mark,
                                                    color:
                                                        AppTheme.successColor,
                                                  ),
                                                ),
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    setState(() {
                                                      _editingCategory = null;
                                                    });
                                                    _editCategoryController
                                                        .clear();
                                                  },
                                                  child: const Icon(
                                                    CupertinoIcons.xmark,
                                                    color: AppTheme.errorColor,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () =>
                                                      _editCategory(category),
                                                  child: const Icon(
                                                    CupertinoIcons.pencil,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                                CupertinoButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () =>
                                                      _deleteCategory(category),
                                                  child: const Icon(
                                                    CupertinoIcons.delete,
                                                    color: AppTheme.errorColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
