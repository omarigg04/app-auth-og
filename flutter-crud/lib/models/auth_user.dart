class AuthUser {
  final int id;
  final String email;
  final String userName;
  final String createdAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.userName,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      userName: json['user_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_name': userName,
      'created_at': createdAt,
    };
  }
}