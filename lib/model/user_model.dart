import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String username;
  final String? bio;
  final String uid;
  final String? profilePath;

  const UserModel({required this.username, this.bio, required this.uid, this.profilePath});

  UserModel.fromFirestore(this.username, Map<String, dynamic> map)
  : bio = map["bio"]
  , uid = map["uid"]
  , profilePath = map["profilePath"];

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "bio": bio,
    "profile": profilePath
  };
}