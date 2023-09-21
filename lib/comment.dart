import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miracle_study/model/comment_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Comment extends StatefulWidget {
  final String id;
  final String postId;
  final CommentModel model;
  const Comment({super.key, required this.id, required this.model, required this.postId});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  var _dateFormattable = false;
  Uint8List? _profilePicture;
  var _liked = false;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final profileData = await FirebaseStorage.instance.ref("profiles/${widget.model.username}").getData();
    if(mounted) { setState(() { _profilePicture = profileData; }); }
    final currentUser = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(mounted) {
      setState(() { _currentUsername = currentUser.docs.single.id; });
      setState(() { _liked = widget.model.likes.contains(_currentUsername); });
    }
    await initializeDateFormatting("ko_KR");
    if(mounted) { setState(() { _dateFormattable = true; }); }
  }

  void _setLike(bool like) async {
    if(_currentUsername != null){
      await FirebaseFirestore.instance
        .collection("posts").doc(widget.postId)
        .collection("comments").doc(widget.id)
        .update({ "likes": like ? (widget.model.likes..add(_currentUsername!)) : (widget.model.likes..remove(_currentUsername!)) });
      setState(() { _liked = like; });
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Skeletonizer(enabled: _profilePicture == null, child: CircleAvatar(radius: 16, backgroundImage: _profilePicture != null ? MemoryImage(_profilePicture!) : null,)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(widget.model.username, style: const TextStyle(fontWeight: FontWeight.bold))
          ),
          Skeletonizer(enabled: !_dateFormattable, child: Text(_dateFormattable ? DateFormat.MMMd("ko_KR").add_Hm().format(widget.model.when.toDate()) : "comment.when.toString()", style: const TextStyle(color: Colors.grey),))
        ]),
        Container(width: 300, padding: EdgeInsets.symmetric(horizontal: 8), child: Text(widget.model.text)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.model.likes.isNotEmpty ? Text("좋아요 ${widget.model.likes.length}개", style: const TextStyle(color: Colors.grey),) : Container(),
        )
      ]),
      IconButton(onPressed: () => _setLike(!_liked), icon: _liked ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_outline))
    ],
  );
}