import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/services/expense_category_service.dart';

class ExpenseCategoryManagementModal extends StatefulWidget {
  final Function() onCategoriesChanged;

  const ExpenseCategoryManagementModal({
    super.key,
    required this.onCategoriesChanged,
  });

  @override
  State<ExpenseCategoryManagementModal> createState() =>
      _ExpenseCategoryManagementModalState();
}

class _ExpenseCategoryManagementModalState
    extends State<ExpenseCategoryManagementModal> {
  List<String> _categories = [];
  bool _isLoading = true;
  String? _editingCategory;
  String _editingText = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ExpenseCategoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading expense categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add Category'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CupertinoTextField(
            placeholder: 'Enter category name',
            autofocus: true,
            onChanged: (value) => _editingText = value,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              if (_editingText.trim().isNotEmpty) {
                final success =
                    await ExpenseCategoryService.addCategory(_editingText);
                if (success) {
                  await _loadCategories();
                  widget.onCategoriesChanged();
                  if (mounted) {
                    _showSuccessMessage('Category added successfully');
                  }
                } else {
                  if (mounted) {
                    _showErrorMessage('Category already exists');
                  }
                }
              }
              _editingText = '';
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCategory(String category) async {
    _editingText = category;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Edit Category'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CupertinoTextField(
            placeholder: 'Enter category name',
            controller: TextEditingController(text: category),
            autofocus: true,
            onChanged: (value) => _editingText = value,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              if (_editingText.trim().isNotEmpty && _editingText != category) {
                final success = await ExpenseCategoryService.updateCategory(
                    category, _editingText);
                if (success) {
                  await _loadCategories();
                  widget.onCategoriesChanged();
                  if (mounted) {
                    _showSuccessMessage('Category updated successfully');
                  }
                } else {
                  if (mounted) {
                    _showErrorMessage('Category already exists');
                  }
                }
              }
              _editingText = '';
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String category) async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$category"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ExpenseCategoryService.deleteCategory(category);
              if (success) {
                await _loadCategories();
                widget.onCategoriesChanged();
                if (mounted) {
                  _showSuccessMessage('Category deleted successfully');
                }
              } else {
                if (mounted) {
                  _showErrorMessage('Failed to delete category');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Categories'),
        content: const Text(
            'This will reset all categories to default values. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await ExpenseCategoryService.resetToDefaults();
              await _loadCategories();
              widget.onCategoriesChanged();
              if (mounted) {
                _showSuccessMessage('Categories reset to defaults');
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.xmark, size: 24),
                ),
                Expanded(
                  child: Text(
                    'Manage Categories',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 44), // Balance the close button
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : Column(
                    children: [
                      // Add Category Button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            onPressed: _addCategory,
                            child: const Text('Add New Category'),
                          ),
                        ),
                      ),

                      // Categories List
                      Expanded(
                        child: _categories.isEmpty
                            ? const Center(
                                child: Text(
                                  'No categories found',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: CupertinoColors.systemGrey4),
                                      borderRadius: BorderRadius.circular(12),
                                      color: CupertinoColors.systemBackground,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              category,
                                              style: AppTheme.body1,
                                            ),
                                          ),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () =>
                                                _editCategory(category),
                                            child: const Icon(
                                              CupertinoIcons.pencil,
                                              size: 20,
                                              color: CupertinoColors.systemBlue,
                                            ),
                                          ),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () =>
                                                _deleteCategory(category),
                                            child: const Icon(
                                              CupertinoIcons.delete,
                                              size: 20,
                                              color: CupertinoColors.systemRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Reset Button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: _resetToDefaults,
                            child: const Text('Reset to Defaults'),
                          ),
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
