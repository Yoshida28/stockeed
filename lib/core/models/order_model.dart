

class Order {
  int? id;
  String? orderNumber;
  String? status; // pending, accepted, dispatched, delivered
  int? clientId;
  String? clientName;
  double? totalAmount;
  double? gstAmount;
  double? netAmount;
  String? paymentStatus; // pending, partial, paid
  double? paidAmount;
  String? notes;
  DateTime? orderDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.orderNumber,
    this.status,
    this.clientId,
    this.clientName,
    this.totalAmount,
    this.gstAmount,
    this.netAmount,
    this.paymentStatus,
    this.paidAmount,
    this.notes,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
  });

  Order copyWith({
    int? id,
    String? orderNumber,
    String? status,
    int? clientId,
    String? clientName,
    double? totalAmount,
    double? gstAmount,
    double? netAmount,
    String? paymentStatus,
    double? paidAmount,
    String? notes,
    DateTime? orderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      totalAmount: totalAmount ?? this.totalAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'client_id': clientId,
      'client_name': clientName,
      'total_amount': totalAmount,
      'gst_amount': gstAmount,
      'net_amount': netAmount,
      'payment_status': paymentStatus,
      'paid_amount': paidAmount,
      'notes': notes,
      'order_date': orderDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String?,
      status: map['status'] as String?,
      clientId: map['client_id'] as int?,
      clientName: map['client_name'] as String?,
      totalAmount: map['total_amount'] as double?,
      gstAmount: map['gst_amount'] as double?,
      netAmount: map['net_amount'] as double?,
      paymentStatus: map['payment_status'] as String?,
      paidAmount: map['paid_amount'] as double?,
      notes: map['notes'] as String?,
      orderDate: map['order_date'] != null
          ? DateTime.parse(map['order_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'status': status,
      'clientId': clientId,
      'clientName': clientName,
      'totalAmount': totalAmount,
      'gstAmount': gstAmount,
      'netAmount': netAmount,
      'paymentStatus': paymentStatus,
      'paidAmount': paidAmount,
      'notes': notes,
      'orderDate': orderDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNumber: json['orderNumber'],
      status: json['status'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      totalAmount: json['totalAmount']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      paymentStatus: json['paymentStatus'],
      paidAmount: json['paidAmount']?.toDouble(),
      notes: json['notes'],
      orderDate:
          json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class OrderItem {
  int? id;
  int? orderId; // Reference to Order
  int? itemId; // Reference to Item
  String? itemName;
  double? unitPrice;
  double? gstPercentage;
  int? quantity;
  double? totalAmount;
  DateTime? createdAt;

  OrderItem({
    this.id,
    this.orderId,
    this.itemId,
    this.itemName,
    this.unitPrice,
    this.gstPercentage,
    this.quantity,
    this.totalAmount,
    this.createdAt,
  });

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? itemId,
    String? itemName,
    double? unitPrice,
    double? gstPercentage,
    int? quantity,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      unitPrice: unitPrice ?? this.unitPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'unit_price': unitPrice,
      'gst_percentage': gstPercentage,
      'quantity': quantity,
      'total_amount': totalAmount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int?,
      itemId: map['item_id'] as int?,
      itemName: map['item_name'] as String?,
      unitPrice: map['unit_price'] as double?,
      gstPercentage: map['gst_percentage'] as double?,
      quantity: map['quantity'] as int?,
      totalAmount: map['total_amount'] as double?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'itemName': itemName,
      'unitPrice': unitPrice,
      'gstPercentage': gstPercentage,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['orderId'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      unitPrice: json['unitPrice']?.toDouble(),
      gstPercentage: json['gstPercentage']?.toDouble(),
      quantity: json['quantity'],
      totalAmount: json['totalAmount']?.toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
