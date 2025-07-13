class User {
  int? id;
  String? email;
  String? name;
  String? role; // distributor or retail_client
  String? phone;
  String? address;
  String? companyName;
  String? gstNumber;
  String? panNumber;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.phone,
    this.address,
    this.companyName,
    this.gstNumber,
    this.panNumber,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? address,
    String? companyName,
    String? gstNumber,
    String? panNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'company_name': companyName,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String?,
      name: map['name'] as String?,
      role: map['role'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      companyName: map['company_name'] as String?,
      gstNumber: map['gst_number'] as String?,
      panNumber: map['pan_number'] as String?,
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
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'companyName': companyName,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      address: json['address'],
      companyName: json['companyName'],
      gstNumber: json['gstNumber'],
      panNumber: json['panNumber'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
