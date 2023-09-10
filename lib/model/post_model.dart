import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:miracle_study/model/comment_model.dart';

@immutable
class PostModel {
  final String username;
  final String? description;
  final List<String> picturesPath;
  final List<String> likes;
  final bool commentsEnabled;
  final bool likesVisible;
  final Timestamp when;

  const PostModel({required this.username, required this.description, required this.picturesPath, required this.likes, required this.likesVisible, required this.when, required this.commentsEnabled});

  PostModel.fromFirestore(Map<String, dynamic> map)
    : username = map["username"],
      description = map["description"],
      picturesPath = (map["picturesPath"] as List).map((item) => item as String).toList(),
      likes = (map["likes"] as List).map((item) => item as String).toList(),
      commentsEnabled = map["commentsEnabled"],
      likesVisible = map["likesVisible"],
      when = map["when"];

  Map<String, dynamic> toMap() => {
    "username": username,
    "description": description,
    "picturesPath": picturesPath,
    "likes": likes,
    "likesVisible": likesVisible,
    "when": when,
    "commentsEnabled": commentsEnabled
  };
}