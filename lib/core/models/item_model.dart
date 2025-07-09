import 'package:isar/isar.dart';

part 'item_model.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  String? name;
  String? category;
  double? unitPrice;
  double? gstPercentage;
  int? openingStock;
  int? currentStock;
  int? lowStockThreshold;
  String? description;
  String? barcode;
  String? sku;

  DateTime? createdAt;
  DateTime? updatedAt;

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId;

  Item({
    this.name,
    this.category,
    this.unitPrice,
    this.gstPercentage,
    this.openingStock,
    this.currentStock,
    this.lowStockThreshold,
    this.description,
    this.barcode,
    this.sku,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  Item copyWith({
    String? name,
    String? category,
    double? unitPrice,
    double? gstPercentage,
    int? openingStock,
    int? currentStock,
    int? lowStockThreshold,
    String? description,
    String? barcode,
    String? sku,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return Item(
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      openingStock: openingStock ?? this.openingStock,
      currentStock: currentStock ?? this.currentStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
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
      'name': name,
      'category': category,
      'unitPrice': unitPrice,
      'gstPercentage': gstPercentage,
      'openingStock': openingStock,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      category: json['category'],
      unitPrice: json['unitPrice']?.toDouble(),
      gstPercentage: json['gstPercentage']?.toDouble(),
      openingStock: json['openingStock'],
      currentStock: json['currentStock'],
      lowStockThreshold: json['lowStockThreshold'],
      description: json['description'],
      barcode: json['barcode'],
      sku: json['sku'],
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
