import 'package:flutter/material.dart';
import 'package:miracle_study/model/post_model.dart';
import 'package:miracle_study/post.dart';

class SinglePostPage extends StatelessWidget {
  final String id;
  final PostModel model;
  const SinglePostPage({super.key, required this.id, required this.model});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios)
      ),
    ),
    body: SingleChildScrollView(child: Post(id: id, model: model)),
  );
}