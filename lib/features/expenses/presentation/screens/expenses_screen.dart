import 'package:flutter/cupertino.dart';
import 'package:stocked/core/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, String>> mockExpenses = [
    {
      'id': 'EXP-001',
      'category': 'Office Supplies',
      'amount': '₹1,200',
      'date': '2024-07-10'
    },
    {
      'id': 'EXP-002',
      'category': 'Travel',
      'amount': '₹3,000',
      'date': '2024-07-09'
    },
    {
      'id': 'EXP-003',
      'category': 'Utilities',
      'amount': '₹2,500',
      'date': '2024-07-08'
    },
    {
      'id': 'EXP-004',
      'category': 'Marketing',
      'amount': '₹4,000',
      'date': '2024-07-07'
    },
  ];

  void _showAddExpenseModal() {
    String category = '';
    String amount = '';
    String date = DateTime.now().toString().substring(0, 10);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Expense'),
        message: Column(
          children: [
            CupertinoTextField(
              placeholder: 'Category',
              onChanged: (v) => category = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Amount (₹)',
              keyboardType: TextInputType.number,
              onChanged: (v) => amount = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Date (YYYY-MM-DD)',
              onChanged: (v) => date = v,
              controller: TextEditingController(text: date),
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              if (category.isNotEmpty && amount.isNotEmpty && date.isNotEmpty) {
                setState(() {
                  mockExpenses.insert(0, {
                    'id':
                        'EXP-${(mockExpenses.length + 1).toString().padLeft(3, '0')}',
                    'category': category,
                    'amount': '₹$amount',
                    'date': date,
                  });
                });
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
    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Expenses'),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                decoration: AppTheme.glassmorphicDecoration,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.money_dollar,
                            color: AppTheme.primaryColor, size: 32),
                        const SizedBox(width: 12),
                        Text('Expenses', style: AppTheme.heading2),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                  child: Text('Expense ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child: Text('Category',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child: Text('Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  child: Text('Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                          Container(
                              height: 1,
                              color: AppTheme.primaryColor.withOpacity(0.15)),
                          ...mockExpenses.map((exp) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(exp['id']!)),
                                    Expanded(child: Text(exp['category']!)),
                                    Expanded(child: Text(exp['amount']!)),
                                    Expanded(child: Text(exp['date']!)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 48,
          right: 48,
          child: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            borderRadius: BorderRadius.circular(24),
            onPressed: _showAddExpenseModal,
            child: const Row(
              children: [
                Icon(CupertinoIcons.add, size: 20),
                SizedBox(width: 8),
                Text('Add Expense'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
