import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/models/expense_model.dart';
import 'package:stocked/core/services/database_service.dart';

final expensesProviderNotifier =
    StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier();
});

class ExpensesState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  ExpensesState({this.expenses = const [], this.isLoading = false, this.error});

  ExpensesState copyWith(
      {List<Expense>? expenses, bool? isLoading, String? error}) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  ExpensesNotifier() : super(ExpensesState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);

    try {
      final expenses = await DatabaseService.getAllExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await DatabaseService.saveExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DatabaseService.saveExpense(expense);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DatabaseService.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadExpenses();
  }
}
