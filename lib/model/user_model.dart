import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String username;
  final String? bio;
  final String uid;
  final String? profilePath;

  const UserModel({required this.username, required this.bio, required this.uid, required this.profilePath});

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "bio": bio,
    "profile": profilePath
  };
}