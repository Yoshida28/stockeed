import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stocked/core/models/user_model.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/core/models/voucher_model.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/core/models/expense_model.dart';

class DatabaseService {
  static late Isar _isar;

  static Isar get isar => _isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        UserSchema,
        ItemSchema,
        OrderSchema,
        OrderItemSchema,
        VoucherSchema,
        PaymentSchema,
        ExpenseSchema,
      ],
      directory: dir.path,
      inspector: false, // Disable Isar Inspector banner
    );
  }

  static Future<void> close() async {
    await _isar.close();
  }

  // User operations
  static Future<User?> getUserByEmail(String email) async {
    return await _isar.users.where().emailEqualTo(email).findFirst();
  }

  static Future<User?> getUserById(int id) async {
    return await _isar.users.get(id);
  }

  static Future<void> saveUser(User user) async {
    await _isar.writeTxn(() async {
      await _isar.users.put(user);
    });
  }

  static Future<List<User>> getAllUsers() async {
    return await _isar.users.where().findAll();
  }

  // Item operations
  static Future<List<Item>> getAllItems() async {
    return await _isar.items.where().findAll();
  }

  static Future<Item?> getItemById(int id) async {
    return await _isar.items.get(id);
  }

  static Future<void> saveItem(Item item) async {
    await _isar.writeTxn(() async {
      await _isar.items.put(item);
    });
  }

  static Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.items.delete(id);
    });
  }

  // Order operations
  static Future<List<Order>> getAllOrders() async {
    return await _isar.orders.where().findAll();
  }

  static Future<Order?> getOrderById(int id) async {
    return await _isar.orders.get(id);
  }

  static Future<void> saveOrder(Order order) async {
    await _isar.writeTxn(() async {
      await _isar.orders.put(order);
    });
  }

  // OrderItem operations
  static Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    return await _isar.orderItems
        .where()
        .filter()
        .orderIdEqualTo(orderId)
        .findAll();
  }

  static Future<void> saveOrderItem(OrderItem orderItem) async {
    await _isar.writeTxn(() async {
      await _isar.orderItems.put(orderItem);
    });
  }

  // Voucher operations
  static Future<List<Voucher>> getAllVouchers() async {
    return await _isar.vouchers.where().findAll();
  }

  static Future<Voucher?> getVoucherById(int id) async {
    return await _isar.vouchers.get(id);
  }

  static Future<void> saveVoucher(Voucher voucher) async {
    await _isar.writeTxn(() async {
      await _isar.vouchers.put(voucher);
    });
  }

  // Payment operations
  static Future<List<Payment>> getAllPayments() async {
    return await _isar.payments.where().findAll();
  }

  static Future<Payment?> getPaymentById(int id) async {
    return await _isar.payments.get(id);
  }

  static Future<void> savePayment(Payment payment) async {
    await _isar.writeTxn(() async {
      await _isar.payments.put(payment);
    });
  }

  // Expense operations
  static Future<List<Expense>> getAllExpenses() async {
    return await _isar.expenses.where().findAll();
  }

  static Future<Expense?> getExpenseById(int id) async {
    return await _isar.expenses.get(id);
  }

  static Future<void> saveExpense(Expense expense) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
  }

  static Future<void> deleteExpense(int id) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.delete(id);
    });
  }

  // Sync operations - simplified for now
  static Future<List<dynamic>> getPendingSyncData() async {
    // For now, return empty list until we fix the query issues
    return [];
  }
}
