class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  final String id;
  final String name;
  final String email;
  final String? token;
}
