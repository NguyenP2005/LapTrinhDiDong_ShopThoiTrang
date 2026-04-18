class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String avatar;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.avatar,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      avatar: json['avatar'] ?? 'https://i.pravatar.cc/150',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'avatar': avatar,
    'role': role,
  };
}