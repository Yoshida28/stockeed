import 'package:flutter/cupertino.dart';
import 'package:stocked/core/theme/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, String>> mockOrders = [
    {
      'id': 'ORD-001',
      'client': 'TechCorp',
      'amount': '₹12,000',
      'status': 'Pending'
    },
    {
      'id': 'ORD-002',
      'client': 'OfficePlus',
      'amount': '₹8,500',
      'status': 'Delivered'
    },
    {
      'id': 'ORD-003',
      'client': 'SmartStore',
      'amount': '₹5,200',
      'status': 'Dispatched'
    },
    {
      'id': 'ORD-004',
      'client': 'DigitalHub',
      'amount': '₹15,000',
      'status': 'Pending'
    },
  ];

  void _shipOrder(int index) {
    setState(() {
      mockOrders[index]['status'] = 'Delivered';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Orders'),
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
                    const Icon(CupertinoIcons.cart,
                        color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 12),
                    Text('Orders', style: AppTheme.heading2),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                              child: Text('Order ID',
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
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 80),
                        ],
                      ),
                      Container(
                          height: 1,
                          color: AppTheme.primaryColor.withOpacity(0.15)),
                      ...mockOrders.asMap().entries.map((entry) {
                        final i = entry.key;
                        final order = entry.value;
                        final canShip = order['status'] == 'Pending' ||
                            order['status'] == 'Dispatched';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text(order['id']!)),
                              Expanded(child: Text(order['client']!)),
                              Expanded(child: Text(order['amount']!)),
                              Expanded(child: Text(order['status']!)),
                              if (canShip)
                                SizedBox(
                                  width: 80,
                                  child: CupertinoButton.filled(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 4),
                                    borderRadius: BorderRadius.circular(8),
                                    onPressed: () => _shipOrder(i),
                                    child: const Text('Ship'),
                                  ),
                                )
                              else
                                const SizedBox(width: 80),
                            ],
                          ),
                        );
                      }),
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
