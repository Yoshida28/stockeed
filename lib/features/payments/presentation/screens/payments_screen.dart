import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/core/models/payment_model.dart';
import 'package:stocked/features/payments/presentation/providers/payments_provider.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _selectedPaymentType = 'All';
  String _searchQuery = '';
  List<String> _paymentTypes = ['All'];
  List<String> _paymentModes = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentModes();
  }

  void _loadPaymentModes() {
    try {
      final modes = ConfigService.get<List<String>>('payment_modes');
      setState(() {
        _paymentTypes = ['All', 'Received', 'Paid'];
        _paymentModes = modes;
      });
    } catch (e) {
      print('Error loading payment modes: $e');
      setState(() {
        _paymentTypes = ['All', 'Received', 'Paid'];
        _paymentModes = [
          'Cash',
          'Bank Transfer',
          'UPI',
          'Cheque',
          'Credit Card',
          'Debit Card'
        ];
      });
    }
  }

  void _showAddPaymentModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        String partyName = '';
        String amount = '';
        String paymentType = 'received';
        String paymentMode =
            _paymentModes.isNotEmpty ? _paymentModes.first : 'Cash';
        String referenceNumber = '';
        String notes = '';
        int paymentModeIndex = 0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return CupertinoActionSheet(
              title: const Text('Add Payment'),
              message: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoTextField(
                        placeholder: 'Party Name',
                        onChanged: (v) => setModalState(() => partyName = v),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        placeholder: 'Amount (₹)',
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setModalState(() => amount = v),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: CupertinoColors.systemGrey4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CupertinoSlidingSegmentedControl<String>(
                          groupValue: paymentType,
                          children: const {
                            'received': Text('Received'),
                            'paid': Text('Paid'),
                          },
                          onValueChanged: (value) {
                            if (value != null)
                              setModalState(() => paymentType = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: CupertinoColors.systemGrey4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text('Mode: '),
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: paymentMode,
                                items: _paymentModes.map((mode) {
                                  return DropdownMenuItem<String>(
                                    value: mode,
                                    child: Text(mode),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setModalState(() => paymentMode = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        placeholder: 'Reference Number (Optional)',
                        onChanged: (v) =>
                            setModalState(() => referenceNumber = v),
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        placeholder: 'Notes (Optional)',
                        onChanged: (v) => setModalState(() => notes = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (partyName.isNotEmpty && amount.isNotEmpty) {
                      final payment = Payment(
                        paymentNumber:
                            'PAY- 2${DateTime.now().millisecondsSinceEpoch}',
                        paymentDate: DateTime.now(),
                        paymentType: paymentType,
                        partyName: partyName,
                        amount: double.tryParse(amount) ?? 0.0,
                        paymentMode: paymentMode,
                        referenceNumber:
                            referenceNumber.isNotEmpty ? referenceNumber : null,
                        notes: notes.isNotEmpty ? notes : null,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      ref
                          .read(paymentsProviderNotifier.notifier)
                          .addPayment(payment);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsState = ref.watch(paymentsProviderNotifier);
    final payments = paymentsState.payments;

    // Filter payments based on search and type
    final filteredPayments = payments.where((payment) {
      final matchesSearch = payment.partyName
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesType = _selectedPaymentType == 'All' ||
          payment.paymentType == _selectedPaymentType.toLowerCase();
      return matchesSearch && matchesType;
    }).toList();

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Payments',
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                onPressed: _showAddPaymentModal,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Add Payment', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassmorphicDecoration,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search Bar
              CupertinoSearchTextField(
                placeholder: 'Search payments...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: AppTheme.body1,
                prefixIcon:
                    Icon(CupertinoIcons.search, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),

              // Payment Type Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _paymentTypes.length,
                        itemBuilder: (context, index) {
                          final type = _paymentTypes[index];
                          final isSelected = _selectedPaymentType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CupertinoButton(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              onPressed: () {
                                setState(() {
                                  _selectedPaymentType = type;
                                });
                              },
                              child: Text(
                                type,
                                style: AppTheme.body2.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Payments Summary Cards
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Payments',
                  value: '${filteredPayments.length}',
                  icon: CupertinoIcons.creditcard,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Amount',
                  value: '₹${_formatAmount(_getTotalAmount(filteredPayments))}',
                  icon: CupertinoIcons.money_dollar,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Payments List
        Expanded(
          child: paymentsState.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _buildPaymentsList(filteredPayments),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassmorphicDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.heading3.copyWith(color: color)),
          Text(title, style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.creditcard,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('No payments found',
                style: AppTheme.heading3
                    .copyWith(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 8),
            Text('Add your first payment to get started',
                style: AppTheme.body2
                    .copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassmorphicDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payment.paymentNumber ?? 'N/A',
                    style: AppTheme.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: payment.paymentType == 'received'
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payment.paymentType?.toUpperCase() ?? 'N/A',
                      style: AppTheme.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.partyName ?? 'Unknown',
                          style: AppTheme.body1,
                        ),
                        if (payment.paymentMode != null)
                          Text(
                            payment.paymentMode!,
                            style: AppTheme.caption
                                .copyWith(color: AppTheme.textSecondaryColor),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_formatAmount(payment.amount ?? 0)}',
                        style: AppTheme.heading3.copyWith(
                          color: payment.paymentType == 'received'
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(payment.paymentDate ?? DateTime.now()),
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.referenceNumber != null || payment.notes != null) ...[
                const SizedBox(height: 8),
                if (payment.referenceNumber != null)
                  Text(
                    'Ref: ${payment.referenceNumber}',
                    style: AppTheme.caption
                        .copyWith(color: AppTheme.textSecondaryColor),
                  ),
                if (payment.notes != null)
                  Text(
                    payment.notes!,
                    style: AppTheme.caption
                        .copyWith(color: AppTheme.textSecondaryColor),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _getTotalAmount(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + (payment.amount ?? 0));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
