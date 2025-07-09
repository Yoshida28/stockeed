import 'package:flutter/cupertino.dart';
import 'package:stocked/core/theme/app_theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockPayments = [
      {
        'id': 'PAY-001',
        'client': 'TechCorp',
        'amount': '₹5,000',
        'date': '2024-07-10'
      },
      {
        'id': 'PAY-002',
        'client': 'OfficePlus',
        'amount': '₹3,200',
        'date': '2024-07-09'
      },
      {
        'id': 'PAY-003',
        'client': 'SmartStore',
        'amount': '₹7,800',
        'date': '2024-07-08'
      },
      {
        'id': 'PAY-004',
        'client': 'DigitalHub',
        'amount': '₹2,500',
        'date': '2024-07-07'
      },
    ];
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Payments'),
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
                    const Icon(CupertinoIcons.creditcard,
                        color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 12),
                    Text('Payments', style: AppTheme.heading2),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                              child: Text('Payment ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Client',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Amount',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      Container(
                          height: 1,
                          color: AppTheme.primaryColor.withOpacity(0.15)),
                      ...mockPayments.map((pay) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(pay['id']!)),
                                Expanded(child: Text(pay['client']!)),
                                Expanded(child: Text(pay['amount']!)),
                                Expanded(child: Text(pay['date']!)),
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
    );
  }
}
