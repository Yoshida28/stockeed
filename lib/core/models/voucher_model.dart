class Voucher {
  int? id;
  String? voucherNumber;
  String? voucherType; // sales, purchase, payment, receipt, journal
  String? partyName;
  int? partyId;
  double? totalAmount;
  double? gstAmount;
  double? netAmount;
  String? paymentMode;
  String? referenceNumber;
  String? notes;
  DateTime? voucherDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Voucher({
    this.id,
    this.voucherNumber,
    this.voucherType,
    this.partyName,
    this.partyId,
    this.totalAmount,
    this.gstAmount,
    this.netAmount,
    this.paymentMode,
    this.referenceNumber,
    this.notes,
    this.voucherDate,
    this.createdAt,
    this.updatedAt,
  });

  Voucher copyWith({
    int? id,
    String? voucherNumber,
    String? voucherType,
    String? partyName,
    int? partyId,
    double? totalAmount,
    double? gstAmount,
    double? netAmount,
    String? paymentMode,
    String? referenceNumber,
    String? notes,
    DateTime? voucherDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Voucher(
      id: id ?? this.id,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      voucherType: voucherType ?? this.voucherType,
      partyName: partyName ?? this.partyName,
      partyId: partyId ?? this.partyId,
      totalAmount: totalAmount ?? this.totalAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      voucherDate: voucherDate ?? this.voucherDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voucher_number': voucherNumber,
      'voucher_type': voucherType,
      'party_name': partyName,
      'party_id': partyId,
      'total_amount': totalAmount,
      'gst_amount': gstAmount,
      'net_amount': netAmount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
      'notes': notes,
      'voucher_date': voucherDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'] as int?,
      voucherNumber: map['voucher_number'] as String?,
      voucherType: map['voucher_type'] as String?,
      partyName: map['party_name'] as String?,
      partyId: map['party_id'] as int?,
      totalAmount: map['total_amount'] as double?,
      gstAmount: map['gst_amount'] as double?,
      netAmount: map['net_amount'] as double?,
      paymentMode: map['payment_mode'] as String?,
      referenceNumber: map['reference_number'] as String?,
      notes: map['notes'] as String?,
      voucherDate: map['voucher_date'] != null
          ? DateTime.parse(map['voucher_date'] as String)
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
      'voucherNumber': voucherNumber,
      'voucherType': voucherType,
      'partyName': partyName,
      'partyId': partyId,
      'totalAmount': totalAmount,
      'gstAmount': gstAmount,
      'netAmount': netAmount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'voucherDate': voucherDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherNumber: json['voucherNumber'],
      voucherType: json['voucherType'],
      partyName: json['partyName'],
      partyId: json['partyId'],
      totalAmount: json['totalAmount']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      notes: json['notes'],
      voucherDate: json['voucherDate'] != null
          ? DateTime.parse(json['voucherDate'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
