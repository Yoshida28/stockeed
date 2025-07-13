class Payment {
  int? id;
  String? paymentNumber;
  String? paymentType; // received, paid
  int? partyId;
  String? partyName;
  double? amount;
  String? paymentMode;
  String? referenceNumber;
  String? notes;
  DateTime? paymentDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Payment({
    this.id,
    this.paymentNumber,
    this.paymentType,
    this.partyId,
    this.partyName,
    this.amount,
    this.paymentMode,
    this.referenceNumber,
    this.notes,
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
  });

  Payment copyWith({
    int? id,
    String? paymentNumber,
    String? paymentType,
    int? partyId,
    String? partyName,
    double? amount,
    String? paymentMode,
    String? referenceNumber,
    String? notes,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      paymentType: paymentType ?? this.paymentType,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payment_number': paymentNumber,
      'payment_type': paymentType,
      'party_id': partyId,
      'party_name': partyName,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
      'notes': notes,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      paymentNumber: map['payment_number'] as String?,
      paymentType: map['payment_type'] as String?,
      partyId: map['party_id'] as int?,
      partyName: map['party_name'] as String?,
      amount: map['amount'] as double?,
      paymentMode: map['payment_mode'] as String?,
      referenceNumber: map['reference_number'] as String?,
      notes: map['notes'] as String?,
      paymentDate: map['payment_date'] != null
          ? DateTime.parse(map['payment_date'] as String)
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
      'paymentNumber': paymentNumber,
      'paymentType': paymentType,
      'partyId': partyId,
      'partyName': partyName,
      'amount': amount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentNumber: json['paymentNumber'],
      paymentType: json['paymentType'],
      partyId: json['partyId'],
      partyName: json['partyName'],
      amount: json['amount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      notes: json['notes'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
