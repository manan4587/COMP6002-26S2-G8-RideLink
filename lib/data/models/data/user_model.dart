class User {
  User({
    this.id,
    this.name,
    this.mobileNumber,
    this.address,
    this.profileImage,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      address: json['address'] as String?,
    );
  }

  final String? id;
  final String? name;
  final String? mobileNumber;
  final String? address;
  final String? profileImage;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? token;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'address': address,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
      'token': token,
    };
  }
}
