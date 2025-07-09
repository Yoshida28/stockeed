import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/models/item_model.dart';
import 'package:stocked/core/services/database_service.dart';

final stockProviderNotifier = StateNotifierProvider<StockNotifier, StockState>((
  ref,
) {
  return StockNotifier();
});

class StockState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  StockState({this.items = const [], this.isLoading = false, this.error});

  StockState copyWith({List<Item>? items, bool? isLoading, String? error}) {
    return StockState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StockNotifier extends StateNotifier<StockState> {
  StockNotifier() : super(StockState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);

    try {
      final items = await DatabaseService.getAllItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(Item item) async {
    try {
      await DatabaseService.saveItem(item);
      await loadItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await DatabaseService.saveItem(item);
      await loadItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await DatabaseService.deleteItem(id);
      await loadItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
