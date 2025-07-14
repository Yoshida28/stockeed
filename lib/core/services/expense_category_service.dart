import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseCategoryService {
  static const String _storageKey = 'expense_categories';
  static const List<String> _defaultCategories = [
    'Office Supplies',
    'Travel',
    'Marketing',
    'Utilities',
    'Rent',
    'Salaries',
    'Equipment',
    'Maintenance',
    'Other',
  ];

  /// Get all expense categories
  static Future<List<String>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_storageKey);

      if (categoriesJson != null) {
        final List<dynamic> categories = jsonDecode(categoriesJson);
        return categories.cast<String>();
      } else {
        // Initialize with default categories if none exist
        await _initializeDefaultCategories();
        return _defaultCategories;
      }
    } catch (e) {
      print('Error getting expense categories: $e');
      return _defaultCategories;
    }
  }

  /// Add a new expense category
  static Future<bool> addCategory(String category) async {
    try {
      if (category.trim().isEmpty) return false;

      final categories = await getCategories();
      final trimmedCategory = category.trim();

      // Check if category already exists (case-insensitive)
      if (categories
          .any((cat) => cat.toLowerCase() == trimmedCategory.toLowerCase())) {
        return false;
      }

      categories.add(trimmedCategory);
      await _saveCategories(categories);
      return true;
    } catch (e) {
      print('Error adding expense category: $e');
      return false;
    }
  }

  /// Update an existing expense category
  static Future<bool> updateCategory(
      String oldCategory, String newCategory) async {
    try {
      if (newCategory.trim().isEmpty) return false;

      final categories = await getCategories();
      final trimmedNewCategory = newCategory.trim();

      // Check if new category already exists (case-insensitive)
      if (categories.any((cat) =>
          cat.toLowerCase() == trimmedNewCategory.toLowerCase() &&
          cat != oldCategory)) {
        return false;
      }

      final index = categories.indexOf(oldCategory);
      if (index == -1) return false;

      categories[index] = trimmedNewCategory;
      await _saveCategories(categories);
      return true;
    } catch (e) {
      print('Error updating expense category: $e');
      return false;
    }
  }

  /// Delete an expense category
  static Future<bool> deleteCategory(String category) async {
    try {
      final categories = await getCategories();
      final success = categories.remove(category);

      if (success) {
        await _saveCategories(categories);
      }

      return success;
    } catch (e) {
      print('Error deleting expense category: $e');
      return false;
    }
  }

  /// Check if a category exists
  static Future<bool> categoryExists(String category) async {
    try {
      final categories = await getCategories();
      return categories
          .any((cat) => cat.toLowerCase() == category.toLowerCase());
    } catch (e) {
      print('Error checking expense category existence: $e');
      return false;
    }
  }

  /// Reset to default categories
  static Future<void> resetToDefaults() async {
    try {
      await _saveCategories(_defaultCategories);
    } catch (e) {
      print('Error resetting expense categories: $e');
    }
  }

  /// Initialize default categories
  static Future<void> _initializeDefaultCategories() async {
    try {
      await _saveCategories(_defaultCategories);
    } catch (e) {
      print('Error initializing default expense categories: $e');
    }
  }

  /// Save categories to local storage
  static Future<void> _saveCategories(List<String> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = jsonEncode(categories);
      await prefs.setString(_storageKey, categoriesJson);
    } catch (e) {
      print('Error saving expense categories: $e');
    }
  }
}
