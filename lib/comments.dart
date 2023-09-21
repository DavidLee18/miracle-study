import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/comment.dart';
import 'package:miracle_study/model/comment_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Comments extends StatefulWidget {
  final String postId;
  const Comments({super.key, required this.postId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _comments;
  Uint8List? _currentProfile;
  final _input = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _comments = FirebaseFirestore.instance.collection("posts").doc(widget.postId).collection("comments").orderBy("when").snapshots();
    _init();
  }

  void _init() async {
    final currentUsername = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    final ref = await FirebaseStorage.instance.ref("profiles/${currentUsername.docs.single.id}").getData();
    if(mounted) { setState(() { _currentProfile = ref; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: StreamBuilder(stream: _comments, builder: (context, snapshot) {
      if(snapshot.hasError) {
        return Center(child: Text("${snapshot.error}"),);
      } else {
        return Skeletonizer(
          enabled: !snapshot.hasData,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data?.size ?? 5,
            itemBuilder: (context, index) => snapshot.hasData ? Comment(
              id: snapshot.data!.docs[index].id,
              postId: widget.postId,
              model: CommentModel.fromFirestore(snapshot.data!.docs[index].data())
            ) : const Row(
      children: [
        Expanded(child: Skeletonizer(enabled: true, child: CircleAvatar(radius: 8))),
        Column(children: [
          Row(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("username", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Skeletonizer(enabled: true, child: Text("comment.when.toString()", style: TextStyle(color: Colors.grey),))
          ]),
          Text("widget.model.text"),
          Row(children: [
            Text("좋아요 ??개", style: TextStyle(color: Colors.grey),),
            TextButton(onPressed: null, child: Text("답글 달기"))
          ])
        ]),
        IconButton(onPressed: null, icon: Icon(Icons.favorite_outline))
      ],
    )
          )
        );
      }
    }),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Skeletonizer(enabled: _currentProfile == null, child: CircleAvatar(radius: 16, backgroundImage: _currentProfile != null ? MemoryImage(_currentProfile!) : null,)),
          ),
          Expanded(
            child: Form(
              key: _key,
              child: TextFormField(
                controller: _input,
                validator: (value) => value == null || value.isEmpty ? "댓글을 입력하세요" : null,
                maxLength: 60,
                maxLines: 3,
                decoration: InputDecoration(border: const OutlineInputBorder(), suffix: IconButton(onPressed: () async {
                  if (_key.currentState!.validate()) {
                    final currentUsername = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
                    await FirebaseFirestore.instance
                      .collection("posts").doc(widget.postId)
                      .collection("comments").add(
                      CommentModel(text: _input.text, username: currentUsername.docs.single.id, when: Timestamp.now(), likes: const []).toMap()
                    );
                    _key.currentState!.reset();
                  }
                }, icon: const Icon(Icons.send_outlined))),
              ),
            ),
          )
        ]),
      ),
    ),
    );
  }
}