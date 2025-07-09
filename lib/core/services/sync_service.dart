import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/core/models/user_model.dart' as app_user;
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/core/models/voucher_model.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/core/models/expense_model.dart';

class SyncService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncPendingData();
      }
    });

    _isInitialized = true;
  }

  static Future<void> syncPendingData() async {
    try {
      final pendingData = await DatabaseService.getPendingSyncData();

      for (final data in pendingData) {
        await _syncItem(data);
      }

      // Mark all as synced
      await _markAllAsSynced();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  static Future<void> _syncItem(dynamic item) async {
    try {
      final tableName = _getTableName(item);
      final jsonData = item.toJson();

      // Remove local ID for cloud sync
      jsonData.remove('id');

      if (item.cloudId != null) {
        // Update existing record
        await _supabase.from(tableName).update(jsonData).eq('id', item.cloudId);
      } else {
        // Insert new record
        final response = await _supabase
            .from(tableName)
            .insert(jsonData)
            .select()
            .single();

        // Update local record with cloud ID
        item.cloudId = response['id'];
        await DatabaseService.saveItem(item);
      }
    } catch (e) {
      print('Error syncing item: $e');
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
    // Simplified for now - will implement proper sync marking later
    print('Marking items as synced...');
  }

  static Future<void> pullFromCloud() async {
    try {
      // Pull users
      final usersResponse = await _supabase.from('users').select();
      for (final userData in usersResponse) {
        final existingUser = await DatabaseService.getUserByEmail(
          userData['email'],
        );
        if (existingUser == null) {
          final user = app_user.User.fromJson(userData);
          user.syncStatus = AppConstants.syncStatusSynced;
          await DatabaseService.saveUser(user);
        }
      }

      // Pull items
      final itemsResponse = await _supabase.from('items').select();
      for (final itemData in itemsResponse) {
        final existingItem = await DatabaseService.getItemById(itemData['id']);
        if (existingItem == null) {
          final item = Item.fromJson(itemData);
          item.syncStatus = AppConstants.syncStatusSynced;
          await DatabaseService.saveItem(item);
        }
      }

      // Pull other data similarly...
    } catch (e) {
      print('Error pulling from cloud: $e');
    }
  }

  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
