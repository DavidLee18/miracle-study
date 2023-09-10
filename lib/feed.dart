import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/post.dart';

class Feed extends StatefulWidget {
  final String? username;
  const Feed({super.key, this.username});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late final Stream<QuerySnapshot<Map<String, dynamic>>> posts;

  @override
  void initState() {
    super.initState();
    posts = FirebaseFirestore.instance.collection("posts").where("username", isEqualTo: widget.username).snapshots();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(stream: posts, builder: (context, snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.active:
        if(snapshot.hasData) {
          return ConstrainedBox(constraints: const BoxConstraints.tightFor(height: 500), child: ListView.builder(itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) => Post(id: snapshot.data!.docs[index].id)));
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      default: return const Center(child: CircularProgressIndicator());
    }
  });
}