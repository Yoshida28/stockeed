import 'package:isar/isar.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/constants/app_constants.dart';

class ConfigService {
  static final Map<String, dynamic> _cache = {};
  static bool _isInitialized = false;

  // Default configurations
  static const Map<String, dynamic> _defaultConfig = {
    'item_categories': [
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
    ],
    'payment_modes': [
      'Cash',
      'Bank Transfer',
      'UPI',
      'Cheque',
      'Credit Card',
      'Debit Card',
    ],
    'voucher_types': ['Sales', 'Purchase', 'Payment', 'Receipt', 'Journal'],
    'order_statuses': [
      'Pending',
      'Accepted',
      'Dispatched',
      'Delivered',
      'Cancelled',
    ],
    'payment_statuses': ['Pending', 'Partial', 'Paid'],
    'expense_categories': [
      'Office Supplies',
      'Travel',
      'Marketing',
      'Utilities',
      'Rent',
      'Salaries',
      'Equipment',
      'Maintenance',
      'Other',
    ],
    'default_gst_rate': 18.0,
    'default_low_stock_threshold': 10,
    'company_name': 'Stocked Business',
    'app_version': '1.0.0',
    'currency_symbol': '₹',
    'date_format': 'dd/MM/yyyy',
    'time_format': 'HH:mm',
    'max_file_size_mb': 10,
    'sync_interval_minutes': 15,
    'backup_enabled': true,
    'notifications_enabled': true,
  };

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load configurations from database
      await _loadFromDatabase();

      // Set defaults for missing configurations
      _setDefaults();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing config service: $e');
      // Use defaults if database is not available
      _cache.addAll(_defaultConfig);
      _isInitialized = true;
    }
  }

  static Future<void> _loadFromDatabase() async {
    try {
      // This would load from a settings table in the database
      // For now, we'll use the default config
      _cache.addAll(_defaultConfig);
    } catch (e) {
      print('Error loading config from database: $e');
      _cache.addAll(_defaultConfig);
    }
  }

  static void _setDefaults() {
    for (final entry in _defaultConfig.entries) {
      if (!_cache.containsKey(entry.key)) {
        _cache[entry.key] = entry.value;
      }
    }
  }

  // Get configuration value
  static T get<T>(String key, {T? defaultValue}) {
    if (!_isInitialized) {
      throw Exception(
        'ConfigService not initialized. Call initialize() first.',
      );
    }

    final value = _cache[key];
    if (value != null) {
      return value as T;
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw Exception(
      'Configuration key "$key" not found and no default provided.',
    );
  }

  // Set configuration value
  static Future<void> set<T>(String key, T value) async {
    if (!_isInitialized) {
      throw Exception(
        'ConfigService not initialized. Call initialize() first.',
      );
    }

    _cache[key] = value;

    // Save to database
    await _saveToDatabase(key, value);
  }

  static Future<void> _saveToDatabase(String key, dynamic value) async {
    try {
      // This would save to a settings table in the database
      // For now, we'll just update the cache
      print('Saving config to database: $key = $value');
    } catch (e) {
      print('Error saving config to database: $e');
    }
  }

  // Get all configurations
  static Map<String, dynamic> getAll() {
    if (!_isInitialized) {
      throw Exception(
        'ConfigService not initialized. Call initialize() first.',
      );
    }
    return Map.unmodifiable(_cache);
  }

  // Reload configurations
  static Future<void> reload() async {
    _cache.clear();
    _isInitialized = false;
    await initialize();
  }

  // Clear cache
  static void clearCache() {
    _cache.clear();
    _isInitialized = false;
  }
}
