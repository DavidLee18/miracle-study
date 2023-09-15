import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/model/comment_model.dart';

class SimpleComment extends StatefulWidget {
  final CommentModel model;
  final bool likable;
  final String? id;
  final String postId;
  const SimpleComment({super.key, required this.model, this.likable = false, this.id, required this.postId});

  @override
  State<SimpleComment> createState() => _SimpleCommentState();
}

class _SimpleCommentState extends State<SimpleComment> {
  var _liked = false;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final currentUser = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(mounted) {
      setState(() { _currentUsername = currentUser.docs.single.id; });
      setState(() { _liked = widget.model.likes.contains(_currentUsername); });
    }
  }

  void _setLike(bool like) async {
    if(_currentUsername != null){
      await FirebaseFirestore.instance.collection("posts").doc(widget.postId).collection("comments").doc(widget.id).update({ "likes": like ? (widget.model.likes..add(_currentUsername!)) : (widget.model.likes..remove(_currentUsername!)) });
      setState(() { _liked = like; });
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(widget.model.username, style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
                Text(widget.model.text),
              ];
    if(widget.likable) {
      children.add(const Spacer());
      children.add(IconButton(onPressed: () => _setLike(!_liked), icon: _liked ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_outline)));
    }
    return Row(
              children: children,
            );
  }
}