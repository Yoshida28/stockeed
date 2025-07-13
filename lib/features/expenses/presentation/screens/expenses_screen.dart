import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
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
    String category = _expenseCategories.skip(1).first;
    String description = '';
    String amount = '';
    String paymentMode =
        _paymentModes.isNotEmpty ? _paymentModes.first : 'Cash';
    String vendorName = '';
    String referenceNumber = '';
    String notes = '';

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Expense'),
        message: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  category = _expenseCategories.skip(1).elementAt(index);
                },
                children: _expenseCategories
                    .skip(1)
                    .map((cat) => Center(child: Text(cat)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Description',
              onChanged: (v) => description = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Amount (₹)',
              keyboardType: TextInputType.number,
              onChanged: (v) => amount = v,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoPicker(
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  paymentMode = _paymentModes[index];
                },
                children: _paymentModes
                    .map((mode) => Center(child: Text(mode)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Vendor Name (Optional)',
              onChanged: (v) => vendorName = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Reference Number (Optional)',
              onChanged: (v) => referenceNumber = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Notes (Optional)',
              onChanged: (v) => notes = v,
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              if (description.isNotEmpty && amount.isNotEmpty) {
                final expenseAmount = double.tryParse(amount) ?? 0.0;
                final gstAmount = expenseAmount * 0.18;
                final netAmount = expenseAmount + gstAmount;

                final expense = Expense(
                  expenseNumber: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
                  expenseDate: DateTime.now(),
                  category: category,
                  description: description,
                  amount: expenseAmount,
                  paymentMode: paymentMode,
                  referenceNumber:
                      referenceNumber.isNotEmpty ? referenceNumber : null,
                  vendorName: vendorName.isNotEmpty ? vendorName : null,
                  gstAmount: gstAmount,
                  netAmount: netAmount,
                  notes: notes.isNotEmpty ? notes : null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                ref.read(expensesProviderNotifier.notifier).addExpense(expense);
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
      ),
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

    return Column(
      children: [
        // Header with Add Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Expenses',
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
                onPressed: _showAddExpenseModal,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Add Expense', style: TextStyle(color: Colors.white)),
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
                placeholder: 'Search expenses...',
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

              // Category Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _expenseCategories.length,
                        itemBuilder: (context, index) {
                          final category = _expenseCategories[index];
                          final isSelected = _selectedCategory == category;
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
                                  _selectedCategory = category;
                                });
                              },
                              child: Text(
                                category,
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

        // Expenses Summary Cards
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Expenses',
                  value: '${filteredExpenses.length}',
                  icon: CupertinoIcons.money_dollar,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Amount',
                  value: '₹${_formatAmount(_getTotalAmount(filteredExpenses))}',
                  icon: CupertinoIcons.chart_bar,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Expenses List
        Expanded(
          child: expensesState.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _buildExpensesList(filteredExpenses),
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

  Widget _buildExpensesList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.money_dollar,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('No expenses found',
                style: AppTheme.heading3
                    .copyWith(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 8),
            Text('Add your first expense to get started',
                style: AppTheme.body2
                    .copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
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
                    expense.expenseNumber ?? 'N/A',
                    style: AppTheme.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      expense.category?.toUpperCase() ?? 'N/A',
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
                          expense.description ?? 'Unknown',
                          style: AppTheme.body1,
                        ),
                        if (expense.vendorName != null)
                          Text(
                            'Vendor: ${expense.vendorName}',
                            style: AppTheme.caption
                                .copyWith(color: AppTheme.textSecondaryColor),
                          ),
                        if (expense.paymentMode != null)
                          Text(
                            'Payment: ${expense.paymentMode}',
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
                        '₹${_formatAmount(expense.amount ?? 0)}',
                        style: AppTheme.heading3
                            .copyWith(color: AppTheme.errorColor),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(expense.expenseDate ?? DateTime.now()),
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
              if (expense.referenceNumber != null || expense.notes != null) ...[
                const SizedBox(height: 8),
                if (expense.referenceNumber != null)
                  Text(
                    'Ref: ${expense.referenceNumber}',
                    style: AppTheme.caption
                        .copyWith(color: AppTheme.textSecondaryColor),
                  ),
                if (expense.notes != null)
                  Text(
                    expense.notes!,
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

  double _getTotalAmount(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + (expense.amount ?? 0));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
