import 'dart:convert';
import 'package:stocked/core/services/database_service.dart';

class CategoryService {
  static const String _categoriesKey = 'user_categories';

  /// Get all user-defined categories
  static Future<List<String>> getCategories() async {
    try {
      final categoriesJson = await DatabaseService.getSetting(_categoriesKey);
      if (categoriesJson != null && categoriesJson is String) {
        final List<dynamic> categoriesList = jsonDecode(categoriesJson);
        return categoriesList.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  /// Add a new category
  static Future<bool> addCategory(String categoryName) async {
    try {
      final categories = await getCategories();

      // Check if category already exists
      if (categories.contains(categoryName.trim())) {
        return false; // Category already exists
      }

      // Add new category
      categories.add(categoryName.trim());

      // Save to database as JSON string
      await DatabaseService.setSetting(_categoriesKey, jsonEncode(categories));

      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  /// Update an existing category
  static Future<bool> updateCategory(String oldName, String newName) async {
    try {
      final categories = await getCategories();

      // Check if new name already exists
      if (categories.contains(newName.trim()) && oldName != newName) {
        return false; // New name already exists
      }

      // Find and update the category
      final index = categories.indexOf(oldName);
      if (index == -1) {
        return false; // Category not found
      }

      categories[index] = newName.trim();

      // Save to database as JSON string
      await DatabaseService.setSetting(_categoriesKey, jsonEncode(categories));

      // Update all items that use this category
      await _updateItemsCategory(oldName, newName.trim());

      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  /// Delete a category
  static Future<bool> deleteCategory(String categoryName) async {
    try {
      final categories = await getCategories();

      // Check if category exists
      if (!categories.contains(categoryName)) {
        return false; // Category not found
      }

      // Remove category
      categories.remove(categoryName);

      // Save to database as JSON string
      await DatabaseService.setSetting(_categoriesKey, jsonEncode(categories));

      // Update all items that use this category to "Uncategorized"
      await _updateItemsCategory(categoryName, 'Uncategorized');

      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  /// Update all items that use a specific category
  static Future<void> _updateItemsCategory(
      String oldCategory, String newCategory) async {
    try {
      // Get all items
      final items = await DatabaseService.getAllItems();

      // Update items that use the old category
      for (final item in items) {
        if (item.category == oldCategory) {
          final updatedItem = item.copyWith(category: newCategory);
          await DatabaseService.saveItem(updatedItem);
        }
      }
    } catch (e) {
      print('Error updating items category: $e');
    }
  }

  /// Get default categories (used when no user categories exist)
  static List<String> getDefaultCategories() {
    return [
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
  }

  /// Initialize categories if none exist
  static Future<void> initializeDefaultCategories() async {
    try {
      final categories = await getCategories();
      if (categories.isEmpty) {
        final defaultCategories = getDefaultCategories();
        await DatabaseService.setSetting(
            _categoriesKey, jsonEncode(defaultCategories));
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  /// Check if a category exists
  static Future<bool> categoryExists(String categoryName) async {
    try {
      final categories = await getCategories();
      return categories.contains(categoryName.trim());
    } catch (e) {
      print('Error checking category existence: $e');
      return false;
    }
  }

  /// Get category statistics
  static Future<Map<String, int>> getCategoryStats() async {
    try {
      final items = await DatabaseService.getAllItems();
      final stats = <String, int>{};

      for (final item in items) {
        if (item.category != null) {
          stats[item.category!] = (stats[item.category!] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting category stats: $e');
      return {};
    }
  }
}
