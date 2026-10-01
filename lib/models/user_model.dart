enum UserRole {
  admin,
  audience;

  static UserRole fromString(String? role) {
    if (role?.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.audience;
  }

  String get value => name;
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin;
  bool get isAudience => role == UserRole.audience;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
