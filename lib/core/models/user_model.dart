import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
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

  // Sync fields
  String? syncStatus;
  DateTime? lastSyncedAt;
  String? cloudId; // Supabase user ID

  User({
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
    this.syncStatus,
    this.lastSyncedAt,
    this.cloudId,
  });

  User copyWith({
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
    String? syncStatus,
    DateTime? lastSyncedAt,
    String? cloudId,
  }) {
    return User(
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
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cloudId: cloudId ?? this.cloudId,
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
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'cloudId': cloudId,
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
