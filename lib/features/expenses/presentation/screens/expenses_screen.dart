import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/models/expense_model.dart';
import 'package:stocked/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _expenseCategories = ['All'];
  List<String> _paymentModes = [];

  @override
  void initState() {
    super.initState();
    _loadExpenseCategories();
  }

  void _loadExpenseCategories() {
    try {
      final categories = ConfigService.get<List<String>>('expense_categories');
      final paymentModes = ConfigService.get<List<String>>('payment_modes');
      setState(() {
        _expenseCategories = ['All', ...categories];
        _paymentModes = paymentModes;
      });
    } catch (e) {
      print('Error loading expense categories: $e');
      setState(() {
        _expenseCategories = [
          'All',
          'Office Supplies',
          'Travel',
          'Marketing',
          'Utilities',
          'Rent',
          'Salaries',
          'Equipment',
          'Maintenance',
          'Other',
        ];
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

  void _showAddExpenseModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        String category = _expenseCategories.skip(1).first;
        String description = '';
        String amount = '';
        String paymentMode =
            _paymentModes.isNotEmpty ? _paymentModes.first : 'Cash';
        String vendorName = '';
        String referenceNumber = '';
        String notes = '';
        DateTime selectedDate = DateTime.now();
        bool isFormValid = false;
        bool includeGST = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Validate form
            void validateForm() {
              setModalState(() {
                isFormValid = description.trim().isNotEmpty &&
                    amount.trim().isNotEmpty &&
                    double.tryParse(amount) != null &&
                    double.tryParse(amount)! > 0;
              });
            }

            // Calculate amounts
            double getBaseAmount() => double.tryParse(amount) ?? 0.0;
            double getGSTAmount() => includeGST ? getBaseAmount() * 0.18 : 0.0;
            double getNetAmount() => getBaseAmount() + getGSTAmount();

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
                            'Add Expense',
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
                          // Category
                          _buildFormSection(
                            title: 'Expense Category',
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
                                      title: const Text('Select Category'),
                                      actions: _expenseCategories
                                          .skip(1)
                                          .map((cat) =>
                                              CupertinoActionSheetAction(
                                                onPressed: () {
                                                  setModalState(
                                                      () => category = cat);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(cat),
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
                                      category,
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

                          // Description
                          _buildFormSection(
                            title: 'Description',
                            child: CupertinoTextField(
                              placeholder: 'Enter expense description',
                              onChanged: (value) {
                                description = value;
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

                          // GST Toggle
                          _buildFormSection(
                            title: 'Include GST (18%)',
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CupertinoColors.systemGrey4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.all(16),
                                onPressed: () {
                                  setModalState(() => includeGST = !includeGST);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      includeGST ? 'Yes' : 'No',
                                      style: AppTheme.body1,
                                    ),
                                    CupertinoSwitch(
                                      value: includeGST,
                                      onChanged: (value) {
                                        setModalState(() => includeGST = value);
                                      },
                                      activeColor: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Amount Breakdown
                          if (amount.isNotEmpty &&
                              double.tryParse(amount) != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Base Amount:',
                                          style: AppTheme.body2),
                                      Text(
                                          '₹${getBaseAmount().toStringAsFixed(2)}',
                                          style: AppTheme.body2),
                                    ],
                                  ),
                                  if (includeGST) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('GST (18%):',
                                            style: AppTheme.body2),
                                        Text(
                                            '₹${getGSTAmount().toStringAsFixed(2)}',
                                            style: AppTheme.body2),
                                      ],
                                    ),
                                  ],
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Amount:',
                                          style: AppTheme.body1.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          '₹${getNetAmount().toStringAsFixed(2)}',
                                          style: AppTheme.body1.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.errorColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

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
                            title: 'Expense Date',
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

                          // Vendor Name
                          _buildFormSection(
                            title: 'Vendor Name (Optional)',
                            child: CupertinoTextField(
                              placeholder: 'Enter vendor or supplier name',
                              onChanged: (value) => vendorName = value,
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

                          // Reference Number
                          _buildFormSection(
                            title: 'Reference Number (Optional)',
                            child: CupertinoTextField(
                              placeholder: 'Invoice number, receipt ID, etc.',
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
                                  ? AppTheme.errorColor
                                  : CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: isFormValid
                                  ? () {
                                      final expenseAmount = getBaseAmount();
                                      final gstAmount = getGSTAmount();
                                      final netAmount = getNetAmount();

                                      final expense = Expense(
                                        expenseNumber:
                                            'EXP-${DateTime.now().millisecondsSinceEpoch}',
                                        expenseDate: selectedDate,
                                        category: category,
                                        description: description.trim(),
                                        amount: expenseAmount,
                                        paymentMode: paymentMode,
                                        referenceNumber:
                                            referenceNumber.trim().isNotEmpty
                                                ? referenceNumber.trim()
                                                : null,
                                        vendorName: vendorName.trim().isNotEmpty
                                            ? vendorName.trim()
                                            : null,
                                        gstAmount: gstAmount,
                                        netAmount: netAmount,
                                        notes: notes.trim().isNotEmpty
                                            ? notes.trim()
                                            : null,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );
                                      ref
                                          .read(
                                              expensesProviderNotifier.notifier)
                                          .addExpense(expense);
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: Text(
                                'Add Expense',
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
    final expensesState = ref.watch(expensesProviderNotifier);
    final expenses = expensesState.expenses;

    // Filter expenses based on search and category
    final filteredExpenses = expenses.where((expense) {
      final matchesSearch = expense.description
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesCategory = _selectedCategory == 'All' ||
          expense.category == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(32),
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
                          'Expenses',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track and manage your business expenses',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    onPressed: _showAddExpenseModal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Add Expense',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filter Section
            Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: CupertinoSearchTextField(
                      placeholder: 'Search expenses by description or vendor...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: AppTheme.body1.copyWith(fontSize: 16),
                      prefixIcon: Icon(CupertinoIcons.search,
                          color: AppTheme.primaryColor, size: 20),
                      decoration: const BoxDecoration(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _expenseCategories.length,
                            itemBuilder: (context, index) {
                              final category = _expenseCategories[index];
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(25),
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Text(
                                    category,
                                    style: AppTheme.body2.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimaryColor,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 15,
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

            // Expenses Summary Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Expenses',
                      value: '${filteredExpenses.length}',
                      subtitle: 'transactions',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      color: AppTheme.primaryColor,
                      gradient: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Amount',
                      value:
                          '₹${_formatAmount(_getTotalAmount(filteredExpenses))}',
                      subtitle: 'spent',
                      icon: CupertinoIcons.chart_bar_fill,
                      color: AppTheme.errorColor,
                      gradient: [AppTheme.errorColor, AppTheme.warningColor],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Average Expense',
                      value: filteredExpenses.isNotEmpty
                          ? '₹${_formatAmount(_getTotalAmount(filteredExpenses) / filteredExpenses.length)}'
                          : '₹0.00',
                      subtitle: 'per transaction',
                      icon: CupertinoIcons.chart_pie_fill,
                      color: AppTheme.successColor,
                      gradient: [AppTheme.successColor, AppTheme.accentColor],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Expenses List
            expensesState.isLoading
                ? Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(radius: 24),
                          const SizedBox(height: 20),
                          Text(
                            'Loading expenses...',
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildExpensesList(filteredExpenses),
                  ),

            // Bottom padding for better scrolling experience
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.arrow_up_right,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: AppTheme.heading2.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTheme.body2.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  CupertinoIcons.money_dollar_circle,
                  size: 80,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No expenses found',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add your first expense to start tracking your business costs',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(28),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                onPressed: _showAddExpenseModal,
                child: const Text('Add Expense',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...expenses.map((expense) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense.expenseNumber ?? 'N/A',
                        style: AppTheme.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppTheme.errorColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        expense.category?.toUpperCase() ?? 'N/A',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description ?? 'Unknown',
                            style: AppTheme.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (expense.vendorName != null)
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.person_circle,
                                  size: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Vendor: ${expense.vendorName}',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          if (expense.paymentMode != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.creditcard,
                                  size: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Payment: ${expense.paymentMode}',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${_formatAmount(expense.amount ?? 0)}',
                          style: AppTheme.heading3.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(expense.expenseDate ?? DateTime.now()),
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        if (expense.gstAmount != null &&
                            expense.gstAmount! > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'GST: ₹${_formatAmount(expense.gstAmount!)}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (expense.referenceNumber != null ||
                    expense.notes != null) ...[
                  const SizedBox(height: 16),
                  if (expense.referenceNumber != null) ...[
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ref: ${expense.referenceNumber}',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (expense.notes != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.chat_bubble_text,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expense.notes!,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                            maxLines: 3,
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

  double _getTotalAmount(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
