import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/core/services/utility_service.dart';
import 'package:stocked/core/models/user_model.dart' as app_user;
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/core/models/voucher_model.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/core/models/expense_model.dart';

class SyncService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isInitialized = false;
  static bool _isSyncing = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          syncPendingData();
        }
      });

      _isInitialized = true;
      print('SyncService initialized successfully');
    } catch (e) {
      print('Error initializing SyncService: $e');
    }
  }

  static Future<void> syncPendingData() async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }

    if (!await isConnected()) {
      print('No internet connection, skipping sync');
      return;
    }

    _isSyncing = true;
    print('Starting sync process...');

    try {
      final pendingData = await DatabaseService.getPendingSyncData();
      print('Found ${pendingData.length} items to sync');

      if (pendingData.isEmpty) {
        print('No pending data to sync');
        return;
      }

      int successCount = 0;
      int errorCount = 0;

      for (final data in pendingData) {
        try {
          await _syncItem(data);
          successCount++;
        } catch (e) {
          print('Error syncing item: $e');
          errorCount++;
        }
      }

      print('Sync completed: $successCount successful, $errorCount errors');

      if (successCount > 0) {
        await _markAllAsSynced();
      }
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> _syncItem(dynamic item) async {
    try {
      final tableName = _getTableName(item);
      final jsonData = _prepareJsonData(item);

      if (item.cloudId != null && item.cloudId!.isNotEmpty) {
        // Update existing record
        await _supabase.from(tableName).update(jsonData).eq('id', item.cloudId);
        print('Updated $tableName with cloud ID: ${item.cloudId}');
      } else {
        // Insert new record
        final response =
            await _supabase.from(tableName).insert(jsonData).select().single();

        // Update local record with cloud ID
        item.cloudId = response['id'];
        await _updateLocalRecord(item);
        print('Inserted new $tableName with cloud ID: ${item.cloudId}');
      }
    } catch (e) {
      print('Error syncing item to ${_getTableName(item)}: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _prepareJsonData(dynamic item) {
    final jsonData = item.toJson();

    // Remove local ID for cloud sync
    jsonData.remove('id');

    // Remove sync-related fields that shouldn't be sent to cloud
    jsonData.remove('syncStatus');
    jsonData.remove('lastSyncedAt');
    jsonData.remove('cloudId');

    // Convert DateTime objects to ISO strings
    final keysToConvert = [
      'createdAt',
      'updatedAt',
      'orderDate',
      'paymentDate',
      'expenseDate',
      'voucherDate'
    ];
    for (final key in keysToConvert) {
      if (jsonData[key] != null && jsonData[key] is DateTime) {
        jsonData[key] = (jsonData[key] as DateTime).toIso8601String();
      }
    }

    return jsonData;
  }

  static Future<void> _updateLocalRecord(dynamic item) async {
    try {
      if (item.runtimeType.toString().contains('User')) {
        await DatabaseService.saveUser(item);
      } else if (item.runtimeType.toString().contains('Item')) {
        await DatabaseService.saveItem(item);
      } else if (item.runtimeType.toString().contains('Order')) {
        await DatabaseService.saveOrder(item);
      } else if (item.runtimeType.toString().contains('Voucher')) {
        await DatabaseService.saveVoucher(item);
      } else if (item.runtimeType.toString().contains('Payment')) {
        await DatabaseService.savePayment(item);
      } else if (item.runtimeType.toString().contains('Expense')) {
        await DatabaseService.saveExpense(item);
      }
    } catch (e) {
      print('Error updating local record: $e');
      rethrow;
    }
  }

  static String _getTableName(dynamic item) {
    if (item.runtimeType.toString().contains('User')) return 'users';
    if (item.runtimeType.toString().contains('Item')) return 'items';
    if (item.runtimeType.toString().contains('Order')) return 'orders';
    if (item.runtimeType.toString().contains('Voucher')) return 'vouchers';
    if (item.runtimeType.toString().contains('Payment')) return 'payments';
    if (item.runtimeType.toString().contains('Expense')) return 'expenses';
    return 'unknown';
  }

  static Future<void> _markAllAsSynced() async {
    try {
      print('Marking all pending items as synced...');

      // Get all pending data and mark as synced
      final pendingData = await DatabaseService.getPendingSyncData();

      for (final item in pendingData) {
        item.syncStatus = AppConstants.syncStatusSynced;
        item.lastSyncedAt = DateTime.now();

        // Save based on item type
        if (item.runtimeType.toString().contains('User')) {
          await DatabaseService.saveUser(item);
        } else if (item.runtimeType.toString().contains('Item')) {
          await DatabaseService.saveItem(item);
        } else if (item.runtimeType.toString().contains('Order')) {
          await DatabaseService.saveOrder(item);
        } else if (item.runtimeType.toString().contains('Voucher')) {
          await DatabaseService.saveVoucher(item);
        } else if (item.runtimeType.toString().contains('Payment')) {
          await DatabaseService.savePayment(item);
        } else if (item.runtimeType.toString().contains('Expense')) {
          await DatabaseService.saveExpense(item);
        }
      }

      print('All pending items marked as synced successfully');
    } catch (e) {
      print('Error marking items as synced: $e');
    }
  }

  static Future<void> pullFromCloud() async {
    if (!await isConnected()) {
      print('No internet connection, cannot pull from cloud');
      return;
    }

    print('Pulling data from cloud...');

    try {
      // Pull users
      final usersResponse = await _supabase.from('users').select();
      print('Pulled ${usersResponse.length} users from cloud');

      for (final userData in usersResponse) {
        try {
          final existingUser = await DatabaseService.getUserByEmail(
            userData['email'],
          );
          if (existingUser == null) {
            final user = app_user.User.fromJson(userData);
            user.syncStatus = AppConstants.syncStatusSynced;
            user.lastSyncedAt = DateTime.now();
            await DatabaseService.saveUser(user);
          }
        } catch (e) {
          print('Error processing user data: $e');
        }
      }

      // Pull items
      final itemsResponse = await _supabase.from('items').select();
      print('Pulled ${itemsResponse.length} items from cloud');

      for (final itemData in itemsResponse) {
        try {
          final existingItem =
              await DatabaseService.getItemById(itemData['id']);
          if (existingItem == null) {
            final item = Item.fromJson(itemData);
            item.syncStatus = AppConstants.syncStatusSynced;
            item.lastSyncedAt = DateTime.now();
            await DatabaseService.saveItem(item);
          }
        } catch (e) {
          print('Error processing item data: $e');
        }
      }

      // Pull orders
      final ordersResponse = await _supabase.from('orders').select();
      print('Pulled ${ordersResponse.length} orders from cloud');

      for (final orderData in ordersResponse) {
        try {
          final existingOrder =
              await DatabaseService.getOrderById(orderData['id']);
          if (existingOrder == null) {
            final order = Order.fromJson(orderData);
            order.syncStatus = AppConstants.syncStatusSynced;
            order.lastSyncedAt = DateTime.now();
            await DatabaseService.saveOrder(order);
          }
        } catch (e) {
          print('Error processing order data: $e');
        }
      }

      // Pull vouchers
      final vouchersResponse = await _supabase.from('vouchers').select();
      print('Pulled ${vouchersResponse.length} vouchers from cloud');

      for (final voucherData in vouchersResponse) {
        try {
          final existingVoucher =
              await DatabaseService.getVoucherById(voucherData['id']);
          if (existingVoucher == null) {
            final voucher = Voucher.fromJson(voucherData);
            voucher.syncStatus = AppConstants.syncStatusSynced;
            voucher.lastSyncedAt = DateTime.now();
            await DatabaseService.saveVoucher(voucher);
          }
        } catch (e) {
          print('Error processing voucher data: $e');
        }
      }

      // Pull payments
      final paymentsResponse = await _supabase.from('payments').select();
      print('Pulled ${paymentsResponse.length} payments from cloud');

      for (final paymentData in paymentsResponse) {
        try {
          final existingPayment =
              await DatabaseService.getPaymentById(paymentData['id']);
          if (existingPayment == null) {
            final payment = Payment.fromJson(paymentData);
            payment.syncStatus = AppConstants.syncStatusSynced;
            payment.lastSyncedAt = DateTime.now();
            await DatabaseService.savePayment(payment);
          }
        } catch (e) {
          print('Error processing payment data: $e');
        }
      }

      // Pull expenses
      final expensesResponse = await _supabase.from('expenses').select();
      print('Pulled ${expensesResponse.length} expenses from cloud');

      for (final expenseData in expensesResponse) {
        try {
          final existingExpense =
              await DatabaseService.getExpenseById(expenseData['id']);
          if (existingExpense == null) {
            final expense = Expense.fromJson(expenseData);
            expense.syncStatus = AppConstants.syncStatusSynced;
            expense.lastSyncedAt = DateTime.now();
            await DatabaseService.saveExpense(expense);
          }
        } catch (e) {
          print('Error processing expense data: $e');
        }
      }

      print('Cloud pull completed successfully');
    } catch (e) {
      print('Error pulling from cloud: $e');
    }
  }

  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  static Future<void> forceSync() async {
    print('Force sync requested');
    await syncPendingData();
  }

  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final pendingData = await DatabaseService.getPendingSyncData();
      final isOnline = await isConnected();

      return {
        'isOnline': isOnline,
        'isSyncing': _isSyncing,
        'pendingItems': pendingData.length,
        'lastSyncAttempt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting sync status: $e');
      return {
        'isOnline': false,
        'isSyncing': false,
        'pendingItems': 0,
        'error': e.toString(),
      };
    }
  }
}
