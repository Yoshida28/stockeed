class Expense {
  int? id;
  String? expenseNumber;
  String? category;
  String? description;
  double? amount;
  String? paymentMode;
  String? referenceNumber;
  String? vendorName;
  String? gstNumber;
  double? gstAmount;
  double? netAmount;
  String? notes;
  DateTime? expenseDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Expense({
    this.id,
    this.expenseNumber,
    this.category,
    this.description,
    this.amount,
    this.paymentMode,
    this.referenceNumber,
    this.vendorName,
    this.gstNumber,
    this.gstAmount,
    this.netAmount,
    this.notes,
    this.expenseDate,
    this.createdAt,
    this.updatedAt,
  });

  Expense copyWith({
    int? id,
    String? expenseNumber,
    String? category,
    String? description,
    double? amount,
    String? paymentMode,
    String? referenceNumber,
    String? vendorName,
    String? gstNumber,
    double? gstAmount,
    double? netAmount,
    String? notes,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      vendorName: vendorName ?? this.vendorName,
      gstNumber: gstNumber ?? this.gstNumber,
      gstAmount: gstAmount ?? this.gstAmount,
      netAmount: netAmount ?? this.netAmount,
      notes: notes ?? this.notes,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_number': expenseNumber,
      'category': category,
      'description': description,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
      'vendor_name': vendorName,
      'gst_number': gstNumber,
      'gst_amount': gstAmount,
      'net_amount': netAmount,
      'notes': notes,
      'expense_date': expenseDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      expenseNumber: map['expense_number'] as String?,
      category: map['category'] as String?,
      description: map['description'] as String?,
      amount: map['amount'] as double?,
      paymentMode: map['payment_mode'] as String?,
      referenceNumber: map['reference_number'] as String?,
      vendorName: map['vendor_name'] as String?,
      gstNumber: map['gst_number'] as String?,
      gstAmount: map['gst_amount'] as double?,
      netAmount: map['net_amount'] as double?,
      notes: map['notes'] as String?,
      expenseDate: map['expense_date'] != null
          ? DateTime.parse(map['expense_date'] as String)
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
      'expenseNumber': expenseNumber,
      'category': category,
      'description': description,
      'amount': amount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'vendorName': vendorName,
      'gstNumber': gstNumber,
      'gstAmount': gstAmount,
      'netAmount': netAmount,
      'notes': notes,
      'expenseDate': expenseDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseNumber: json['expenseNumber'],
      category: json['category'],
      description: json['description'],
      amount: json['amount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      vendorName: json['vendorName'],
      gstNumber: json['gstNumber'],
      gstAmount: json['gstAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      notes: json['notes'],
      expenseDate: json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
