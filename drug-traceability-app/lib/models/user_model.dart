import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final String token;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'public',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
    };
  }

  String getRoleDisplayName() {
    switch (role) {
      case 'admin':
        return '超级管理员';
      case 'regulator':
        return '监管人员';
      case 'enterprise':
        return '企业用户';
      case 'institution':
        return '医疗机构';
      case 'public':
        return '公众用户';
      default:
        return '未知角色';
    }
  }

  bool isAdmin() => role == 'admin';
  bool isRegulator() => role == 'regulator';
  bool isEnterprise() => role == 'enterprise';
  bool isInstitution() => role == 'institution';
  bool isPublic() => role == 'public';
}
