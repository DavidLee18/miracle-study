import 'package:flutter/foundation.dart';

@immutable
class CommentModel {
  final String text;
  final List<String> likes;
  final List<CommentModel> replies;

  const CommentModel({required this.text, required this.likes, required this.replies});
}