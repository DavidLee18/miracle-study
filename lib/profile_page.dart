import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/edit_profile_page.dart';
import 'package:miracle_study/main.dart';
import 'package:miracle_study/model/post_model.dart';
import 'package:miracle_study/model/user_model.dart';
import 'package:miracle_study/single_post_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  final Uint8List? image;
  final UserModel? model;
  const ProfilePage({super.key, this.username, this.image, this.model});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _username;
  Uint8List? _image;
  UserModel? _model;
  Future<AggregateQuerySnapshot>? _postsCount;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _posts;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) { return; }
    try {
      if (widget.username == null) {
        if (widget.model != null) {
          setState(() { _model = widget.model; });
          setState(() { _username = _model!.username; });
        } else {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final user = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: uid).get();
          setState(() { _username = user.docs.single.id; });
        }
      } else {
        setState(() { _username = widget.username; });
      }

      if (widget.model == null) {
        final data = await FirebaseFirestore.instance.collection("users").doc(_username).get();
        setState(() { _model = UserModel.fromFirestore(_username!, data.data()!); });
      } else {
        setState(() { _model = widget.model; });
      }

      if (widget.image == null) {
        final image = await FirebaseStorage.instance.ref("profiles/$_username").getData();
        setState(() { _image = image; });
      } else {
        setState(() { _image = widget.image; });
      }

      final postsQuery = FirebaseFirestore.instance.collection("posts").where("username", isEqualTo: _username);
      setState(() { _postsCount = postsQuery.count().get(); });
      setState(() { _posts = postsQuery.snapshots(); });
    } catch (e) {
      logger.e(e.toString(), error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: [
            SizedBox(width: 100, child: AspectRatio(aspectRatio: 1, child: Skeletonizer(enabled: _image == null, child: _image != null ? CircleAvatar(backgroundImage: MemoryImage(_image!)) : const CircleAvatar(backgroundImage: AssetImage("assets/sulbing.jpeg"))),)),
            Skeletonizer(enabled: _username == null, child: Text(_username ?? "username", style: const TextStyle(fontWeight: FontWeight.bold)))
          ],),
        ),
        _postsCount == null ? const Skeletonizer(enabled: true, child: Text("게시물 ?개", style: TextStyle(fontWeight: FontWeight.bold),))
        : FutureBuilder(future: _postsCount, builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e(snapshot.error, error: snapshot.error, stackTrace: snapshot.stackTrace);
            return Text("${snapshot.error}", style: const TextStyle(color: Colors.redAccent),);
          } else {
            return Skeletonizer(enabled: !snapshot.hasData, child: Text("게시물 ${snapshot.hasData ? snapshot.data!.count : "?"}개", style: const TextStyle(fontWeight: FontWeight.bold)));
          }
        },)
      ],),
      Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Skeletonizer(enabled: _model == null, child: Text(_model != null ? (_model!.bio ?? "") : "a sample description")),
        ),
        OutlinedButton(onPressed: _username == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(username: _username!, image: _image, model: _model,),)), child: const Text("프로필 수정"))
      ],),
      Expanded(
        child: StreamBuilder(
          stream: _posts,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.e(snapshot.error, error: snapshot.error, stackTrace: snapshot.stackTrace);
              return Center(child: Text("${snapshot.error}", style: const TextStyle(color: Colors.redAccent),),);
            } else {
              // snapshot.data!.docs.map((e) => PostModel.fromFirestore(e.data()));
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: snapshot.data?.size,
                itemBuilder: (context, index) {
                  if (!snapshot.hasData) {
                    return Skeletonizer(enabled: true, child: Image.asset("assets/sulbing.jpeg"));
                  } else {
                    final postId = snapshot.data!.docs[index].id;
                    final p = PostModel.fromFirestore(snapshot.data!.docs[index].data());
                    return FutureBuilder(
                      future: FirebaseStorage.instance.ref(p.picturesPath[0]).getData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          logger.e(snapshot.error, error: snapshot.error, stackTrace: snapshot.stackTrace);
                          return const Center(child: Icon(Icons.error_outline),);
                        } else {
                          return Skeletonizer(enabled: !snapshot.hasData, child: snapshot.hasData
                            ? GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePostPage(id: postId, model: p,))), child: AspectRatio(aspectRatio: 1, child: Image.memory(snapshot.data!)))
                            : AspectRatio(aspectRatio: 1, child: Image.asset("assets/sulbing.jpeg"),));
                        }
                      },
                    );
                  }
                },
              );
            }
          }
        ),
      )
    ],);
  }
}