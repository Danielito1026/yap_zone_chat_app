import 'dart:io';
import 'package:uuid/uuid.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String imageUrl;
  final File? image;
  final DateTime? lastActive;

  UserModel({
    String? uid,
    required this.name,
    required this.username,
    required this.email,
    required this.imageUrl,
    this.image,
    this.lastActive,
  }) : uid = uid ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'imageUrl': imageUrl,
      'lastActive': lastActive,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['username'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      lastActive: map['lastActive'] as DateTime? ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? imageUrl,
    File? image,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
