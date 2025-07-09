import 'package:isar/isar.dart';

part 'payment_model.g.dart';

@collection
class Payment {
  Id id = Isar.autoIncrement;

  String? paymentNumber;
  String? clientId;
  String? clientName;
  double? amount;
  String? paymentMode;
  String? referenceNumber;
  String? proofUrl;
  String? status; // pending, approved, rejected
  String? notes;

  DateTime? paymentDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  Payment({
    this.paymentNumber,
    this.clientId,
    this.clientName,
    this.amount,
    this.paymentMode,
    this.referenceNumber,
    this.proofUrl,
    this.status,
    this.notes,
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  Payment copyWith({
    String? paymentNumber,
    String? clientId,
    String? clientName,
    double? amount,
    String? paymentMode,
    String? referenceNumber,
    String? proofUrl,
    String? status,
    String? notes,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return Payment(
      paymentNumber: paymentNumber ?? this.paymentNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      proofUrl: proofUrl ?? this.proofUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
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
      'paymentNumber': paymentNumber,
      'clientId': clientId,
      'clientName': clientName,
      'amount': amount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'proofUrl': proofUrl,
      'status': status,
      'notes': notes,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentNumber: json['paymentNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      amount: json['amount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      proofUrl: json['proofUrl'],
      status: json['status'],
      notes: json['notes'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
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
