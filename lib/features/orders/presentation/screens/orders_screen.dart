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
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        String clientName = '';
        String totalAmount = '';
        String status = _orderStatuses.skip(1).first.toLowerCase();
        String paymentStatus = _paymentStatuses.isNotEmpty
            ? _paymentStatuses.first.toLowerCase()
            : 'pending';
        String notes = '';
        DateTime selectedDate = DateTime.now();
        bool isFormValid = false;
        bool includeGST = true;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Validate form
            void validateForm() {
              setModalState(() {
                isFormValid = clientName.trim().isNotEmpty &&
                    totalAmount.trim().isNotEmpty &&
                    double.tryParse(totalAmount) != null &&
                    double.tryParse(totalAmount)! > 0;
              });
            }

            // Calculate amounts
            double getBaseAmount() => double.tryParse(totalAmount) ?? 0.0;
            double getGSTAmount() => includeGST ? getBaseAmount() * 0.18 : 0.0;
            double getNetAmount() => getBaseAmount() + getGSTAmount();

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        Text('Add New Order', style: AppTheme.heading3),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: isFormValid
                              ? () {
                                  final order = Order(
                                    orderNumber:
                                        'ORD-${DateTime.now().millisecondsSinceEpoch}',
                                    status: status,
                                    clientName: clientName.trim(),
                                    totalAmount: getBaseAmount(),
                                    gstAmount: getGSTAmount(),
                                    netAmount: getNetAmount(),
                                    paymentStatus: paymentStatus,
                                    paidAmount: 0.0,
                                    notes: notes.trim().isNotEmpty
                                        ? notes.trim()
                                        : null,
                                    orderDate: selectedDate,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                                  ref
                                      .read(ordersProviderNotifier.notifier)
                                      .addOrder(order);
                                  Navigator.pop(context);
                                }
                              : null,
                          child: Text(
                            'Create',
                            style: TextStyle(
                              color: isFormValid
                                  ? AppTheme.primaryColor
                                  : CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Client Name
                          _buildTextField(
                            label: 'Client Name *',
                            placeholder: 'Enter client name',
                            icon: CupertinoIcons.person,
                            onChanged: (value) {
                              clientName = value;
                              validateForm();
                            },
                          ),
                          const SizedBox(height: 20),

                          // Order Date
                          _buildDatePicker(
                            label: 'Order Date',
                            selectedDate: selectedDate,
                            onDateChanged: (date) {
                              setModalState(() {
                                selectedDate = date;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Total Amount
                          _buildTextField(
                            label: 'Total Amount (₹) *',
                            placeholder: '0.00',
                            icon: CupertinoIcons.money_dollar,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              totalAmount = value;
                              validateForm();
                            },
                          ),
                          const SizedBox(height: 16),

                          // GST Toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.percent,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Include GST (18%)',
                                        style: AppTheme.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Automatically calculate GST amount',
                                        style: AppTheme.body2.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: includeGST,
                                  onChanged: (value) {
                                    setModalState(() {
                                      includeGST = value;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Amount Breakdown
                          if (totalAmount.isNotEmpty &&
                              double.tryParse(totalAmount) != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Amount Breakdown',
                                    style: AppTheme.body2.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAmountRow(
                                      'Base Amount', getBaseAmount()),
                                  if (includeGST) ...[
                                    const SizedBox(height: 8),
                                    _buildAmountRow(
                                        'GST (18%)', getGSTAmount()),
                                  ],
                                  const Divider(height: 16),
                                  _buildAmountRow('Net Amount', getNetAmount(),
                                      isTotal: true),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Order Status
                          _buildStatusPicker(
                            label: 'Order Status',
                            selectedValue: status,
                            options: _orderStatuses
                                .skip(1)
                                .map((s) => s.toLowerCase())
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                status = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Payment Status
                          _buildStatusPicker(
                            label: 'Payment Status',
                            selectedValue: paymentStatus,
                            options: _paymentStatuses
                                .map((s) => s.toLowerCase())
                                .toList(),
                            onChanged: (value) {
                              setModalState(() {
                                paymentStatus = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Notes
                          _buildTextField(
                            label: 'Notes (Optional)',
                            placeholder: 'Add any additional notes',
                            icon: CupertinoIcons.text_quote,
                            maxLines: 3,
                            onChanged: (value) {
                              notes = value;
                            },
                          ),
                          const SizedBox(height: 32),
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

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: CupertinoTextField(
            placeholder: placeholder,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: null,
            style: AppTheme.body1,
            placeholderStyle: AppTheme.body1.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: AppTheme.body1,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
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
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              children: [
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                const Spacer(),
                                Text('Select Date', style: AppTheme.heading3),
                                const Spacer(),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedDate,
                              onDateTimeChanged: onDateChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPicker({
    required String label,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                label.contains('Order')
                    ? CupertinoIcons.cube_box
                    : CupertinoIcons.creditcard,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    onChanged(options[index]);
                  },
                  children: options.map((option) {
                    return Center(
                      child: Text(
                        option.toUpperCase(),
                        style: AppTheme.body1,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.body2.copyWith(
            color: AppTheme.textSecondaryColor,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTheme.body2.copyWith(
            color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
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
                          'Orders',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryColor,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage customer orders and track fulfillment',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    onPressed: _showAddOrderModal,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Add Order',
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
                      placeholder: 'Search orders by customer name...',
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

                  // Status Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _orderStatuses.length,
                            itemBuilder: (context, index) {
                              final status = _orderStatuses[index];
                              final isSelected = _selectedStatus == status;
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
                                      _selectedStatus = status;
                                    });
                                  },
                                  child: Text(
                                    status,
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

            // Orders Summary Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Orders',
                      value: '${filteredOrders.length}',
                      subtitle: 'orders',
                      icon: CupertinoIcons.shopping_cart,
                      color: AppTheme.primaryColor,
                      gradient: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Revenue',
                      value:
                          '₹${_formatAmount(_getTotalRevenue(filteredOrders))}',
                      subtitle: 'generated',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      color: AppTheme.successColor,
                      gradient: [AppTheme.successColor, AppTheme.accentColor],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Pending Orders',
                      value: '${_getPendingOrdersCount(filteredOrders)}',
                      subtitle: 'awaiting',
                      icon: CupertinoIcons.clock_fill,
                      color: AppTheme.warningColor,
                      gradient: [AppTheme.warningColor, AppTheme.errorColor],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Orders List
            ordersState.isLoading
                ? Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(radius: 24),
                          const SizedBox(height: 20),
                          Text(
                            'Loading orders...',
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
                    child: _buildOrdersList(filteredOrders),
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

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
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
                  CupertinoIcons.shopping_cart,
                  size: 80,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No orders found',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add your first order to start managing customer requests',
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
                onPressed: _showAddOrderModal,
                child: const Text('Add Order',
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
        ...orders.map((order) {
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
                          order.orderNumber ?? 'N/A',
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
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _getStatusColor(order.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.status?.toUpperCase() ?? 'N/A',
                          style: AppTheme.caption.copyWith(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.w600,
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
                              order.clientName ?? 'Unknown',
                              style: AppTheme.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (order.notes != null)
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.text_quote,
                                    size: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    order.notes!,
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 14,
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
                            '₹${_formatAmount(order.netAmount ?? 0)}',
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(order.orderDate ?? DateTime.now()),
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                          if (order.gstAmount != null &&
                              order.gstAmount! > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'GST: ₹${_formatAmount(order.gstAmount!)}',
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
                  if (order.paymentStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.creditcard,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Payment: ${order.paymentStatus!.toUpperCase()}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'processing':
        return AppTheme.primaryColor;
      case 'shipped':
        return AppTheme.accentColor;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  double _getTotalRevenue(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + (order.totalAmount ?? 0));
  }

  int _getPendingOrdersCount(List<Order> orders) {
    return orders
        .where((order) => order.status?.toLowerCase() == 'pending')
        .length;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
}
