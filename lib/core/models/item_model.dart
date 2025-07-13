class Item {
  int? id;
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

  Item({
    this.id,
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
  });

  Item copyWith({
    int? id,
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
  }) {
    return Item(
      id: id ?? this.id,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit_price': unitPrice,
      'gst_percentage': gstPercentage,
      'opening_stock': openingStock,
      'current_stock': currentStock,
      'low_stock_threshold': lowStockThreshold,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String?,
      category: map['category'] as String?,
      unitPrice: map['unit_price'] as double?,
      gstPercentage: map['gst_percentage'] as double?,
      openingStock: map['opening_stock'] as int?,
      currentStock: map['current_stock'] as int?,
      lowStockThreshold: map['low_stock_threshold'] as int?,
      description: map['description'] as String?,
      barcode: map['barcode'] as String?,
      sku: map['sku'] as String?,
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
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
