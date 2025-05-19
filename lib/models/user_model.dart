class User {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin' atau 'customer'
  final String? token; // Untuk autentikasi
  final String? refreshToken; // Optional, if you want to handle refresh tokens

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Convert int to String for id
      id: json['id'], // This handles both int and string IDs
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'customer', // Default role
      token: json['token'], // This might be null for registration
      refreshToken: json['refreshToken'], // Optional
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'token': token,
        'refreshToken': refreshToken,
      };
}
