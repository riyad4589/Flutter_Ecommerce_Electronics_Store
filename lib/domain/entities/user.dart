import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? token;
  final String? username;
  final String? profileImage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.username,
    this.profileImage,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? username,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  List<Object?> get props => [id, name, email, token, username, profileImage];
}
