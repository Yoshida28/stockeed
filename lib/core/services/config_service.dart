import 'package:stocked/core/services/database_service.dart';

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
      // Load settings from database
      final settings = [
        'item_categories',
        'payment_modes',
        'voucher_types',
        'order_statuses',
        'payment_statuses',
        'expense_categories',
        'default_gst_rate',
        'default_low_stock_threshold',
        'company_name',
        'app_version',
        'currency_symbol',
        'date_format',
        'time_format',
        'max_file_size_mb',
        'backup_enabled',
        'notifications_enabled',
      ];

      for (final key in settings) {
        final value = await DatabaseService.getSetting(key);
        if (value != null) {
          _cache[key] = _parseValue(key, value);
        }
      }
    } catch (e) {
      print('Error loading config from database: $e');
      _cache.addAll(_defaultConfig);
    }
  }

  static dynamic _parseValue(String key, String value) {
    switch (key) {
      case 'item_categories':
      case 'payment_modes':
      case 'voucher_types':
      case 'order_statuses':
      case 'payment_statuses':
      case 'expense_categories':
        return value.split(',');
      case 'default_gst_rate':
      case 'max_file_size_mb':
        return double.tryParse(value) ?? _defaultConfig[key];
      case 'default_low_stock_threshold':
        return int.tryParse(value) ?? _defaultConfig[key];
      case 'backup_enabled':
      case 'notifications_enabled':
        return value.toLowerCase() == 'true';
      default:
        return value;
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
      String stringValue;
      if (value is List) {
        stringValue = value.join(',');
      } else {
        stringValue = value.toString();
      }

      await DatabaseService.setSetting(key, stringValue);
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
