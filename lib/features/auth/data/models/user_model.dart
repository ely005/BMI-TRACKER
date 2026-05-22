import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bmi_tracker/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    final dynamic rawToken = json['token'] ?? userJson['token'];
    return UserModel(
      id: (userJson['id'] ?? json['id'] ?? '').toString(),
      name: (userJson['name'] ?? json['name'] ?? '').toString(),
      email: (userJson['email'] ?? json['email'] ?? '').toString(),
      token: rawToken?.toString(),
    );
  }

  factory UserModel.fromSupabaseUser(User user, {String? token}) {
    final Map<String, dynamic>? metadata = user.userMetadata;
    final String name = (metadata?['name'] ?? metadata?['full_name'] ?? '')
        .toString();
    return UserModel(
      id: user.id,
      name: name,
      email: user.email ?? '',
      token: token,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      token: entity.token,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
