import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  final String text;
  final String username;
  final Timestamp when;
  final List<String> likes;

  const CommentModel({required this.text, required this.username, required this.when, required this.likes});

  CommentModel.fromFirestore(Map<String, dynamic> map)
  : text = map["text"]
  , username = map["username"]
  , when = map["when"]
  , likes = (map["likes"] as List).map((item) => item as String).toList();

  Map<String, dynamic> toMap() => {
    "text": text,
    "username": username,
    "when": when,
    "likes": likes
  };
}