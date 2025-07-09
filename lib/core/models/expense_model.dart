import 'package:isar/isar.dart';

part 'expense_model.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  String? expenseNumber;
  String? expenseType;
  String? category;
  double? amount;
  double? gstPercentage;
  double? gstAmount;
  double? netAmount;
  String? paymentMode;
  String? referenceNumber;
  String? attachmentUrl;
  String? notes;
  bool? isRecurring;
  String? recurringFrequency; // daily, weekly, monthly, yearly

  DateTime? expenseDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  Expense({
    this.expenseNumber,
    this.expenseType,
    this.category,
    this.amount,
    this.gstPercentage,
    this.gstAmount,
    this.netAmount,
    this.paymentMode,
    this.referenceNumber,
    this.attachmentUrl,
    this.notes,
    this.isRecurring,
    this.recurringFrequency,
    this.expenseDate,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  Expense copyWith({
    String? expenseNumber,
    String? expenseType,
    String? category,
    double? amount,
    double? gstPercentage,
    double? gstAmount,
    double? netAmount,
    String? paymentMode,
    String? referenceNumber,
    String? attachmentUrl,
    String? notes,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return Expense(
      expenseNumber: expenseNumber ?? this.expenseNumber,
      expenseType: expenseType ?? this.expenseType,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      gstAmount: gstAmount ?? this.gstAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      expenseDate: expenseDate ?? this.expenseDate,
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
      'expenseNumber': expenseNumber,
      'expenseType': expenseType,
      'category': category,
      'amount': amount,
      'gstPercentage': gstPercentage,
      'gstAmount': gstAmount,
      'netAmount': netAmount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'attachmentUrl': attachmentUrl,
      'notes': notes,
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'expenseDate': expenseDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseNumber: json['expenseNumber'],
      expenseType: json['expenseType'],
      category: json['category'],
      amount: json['amount']?.toDouble(),
      gstPercentage: json['gstPercentage']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      attachmentUrl: json['attachmentUrl'],
      notes: json['notes'],
      isRecurring: json['isRecurring'],
      recurringFrequency: json['recurringFrequency'],
      expenseDate: json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'])
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
