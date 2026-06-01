import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      'image': imageUrl,
      'last_active': lastActive,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    // Handle Timestamp conversion
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      // If it's a Firestore Timestamp object
      if (value is Timestamp) return value.toDate();
      // If it's a Map (rare case)
      if (value is Map) {
        return DateTime.fromMillisecondsSinceEpoch(
          (value['seconds'] ?? 0) * 1000 +
              (value['nanoseconds'] ?? 0) ~/ 1000000,
        );
      }
      return null;
    }

    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      imageUrl: map['image'] as String? ?? '',
      lastActive: parseTimestamp(map['last_active']) ?? DateTime.now(),
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
