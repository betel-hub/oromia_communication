class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String type;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.type = 'public_user',
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      type: json['type'] ?? 'public_user',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'type': type,
        'is_verified': isVerified,
      };

  User copyWith({bool? isVerified}) => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        type: type,
        isVerified: isVerified ?? this.isVerified,
      );
}