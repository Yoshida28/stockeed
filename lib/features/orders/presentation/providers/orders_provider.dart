import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/core/services/database_service.dart';

final ordersProviderNotifier =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier();
});

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrdersState({this.orders = const [], this.isLoading = false, this.error});

  OrdersState copyWith({List<Order>? orders, bool? isLoading, String? error}) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier() : super(OrdersState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);

    try {
      final orders = await DatabaseService.getAllOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      await DatabaseService.saveOrder(order);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await DatabaseService.saveOrder(order);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final order = state.orders.firstWhere((order) => order.id == orderId);
      final updatedOrder = order.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await DatabaseService.saveOrder(updatedOrder);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await DatabaseService.deleteOrder(id);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }
}
