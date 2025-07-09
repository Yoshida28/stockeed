import 'package:isar/isar.dart';

part 'order_model.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;

  String? orderNumber;
  String? status; // pending, accepted, dispatched, delivered
  String? clientId;
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

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  Order({
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
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  Order copyWith({
    String? orderNumber,
    String? status,
    String? clientId,
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
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return Order(
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
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudId: cloudId ?? this.cloudId,
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
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
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
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      syncStatus: json['syncStatus'],
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : null,
      cloudId: json['cloudId'],
    );
  }
}

@collection
class OrderItem {
  Id id = Isar.autoIncrement;

  int? orderId; // Reference to Order
  int? itemId; // Reference to Item

  String? itemName;
  double? unitPrice;
  double? gstPercentage;
  int? quantity;
  double? totalAmount;
  double? gstAmount;
  double? netAmount;

  DateTime? createdAt;
  DateTime? updatedAt;

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  OrderItem({
    this.orderId,
    this.itemId,
    this.itemName,
    this.unitPrice,
    this.gstPercentage,
    this.quantity,
    this.totalAmount,
    this.gstAmount,
    this.netAmount,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  OrderItem copyWith({
    int? orderId,
    int? itemId,
    String? itemName,
    double? unitPrice,
    double? gstPercentage,
    int? quantity,
    double? totalAmount,
    double? gstAmount,
    double? netAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return OrderItem(
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      unitPrice: unitPrice ?? this.unitPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      netAmount: netAmount ?? this.netAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudId: cloudId ?? this.cloudId,
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
      'gstAmount': gstAmount,
      'netAmount': netAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
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
      gstAmount: json['gstAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      syncStatus: json['syncStatus'],
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : null,
      cloudId: json['cloudId'],
    );
  }
}
