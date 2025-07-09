import 'package:isar/isar.dart';

part 'voucher_model.g.dart';

@collection
class Voucher {
  Id id = Isar.autoIncrement;

  String? voucherNumber;
  String? voucherType; // sales, purchase, payment, receipt, journal
  String? partyName;
  double? amount;
  double? gstPercentage;
  double? tdsPercentage;
  double? gstAmount;
  double? tdsAmount;
  double? netAmount;
  String? paymentMode;
  String? referenceNumber;
  String? notes;
  String? status; // pending, approved, rejected

  DateTime? voucherDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  Voucher({
    this.voucherNumber,
    this.voucherType,
    this.partyName,
    this.amount,
    this.gstPercentage,
    this.tdsPercentage,
    this.gstAmount,
    this.tdsAmount,
    this.netAmount,
    this.paymentMode,
    this.referenceNumber,
    this.notes,
    this.status,
    this.voucherDate,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  Voucher copyWith({
    String? voucherNumber,
    String? voucherType,
    String? partyName,
    double? amount,
    double? gstPercentage,
    double? tdsPercentage,
    double? gstAmount,
    double? tdsAmount,
    double? netAmount,
    String? paymentMode,
    String? referenceNumber,
    String? notes,
    String? status,
    DateTime? voucherDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return Voucher(
      voucherNumber: voucherNumber ?? this.voucherNumber,
      voucherType: voucherType ?? this.voucherType,
      partyName: partyName ?? this.partyName,
      amount: amount ?? this.amount,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      tdsPercentage: tdsPercentage ?? this.tdsPercentage,
      gstAmount: gstAmount ?? this.gstAmount,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      voucherDate: voucherDate ?? this.voucherDate,
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
      'voucherNumber': voucherNumber,
      'voucherType': voucherType,
      'partyName': partyName,
      'amount': amount,
      'gstPercentage': gstPercentage,
      'tdsPercentage': tdsPercentage,
      'gstAmount': gstAmount,
      'tdsAmount': tdsAmount,
      'netAmount': netAmount,
      'paymentMode': paymentMode,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'status': status,
      'voucherDate': voucherDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
    };
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherNumber: json['voucherNumber'],
      voucherType: json['voucherType'],
      partyName: json['partyName'],
      amount: json['amount']?.toDouble(),
      gstPercentage: json['gstPercentage']?.toDouble(),
      tdsPercentage: json['tdsPercentage']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      tdsAmount: json['tdsAmount']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      paymentMode: json['paymentMode'],
      referenceNumber: json['referenceNumber'],
      notes: json['notes'],
      status: json['status'],
      voucherDate: json['voucherDate'] != null
          ? DateTime.parse(json['voucherDate'])
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
