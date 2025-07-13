import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/core/models/order_model.dart';
import 'package:stocked/features/orders/presentation/providers/orders_provider.dart';
import 'package:stocked/core/services/config_service.dart';
import 'package:stocked/core/services/database_service.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';
  List<String> _orderStatuses = ['All'];
  List<String> _paymentStatuses = [];

  @override
  void initState() {
    super.initState();
    _loadOrderStatuses();
  }

  void _loadOrderStatuses() {
    try {
      final statuses = ConfigService.get<List<String>>('order_statuses');
      final paymentStatuses =
          ConfigService.get<List<String>>('payment_statuses');
      setState(() {
        _orderStatuses = ['All', ...statuses];
        _paymentStatuses = paymentStatuses;
      });
    } catch (e) {
      print('Error loading order statuses: $e');
      setState(() {
        _orderStatuses = [
          'All',
          'Pending',
          'Accepted',
          'Dispatched',
          'Delivered',
          'Cancelled'
        ];
        _paymentStatuses = ['Pending', 'Partial', 'Paid'];
      });
    }
  }

  void _showAddOrderModal() {
    String clientName = '';
    String totalAmount = '';
    String status = 'pending';
    String paymentStatus = 'pending';
    String notes = '';

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Order'),
        message: Column(
          children: [
            CupertinoTextField(
              placeholder: 'Client Name',
              onChanged: (v) => clientName = v,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: 'Total Amount (₹)',
              keyboardType: TextInputType.number,
              onChanged: (v) => totalAmount = v,
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
                  status =
                      _orderStatuses.skip(1).elementAt(index).toLowerCase();
                },
                children: _orderStatuses
                    .skip(1)
                    .map((status) => Center(child: Text(status)))
                    .toList(),
              ),
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
                  paymentStatus = _paymentStatuses[index].toLowerCase();
                },
                children: _paymentStatuses
                    .map((status) => Center(child: Text(status)))
                    .toList(),
              ),
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
              if (clientName.isNotEmpty && totalAmount.isNotEmpty) {
                final order = Order(
                  orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                  status: status,
                  clientName: clientName,
                  totalAmount: double.tryParse(totalAmount) ?? 0.0,
                  gstAmount: (double.tryParse(totalAmount) ?? 0.0) * 0.18,
                  netAmount: (double.tryParse(totalAmount) ?? 0.0) * 1.18,
                  paymentStatus: paymentStatus,
                  paidAmount: 0.0,
                  notes: notes.isNotEmpty ? notes : null,
                  orderDate: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                ref.read(ordersProviderNotifier.notifier).addOrder(order);
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

  void _updateOrderStatus(Order order, String newStatus) {
    ref
        .read(ordersProviderNotifier.notifier)
        .updateOrderStatus(order.id!, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProviderNotifier);
    final orders = ordersState.orders;

    // Filter orders based on search and status
    final filteredOrders = orders.where((order) {
      final matchesSearch = order.clientName
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesStatus = _selectedStatus == 'All' ||
          order.status == _selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
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
                  'Orders',
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
                onPressed: _showAddOrderModal,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Add Order', style: TextStyle(color: Colors.white)),
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
                placeholder: 'Search orders...',
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

              // Status Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _orderStatuses.length,
                        itemBuilder: (context, index) {
                          final status = _orderStatuses[index];
                          final isSelected = _selectedStatus == status;
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
                                  _selectedStatus = status;
                                });
                              },
                              child: Text(
                                status,
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

        // Orders Summary Cards
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Orders',
                  value: '${filteredOrders.length}',
                  icon: CupertinoIcons.cart,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Value',
                  value: '₹${_formatAmount(_getTotalValue(filteredOrders))}',
                  icon: CupertinoIcons.money_dollar,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Orders List
        Expanded(
          child: ordersState.isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _buildOrdersList(filteredOrders),
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

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.cart,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('No orders found',
                style: AppTheme.heading3
                    .copyWith(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: 8),
            Text('Add your first order to get started',
                style: AppTheme.body2
                    .copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final canUpdateStatus =
            order.status != 'delivered' && order.status != 'cancelled';

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
                    order.orderNumber ?? 'N/A',
                    style: AppTheme.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status ?? 'pending'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status?.toUpperCase() ?? 'N/A',
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
                          order.clientName ?? 'Unknown',
                          style: AppTheme.body1,
                        ),
                        Text(
                          'Payment: ${order.paymentStatus?.toUpperCase() ?? 'N/A'}',
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
                        '₹${_formatAmount(order.totalAmount ?? 0)}',
                        style: AppTheme.heading3
                            .copyWith(color: AppTheme.primaryColor),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(order.orderDate ?? DateTime.now()),
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
              if (order.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  order.notes!,
                  style: AppTheme.caption
                      .copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
              if (canUpdateStatus) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: () => _showStatusUpdateModal(order),
                      child: const Text('Update Status'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showStatusUpdateModal(Order order) {
    String selectedStatus = order.status ?? 'pending';

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Update Order Status'),
        message: Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (index) {
              selectedStatus =
                  _orderStatuses.skip(1).elementAt(index).toLowerCase();
            },
            children: _orderStatuses
                .skip(1)
                .map((status) => Center(child: Text(status)))
                .toList(),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _updateOrderStatus(order, selectedStatus);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'accepted':
        return AppTheme.infoColor;
      case 'dispatched':
        return AppTheme.primaryColor;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  double _getTotalValue(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + (order.totalAmount ?? 0));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
