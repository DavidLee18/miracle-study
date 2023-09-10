import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miracle_study/model/post_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Post extends StatefulWidget {
  final String id;
  const Post({super.key, required this.id});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  Uint8List? _profile;
  List<Uint8List> _postPictures = [];
  var _currentPage = 0;
  final _imagePages = PageController();
  String? _currentUsername;
  PostModel? _postSnapshot;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _post;
  var _liked = false;
  var _dateFormattable = false;


  @override
  void initState() {
    super.initState();
    _post = FirebaseFirestore.instance.collection("posts").doc(widget.id).snapshots();
    _init();
  }

  void _init() async {
    final rawData = await FirebaseFirestore.instance.collection("posts").doc(widget.id).get();
    _postSnapshot = PostModel.fromFirestore(rawData.data()!);
    final profileData = await FirebaseStorage.instance.ref("profiles/${_postSnapshot!.username}").getData();
    setState(() { _profile = profileData; });
    for (var ref in (await FirebaseStorage.instance.ref("posts/${widget.id}").listAll()).items) {
      var data = await ref.getData();
      setState(() { _postPictures.add(data!); });
    }
    final currentUser = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    setState(() { _currentUsername = currentUser.docs.single.id; });
    setState(() { _liked = _postSnapshot!.likes.contains(_currentUsername); });
    await initializeDateFormatting("ko_KR");
    setState(() { _dateFormattable = true; });
  }

  void _like() async {
    if(!_liked) {
      var likes = (await FirebaseFirestore.instance.collection("posts").doc(widget.id).get()).get("likes");
      await FirebaseFirestore.instance.collection("posts").doc(widget.id).update({ "likes": likes ..add(_currentUsername) });
      setState(() { _liked = true; });
    }
  }

  void _toggleLike() async {
    if(!_liked) {
      List likes = (await FirebaseFirestore.instance.collection("posts").doc(widget.id).get()).get("likes");
      await FirebaseFirestore.instance.collection("posts").doc(widget.id).update({ "likes": likes ..add(_currentUsername!) });
      setState(() { _liked = true; });
    } else {
      List likes = (await FirebaseFirestore.instance.collection("posts").doc(widget.id).get()).get("likes");
      await FirebaseFirestore.instance.collection("posts").doc(widget.id).update({ "likes": likes..remove(_currentUsername!)  });
      setState(() { _liked = false; });
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: _post,
    builder: (context, snapshot) {
      final post = snapshot.hasData ? PostModel.fromFirestore(snapshot.data!.data()!) : null;
        if(snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"),);
        } else {
              return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Skeletonizer(enabled: _profile == null, child: CircleAvatar(radius: 8, backgroundImage: _profile != null ? MemoryImage(_profile!) : null,)),
                const Spacer(),
                Skeletonizer(
                  enabled: post == null,
                  child: Text(
                    post?.username ?? "dummy",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(flex: 50)
              ],
            ),
            Skeletonizer(
              enabled: _postPictures.isEmpty,
              child: GestureDetector(onDoubleTap: _like, child: _postPictures.isEmpty || _postPictures.length == 1 ? AspectRatio(aspectRatio: 1.0, child: _postPictures.isNotEmpty ? Image.memory(_postPictures[0]) : Image.asset("assets/sulbing.jpeg"))
                                                                                                                   : ConstrainedBox(constraints: const BoxConstraints.tightForFinite(),
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        AspectRatio(
                                                                                          aspectRatio: 1.0,
                                                                                          child: PageView(controller: _imagePages,
                                                                                          children: _postPictures.map((d) => Image.memory(d)).toList(),
                                                                                          onPageChanged: (value) => setState(() { _currentPage = value; }),
                                                                                          ),
                                                                                        ),
                                                                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: _postPictures.indexed.map((t) => Padding(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                                                                          child: CircleAvatar(radius: 3, backgroundColor: _currentPage == t.$1 ? Theme.of(context).highlightColor : Theme.of(context).unselectedWidgetColor,),
                                                                                        )).toList())
                                                                                      ]
                                                                                    ),
                                                                                  )),
            ),
            Row(
              children: [
                IconButton(onPressed: _toggleLike, icon: _liked ? const Icon(Icons.favorite)
                                                                : const Icon(Icons.favorite_outline), color: _liked ? Colors.red : null,),
                const Spacer(),
                IconButton(onPressed: (post?.commentsEnabled ?? false) ? () {} : null, icon: const Icon(Icons.comment_outlined)),
                const Spacer(flex: 20)
              ],
            ),
            (post?.likes.isNotEmpty ?? true) ? Skeletonizer(enabled: post == null, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(post != null ? "좋아요 ${post.likes.length}개" : "좋아요 ?개")))
                                             : Container(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Skeletonizer(enabled: post == null, child: Text(post?.username ?? "dummy", style: const TextStyle(fontWeight: FontWeight.bold),)),
                ),
                Skeletonizer(enabled: post == null || post.description == null, child: Text(post?.description ?? "dummy description")),
              ],
            ),
            const Divider(),
            Skeletonizer(enabled: !_dateFormattable || post == null, child: Text(_dateFormattable && post != null ? DateFormat.yMMMMd("ko_KR").add_Hm().format(post.when.toDate()) : "post.when.toString()", style: const TextStyle(color: Colors.grey),))
          ],
        );
        }
      }
  );
}
