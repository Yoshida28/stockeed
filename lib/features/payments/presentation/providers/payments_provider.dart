import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/core/services/database_service.dart';

final paymentsProviderNotifier =
    StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  return PaymentsNotifier();
});

class PaymentsState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;

  PaymentsState({this.payments = const [], this.isLoading = false, this.error});

  PaymentsState copyWith(
      {List<Payment>? payments, bool? isLoading, String? error}) {
    return PaymentsState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  PaymentsNotifier() : super(PaymentsState()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true);

    try {
      final payments = await DatabaseService.getAllPayments();
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      await DatabaseService.savePayment(payment);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      await DatabaseService.savePayment(payment);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await DatabaseService.deletePayment(id);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadPayments();
  }
}
