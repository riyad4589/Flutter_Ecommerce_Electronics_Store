import '../../domain/entities/user.dart';

class UserModel extends User {
  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String? token;
  @override
  final String? username;
  @override
  final String? profileImage;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.username,
    this.profileImage,
  }) : super(
          id: id,
          name: name,
          email: email,
          token: token,
          username: username,
          profileImage: profileImage,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      username: json['username'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'username': username,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      token: user.token,
      username: user.username,
      profileImage: user.profileImage,
    );
  }
}
