class UserModel {
  final String id;
  final String role;

  UserModel({
    required this.id,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_user'],
      role: json['role'],
    );
  }
}
