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
        DateTime selectedDate = DateTime.now();
        bool isFormValid = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Validate form
            void validateForm() {
              setModalState(() {
                isFormValid = partyName.trim().isNotEmpty &&
                    amount.trim().isNotEmpty &&
                    double.tryParse(amount) != null &&
                    double.tryParse(amount)! > 0;
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(CupertinoIcons.xmark, size: 24),
                        ),
                        Expanded(
                          child: Text(
                            'Add Payment',
                            textAlign: TextAlign.center,
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44), // Balance the close button
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Party Name
                          _buildFormSection(
                            title: 'Party Name',
                            child: CupertinoTextField(
                              placeholder: 'Enter party or client name',
                              onChanged: (value) {
                                partyName = value;
                                validateForm();
                              },
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              style: AppTheme.body1,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Amount
                          _buildFormSection(
                            title: 'Amount',
                            child: CupertinoTextField(
                              placeholder: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (value) {
                                amount = value;
                                validateForm();
                              },
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text('₹',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              style: AppTheme.body1.copyWith(fontSize: 18),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Payment Type
                          _buildFormSection(
                            title: 'Payment Type',
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoSlidingSegmentedControl<String>(
                                groupValue: paymentType,
                                backgroundColor: CupertinoColors.systemGrey6,
                                thumbColor: AppTheme.primaryColor,
                                children: const {
                                  'received': Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Text('Received',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  'paid': Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Text('Paid',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                },
                                onValueChanged: (value) {
                                  if (value != null) {
                                    setModalState(() => paymentType = value);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Payment Mode
                          _buildFormSection(
                            title: 'Payment Mode',
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.all(16),
                                onPressed: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) => CupertinoActionSheet(
                                      title: const Text('Select Payment Mode'),
                                      actions: _paymentModes
                                          .map((mode) =>
                                              CupertinoActionSheetAction(
                                                onPressed: () {
                                                  setModalState(
                                                      () => paymentMode = mode);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(mode),
                                              ))
                                          .toList(),
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      paymentMode,
                                      style: AppTheme.body1,
                                    ),
                                    const Icon(CupertinoIcons.chevron_down,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Date
                          _buildFormSection(
                            title: 'Payment Date',
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.all(16),
                                onPressed: () {
                                  showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) => Container(
                                      height: 300,
                                      color: CupertinoColors.systemBackground,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: CupertinoColors
                                                          .systemGrey4)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CupertinoButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                const Text('Select Date',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                CupertinoButton(
                                                  onPressed: () {
                                                    setModalState(() =>
                                                        selectedDate =
                                                            selectedDate);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Done'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              initialDateTime: selectedDate,
                                              maximumDate: DateTime.now(),
                                              onDateTimeChanged: (date) {
                                                setModalState(
                                                    () => selectedDate = date);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(selectedDate),
                                      style: AppTheme.body1,
                                    ),
                                    const Icon(CupertinoIcons.calendar,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Reference Number
                          _buildFormSection(
                            title: 'Reference Number (Optional)',
                            child: CupertinoTextField(
                              placeholder:
                                  'Transaction ID, cheque number, etc.',
                              onChanged: (value) => referenceNumber = value,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              style: AppTheme.body1,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Notes
                          _buildFormSection(
                            title: 'Notes (Optional)',
                            child: CupertinoTextField(
                              placeholder: 'Add any additional notes...',
                              onChanged: (value) => notes = value,
                              maxLines: 3,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              style: AppTheme.body1,
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      border: Border(
                          top: BorderSide(color: CupertinoColors.systemGrey4)),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: AppTheme.body1
                                    .copyWith(color: CupertinoColors.label),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CupertinoButton(
                              color: isFormValid
                                  ? AppTheme.primaryColor
                                  : CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: isFormValid
                                  ? () {
                                      final payment = Payment(
                                        paymentNumber:
                                            'PAY-${DateTime.now().millisecondsSinceEpoch}',
                                        paymentDate: selectedDate,
                                        paymentType: paymentType,
                                        partyName: partyName.trim(),
                                        amount: double.tryParse(amount) ?? 0.0,
                                        paymentMode: paymentMode,
                                        referenceNumber:
                                            referenceNumber.trim().isNotEmpty
                                                ? referenceNumber.trim()
                                                : null,
                                        notes: notes.trim().isNotEmpty
                                            ? notes.trim()
                                            : null,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );
                                      ref
                                          .read(
                                              paymentsProviderNotifier.notifier)
                                          .addPayment(payment);
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: Text(
                                'Add Payment',
                                style: AppTheme.body1.copyWith(
                                  color: isFormValid
                                      ? Colors.white
                                      : CupertinoColors.systemGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
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

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payments',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your incoming and outgoing payments',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                    onPressed: _showAddPaymentModal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Add Payment',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filter Section
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: CupertinoSearchTextField(
                      placeholder: 'Search payments by party name...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: AppTheme.body1,
                      prefixIcon: Icon(CupertinoIcons.search,
                          color: AppTheme.primaryColor),
                      decoration: const BoxDecoration(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Type Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _paymentTypes.length,
                            itemBuilder: (context, index) {
                              final type = _paymentTypes[index];
                              final isSelected = _selectedPaymentType == type;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(22),
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
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
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

            // Payments Summary Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Payments',
                      value: '${filteredPayments.length}',
                      subtitle: 'transactions',
                      icon: CupertinoIcons.creditcard_fill,
                      color: AppTheme.primaryColor,
                      gradient: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Amount',
                      value:
                          '₹${_formatAmount(_getTotalAmount(filteredPayments))}',
                      subtitle: 'processed',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      color: AppTheme.successColor,
                      gradient: [AppTheme.successColor, AppTheme.accentColor],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payments List
            paymentsState.isLoading
                ? Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(radius: 20),
                          const SizedBox(height: 16),
                          Text(
                            'Loading payments...',
                            style: AppTheme.body2
                                .copyWith(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildPaymentsList(filteredPayments),
                  ),

            // Bottom padding for better scrolling experience
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.arrow_up_right,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTheme.heading2.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.creditcard,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No payments found',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first payment to get started',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(25),
                onPressed: _showAddPaymentModal,
                child: const Text('Add Payment'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...payments.map((payment) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.paymentNumber ?? 'N/A',
                          style: AppTheme.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: payment.paymentType == 'received'
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: payment.paymentType == 'received'
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          payment.paymentType?.toUpperCase() ?? 'N/A',
                          style: AppTheme.caption.copyWith(
                            color: payment.paymentType == 'received'
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.partyName ?? 'Unknown',
                              style: AppTheme.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (payment.paymentMode != null)
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.creditcard,
                                    size: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    payment.paymentMode!,
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(payment.paymentDate ?? DateTime.now()),
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (payment.referenceNumber != null ||
                      payment.notes != null) ...[
                    const SizedBox(height: 12),
                    if (payment.referenceNumber != null) ...[
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ref: ${payment.referenceNumber}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (payment.notes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_text,
                            size: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              payment.notes!,
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  double _getTotalAmount(List<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + (payment.amount ?? 0));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
