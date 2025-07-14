import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:stocked/core/models/user_model.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/core/models/voucher_model.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/core/models/expense_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'stocked.db';
  static const int _databaseVersion = 2; // Updated version

  static Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  static Future<void> initialize() async {
    if (kIsWeb) {
      // For web, we'll use a simple in-memory database for now
      // In a production app, you'd want to use IndexedDB or a web-compatible database
      print('Running on web - using in-memory database');
      _database = await openDatabase(
        ':memory:',
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } else {
      // For desktop platforms (Windows, macOS, Linux), initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // For mobile platforms, use the file system
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }

    // Seed initial data
    await _seedInitialData();
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        phone TEXT,
        company_name TEXT,
        role TEXT NOT NULL DEFAULT 'retail_client',
        address TEXT,
        gst_number TEXT,
        pan_number TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit_price REAL NOT NULL DEFAULT 0.0,
        gst_percentage REAL NOT NULL DEFAULT 18.0,
        opening_stock INTEGER NOT NULL DEFAULT 0,
        current_stock INTEGER NOT NULL DEFAULT 0,
        low_stock_threshold INTEGER NOT NULL DEFAULT 10,
        sku TEXT UNIQUE,
        barcode TEXT UNIQUE,
        description TEXT,
        image_url TEXT,
        user_id INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE,
        status TEXT DEFAULT 'pending',
        client_id INTEGER,
        client_name TEXT,
        total_amount REAL DEFAULT 0.0,
        gst_amount REAL DEFAULT 0.0,
        net_amount REAL DEFAULT 0.0,
        payment_status TEXT DEFAULT 'pending',
        paid_amount REAL DEFAULT 0.0,
        notes TEXT,
        order_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES users (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        gst_percentage REAL DEFAULT 18.0,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Vouchers table
    await db.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_number TEXT UNIQUE,
        voucher_type TEXT NOT NULL,
        voucher_date TEXT NOT NULL,
        party_name TEXT,
        party_id INTEGER,
        total_amount REAL DEFAULT 0.0,
        gst_amount REAL DEFAULT 0.0,
        net_amount REAL DEFAULT 0.0,
        payment_mode TEXT,
        reference_number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (party_id) REFERENCES users (id)
      )
    ''');

    // Voucher items table
    await db.execute('''
      CREATE TABLE voucher_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        gst_percentage REAL DEFAULT 18.0,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (voucher_id) REFERENCES vouchers (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_number TEXT UNIQUE,
        payment_date TEXT NOT NULL,
        payment_type TEXT NOT NULL,
        party_id INTEGER,
        party_name TEXT,
        amount REAL NOT NULL,
        payment_mode TEXT,
        reference_number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (party_id) REFERENCES users (id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_number TEXT UNIQUE,
        expense_date TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_mode TEXT,
        reference_number TEXT,
        vendor_name TEXT,
        gst_number TEXT,
        gst_amount REAL DEFAULT 0.0,
        net_amount REAL DEFAULT 0.0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Stock movements table
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        previous_stock INTEGER NOT NULL,
        new_stock INTEGER NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT UNIQUE NOT NULL,
        setting_value TEXT,
        setting_type TEXT DEFAULT 'string',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_role ON users(role)');
    await db.execute('CREATE INDEX idx_items_category ON items(category)');
    await db.execute('CREATE INDEX idx_items_name ON items(name)');
    await db.execute('CREATE INDEX idx_orders_client_id ON orders(client_id)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');
    await db
        .execute('CREATE INDEX idx_orders_order_date ON orders(order_date)');
    await db.execute(
        'CREATE INDEX idx_order_items_order_id ON order_items(order_id)');
    await db.execute(
        'CREATE INDEX idx_vouchers_voucher_type ON vouchers(voucher_type)');
    await db.execute(
        'CREATE INDEX idx_vouchers_voucher_date ON vouchers(voucher_date)');
    await db
        .execute('CREATE INDEX idx_payments_party_id ON payments(party_id)');
    await db.execute(
        'CREATE INDEX idx_payments_payment_date ON payments(payment_date)');
    await db
        .execute('CREATE INDEX idx_expenses_category ON expenses(category)');
    await db.execute(
        'CREATE INDEX idx_expenses_expense_date ON expenses(expense_date)');
    await db.execute(
        'CREATE INDEX idx_stock_movements_item_id ON stock_movements(item_id)');
    await db.execute(
        'CREATE INDEX idx_stock_movements_created_at ON stock_movements(created_at)');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to items table
      try {
        await db.execute('ALTER TABLE items ADD COLUMN image_url TEXT');
      } catch (e) {
        print('Column image_url might already exist: $e');
      }

      try {
        await db.execute('ALTER TABLE items ADD COLUMN user_id INTEGER');
      } catch (e) {
        print('Column user_id might already exist: $e');
      }

      try {
        await db.execute(
            'ALTER TABLE items ADD COLUMN is_active INTEGER DEFAULT 1');
      } catch (e) {
        print('Column is_active might already exist: $e');
      }

      // Update existing items to have a default user_id (admin user)
      try {
        final adminUser = await getUserByEmail('admin@stocked.com');
        if (adminUser != null) {
          await db.execute('UPDATE items SET user_id = ? WHERE user_id IS NULL',
              [adminUser.id]);
        }
      } catch (e) {
        print('Error updating existing items: $e');
      }
    }
  }

  static Future<void> _seedInitialData() async {
    // Check if data already exists
    final userCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM users'));

    if (userCount == 0) {
      // Seed default settings
      await _seedSettings();

      // Seed sample items
      await _seedSampleItems();

      // Seed sample users
      await _seedSampleUsers();
    }
  }

  static Future<void> _seedSettings() async {
    final settings = [
      {
        'key': 'item_categories',
        'value':
            'Electronics,Clothing,Food & Beverages,Home & Garden,Sports,Books,Automotive,Health & Beauty,Toys & Games,Other'
      },
      {
        'key': 'payment_modes',
        'value': 'Cash,Bank Transfer,UPI,Cheque,Credit Card,Debit Card'
      },
      {
        'key': 'voucher_types',
        'value': 'Sales,Purchase,Payment,Receipt,Journal'
      },
      {
        'key': 'order_statuses',
        'value': 'Pending,Accepted,Dispatched,Delivered,Cancelled'
      },
      {'key': 'payment_statuses', 'value': 'Pending,Partial,Paid'},
      {
        'key': 'expense_categories',
        'value':
            'Office Supplies,Travel,Marketing,Utilities,Rent,Salaries,Equipment,Maintenance,Other'
      },
      {'key': 'default_gst_rate', 'value': '18.0'},
      {'key': 'default_low_stock_threshold', 'value': '10'},
      {'key': 'company_name', 'value': 'Stocked Business'},
      {'key': 'app_version', 'value': '1.0.0'},
      {'key': 'currency_symbol', 'value': '₹'},
      {'key': 'date_format', 'value': 'dd/MM/yyyy'},
      {'key': 'time_format', 'value': 'HH:mm'},
    ];

    for (final setting in settings) {
      await database.insert('settings', {
        'setting_key': setting['key'],
        'setting_value': setting['value'],
        'setting_type': 'string',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> _seedSampleItems() async {
    final items = [
      {
        'name': 'Laptop Dell Inspiron',
        'category': 'Electronics',
        'unit_price': 45000.0,
        'gst_percentage': 18.0,
        'opening_stock': 50,
        'current_stock': 45,
        'low_stock_threshold': 10,
        'description': 'High-performance laptop for business use',
        'barcode': 'DELL001',
        'sku': 'LAP-DELL-001',
      },
      {
        'name': 'Wireless Mouse',
        'category': 'Electronics',
        'unit_price': 1200.0,
        'gst_percentage': 18.0,
        'opening_stock': 100,
        'current_stock': 85,
        'low_stock_threshold': 20,
        'description': 'Ergonomic wireless mouse',
        'barcode': 'MOUSE001',
        'sku': 'ACC-MOUSE-001',
      },
      {
        'name': 'Office Chair',
        'category': 'Office',
        'unit_price': 3500.0,
        'gst_percentage': 18.0,
        'opening_stock': 30,
        'current_stock': 25,
        'low_stock_threshold': 5,
        'description': 'Comfortable office chair with armrests',
        'barcode': 'CHAIR001',
        'sku': 'OFF-CHAIR-001',
      },
      {
        'name': 'Printer Paper A4',
        'category': 'Office',
        'unit_price': 250.0,
        'gst_percentage': 18.0,
        'opening_stock': 200,
        'current_stock': 180,
        'low_stock_threshold': 50,
        'description': 'High-quality A4 printer paper',
        'barcode': 'PAPER001',
        'sku': 'OFF-PAPER-001',
      },
    ];

    for (final item in items) {
      await database.insert('items', {
        ...item,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> _seedSampleUsers() async {
    final users = [
      {
        'email': 'admin@stocked.com',
        'name': 'Admin User',
        'phone': '+91-9876543210',
        'company_name': 'Stocked Business',
        'role': 'distributor',
        'address': '123 Business Street, Mumbai, Maharashtra',
        'gst_number': '27ABCDE1234F1Z5',
        'pan_number': 'ABCDE1234F',
      },
      {
        'email': 'client1@example.com',
        'name': 'TechCorp Solutions',
        'phone': '+91-9876543211',
        'company_name': 'TechCorp Solutions Pvt Ltd',
        'role': 'retail_client',
        'address': '456 Tech Park, Bangalore, Karnataka',
        'gst_number': '29TECHC1234F1Z5',
        'pan_number': 'TECHC1234F',
      },
      {
        'email': 'client2@example.com',
        'name': 'OfficePlus Store',
        'phone': '+91-9876543212',
        'company_name': 'OfficePlus Store',
        'role': 'retail_client',
        'address': '789 Office Complex, Delhi, NCR',
        'gst_number': '07OFFIC1234F1Z5',
        'pan_number': 'OFFIC1234F',
      },
    ];

    for (final user in users) {
      await database.insert('users', {
        ...user,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> close() async {
    await _database?.close();
  }

  // Settings operations
  static Future<String?> getSetting(String key) async {
    final result = await database.query(
      'settings',
      where: 'setting_key = ?',
      whereArgs: [key],
    );
    return result.isNotEmpty ? result.first['setting_value'] as String? : null;
  }

  static Future<void> setSetting(String key, String value) async {
    await database.insert(
      'settings',
      {
        'setting_key': key,
        'setting_value': value,
        'setting_type': 'string',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // User operations
  static Future<User?> getUserByEmail(String email) async {
    final result = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  static Future<User?> getUserById(int id) async {
    final result = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  static Future<void> saveUser(User user) async {
    if (user.id == null) {
      await database.insert('users', user.toMap());
    } else {
      await database.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  static Future<List<User>> getAllUsers() async {
    final result = await database.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Item operations
  static Future<List<Item>> getAllItems() async {
    // Get current user ID from settings
    final currentUserEmail = await getSetting('current_user_email');
    final currentUser = currentUserEmail != null
        ? await getUserByEmail(currentUserEmail)
        : null;

    if (currentUser == null) {
      // If no user is logged in, return all items (for backward compatibility)
      // This allows the app to work even without a logged-in user
      final result = await database.query('items');
      return result.map((map) => Item.fromMap(map)).toList();
    }

    final result = await database.query(
      'items',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [currentUser.id],
    );
    return result.map((map) => Item.fromMap(map)).toList();
  }

  static Future<Item?> getItemById(int id) async {
    final result = await database.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Item.fromMap(result.first) : null;
  }

  static Future<void> saveItem(Item item) async {
    // Get current user ID from settings
    final currentUserEmail = await getSetting('current_user_email');
    final currentUser = currentUserEmail != null
        ? await getUserByEmail(currentUserEmail)
        : null;

    // Prepare item data
    final itemData = item.toMap();
    itemData['created_at'] = DateTime.now().toIso8601String();
    itemData['updated_at'] = DateTime.now().toIso8601String();

    // If there's a current user, add user_id
    if (currentUser != null) {
      itemData['user_id'] = currentUser.id;
    } else {
      // For backward compatibility, try to get admin user or set to null
      try {
        final adminUser = await getUserByEmail('admin@stocked.com');
        itemData['user_id'] = adminUser?.id;
      } catch (e) {
        print('Warning: No user found for item creation');
        itemData['user_id'] = null;
      }
    }

    if (item.id == null) {
      await database.insert('items', itemData);
    } else {
      await database.update(
        'items',
        itemData,
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  static Future<void> deleteItem(int id) async {
    await database.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Order operations
  static Future<List<Order>> getAllOrders() async {
    final result = await database.query('orders');
    return result.map((map) => Order.fromMap(map)).toList();
  }

  static Future<Order?> getOrderById(int id) async {
    final result = await database.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Order.fromMap(result.first) : null;
  }

  static Future<void> saveOrder(Order order) async {
    if (order.id == null) {
      await database.insert('orders', order.toMap());
    } else {
      await database.update(
        'orders',
        order.toMap(),
        where: 'id = ?',
        whereArgs: [order.id],
      );
    }
  }

  static Future<void> deleteOrder(int id) async {
    await database.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // OrderItem operations
  static Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    final result = await database.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((map) => OrderItem.fromMap(map)).toList();
  }

  static Future<void> saveOrderItem(OrderItem orderItem) async {
    if (orderItem.id == null) {
      await database.insert('order_items', orderItem.toMap());
    } else {
      await database.update(
        'order_items',
        orderItem.toMap(),
        where: 'id = ?',
        whereArgs: [orderItem.id],
      );
    }
  }

  // Voucher operations
  static Future<List<Voucher>> getAllVouchers() async {
    final result = await database.query('vouchers');
    return result.map((map) => Voucher.fromMap(map)).toList();
  }

  static Future<Voucher?> getVoucherById(int id) async {
    final result = await database.query(
      'vouchers',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Voucher.fromMap(result.first) : null;
  }

  static Future<void> saveVoucher(Voucher voucher) async {
    if (voucher.id == null) {
      await database.insert('vouchers', voucher.toMap());
    } else {
      await database.update(
        'vouchers',
        voucher.toMap(),
        where: 'id = ?',
        whereArgs: [voucher.id],
      );
    }
  }

  // Payment operations
  static Future<List<Payment>> getAllPayments() async {
    final result = await database.query('payments');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  static Future<Payment?> getPaymentById(int id) async {
    final result = await database.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Payment.fromMap(result.first) : null;
  }

  static Future<void> savePayment(Payment payment) async {
    if (payment.id == null) {
      await database.insert('payments', payment.toMap());
    } else {
      await database.update(
        'payments',
        payment.toMap(),
        where: 'id = ?',
        whereArgs: [payment.id],
      );
    }
  }

  static Future<void> deletePayment(int id) async {
    await database.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Expense operations
  static Future<List<Expense>> getAllExpenses() async {
    final result = await database.query('expenses');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  static Future<Expense?> getExpenseById(int id) async {
    final result = await database.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Expense.fromMap(result.first) : null;
  }

  static Future<void> saveExpense(Expense expense) async {
    if (expense.id == null) {
      await database.insert('expenses', expense.toMap());
    } else {
      await database.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    }
  }

  static Future<void> deleteExpense(int id) async {
    await database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics operations
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final totalItems = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM items')) ??
        0;

    final lowStockItems = Sqflite.firstIntValue(await database.rawQuery('''
        SELECT COUNT(*) FROM items 
        WHERE current_stock <= low_stock_threshold
      ''')) ?? 0;

    final pendingOrders = Sqflite.firstIntValue(await database.rawQuery('''
        SELECT COUNT(*) FROM orders 
        WHERE status = 'pending'
      ''')) ?? 0;

    final todayOrders = Sqflite.firstIntValue(await database.rawQuery('''
        SELECT COUNT(*) FROM orders 
        WHERE DATE(order_date) = DATE('now')
      ''')) ?? 0;

    final todaySalesResult = await database.rawQuery('''
        SELECT COALESCE(SUM(total_amount), 0) as total FROM orders 
        WHERE DATE(order_date) = DATE('now')
      ''');
    final todaySales =
        (todaySalesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final todayPaymentsResult = await database.rawQuery('''
        SELECT COALESCE(SUM(amount), 0) as total FROM payments 
        WHERE payment_type = 'received' AND DATE(payment_date) = DATE('now')
      ''');
    final todayPayments =
        (todayPaymentsResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final todayExpensesResult = await database.rawQuery('''
        SELECT COALESCE(SUM(amount), 0) as total FROM expenses 
        WHERE DATE(expense_date) = DATE('now')
      ''');
    final todayExpenses =
        (todayExpensesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'total_items': totalItems,
      'low_stock_items': lowStockItems,
      'pending_orders': pendingOrders,
      'today_orders': todayOrders,
      'today_sales': todaySales,
      'today_payments': todayPayments,
      'today_expenses': todayExpenses,
    };
  }

  // Stock movement operations
  static Future<void> recordStockMovement({
    required int itemId,
    required String movementType,
    required int quantity,
    required int previousStock,
    required int newStock,
    String? referenceType,
    int? referenceId,
    String? notes,
  }) async {
    await database.insert('stock_movements', {
      'item_id': itemId,
      'movement_type': movementType,
      'quantity': quantity,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateItemStock(int itemId, int newStock) async {
    await database.update(
      'items',
      {
        'current_stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }
}
