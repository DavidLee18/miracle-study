import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miracle_study/comments.dart';
import 'package:miracle_study/like_animation.dart';
import 'package:miracle_study/model/comment_model.dart';
import 'package:miracle_study/model/post_model.dart';
import 'package:miracle_study/simple_comment.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Post extends StatefulWidget {
  final String id;
  final PostModel model;
  const Post({super.key, required this.id, required this.model});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  Uint8List? _profilePicture;
  final List<Uint8List> _postPictures = [];
  var _currentPage = 0;
  final _imagePages = PageController();
  String? _currentUsername;
  var _liked = false;
  var _dateFormattable = false;
  var _isLikeAnimating = false;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _comments;


  @override
  void initState() {
    super.initState();
    _comments = FirebaseFirestore.instance.collection("posts").doc(widget.id).collection("comments").limit(3).snapshots();
    _init();
  }

  void _init() async {
    final profileData = await FirebaseStorage.instance.ref("profiles/${widget.model.username}").getData();
    if(mounted) { setState(() { _profilePicture = profileData; }); }
    for (var ref in (await FirebaseStorage.instance.ref("posts/${widget.id}").listAll()).items) {
      var data = await ref.getData();
      if(mounted) { setState(() { _postPictures.add(data!); }); }
    }
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
      await FirebaseFirestore.instance.collection("posts").doc(widget.id).update({ "likes": like ? (widget.model.likes..add(_currentUsername!)) : (widget.model.likes..remove(_currentUsername!)) });
      setState(() { _liked = like; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Skeletonizer(enabled: _profilePicture == null, child: CircleAvatar(radius: 12, backgroundImage: _profilePicture != null ? MemoryImage(_profilePicture!) : null,)),
                const Spacer(),
                Text(
                  widget.model.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(flex: 50)
              ],
            ),
            GestureDetector(
              onDoubleTap: () {
                _setLike(true);
                setState(() { _isLikeAnimating = true; });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Skeletonizer(
                    enabled: _postPictures.isEmpty,
                    child: _postPictures.isEmpty || _postPictures.length == 1
                      ? AspectRatio(aspectRatio: 1.0, child: _postPictures.isNotEmpty ? Image.memory(_postPictures[0]) : Image.asset("assets/sulbing.jpeg"))
                      : ConstrainedBox(
                          constraints: const BoxConstraints.tightForFinite(),
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
                        ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      child: const Icon(Icons.favorite, color: Colors.red, size: 120,),
                      isAnimating: _isLikeAnimating,
                      duration: const Duration(milliseconds: 400),
                      onEnd: () => setState(() {
                        _isLikeAnimating = false;
                      }),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                LikeAnimation(
                  isAnimating: _liked,
                  smallLike: true,
                  child: IconButton(onPressed: () => _setLike(!_liked), icon: _liked ? const Icon(Icons.favorite)
                                                                  : const Icon(Icons.favorite_outline), color: _liked ? Colors.red : null,),
                ),
                const Spacer(),
                IconButton(onPressed: widget.model.commentsEnabled ? () => showModalBottomSheet(context: context, builder: (context) => Comments(postId: widget.id)) : null, icon: const Icon(Icons.comment_outlined)),
                const Spacer(flex: 20)
              ],
            ),
            widget.model.likes.isNotEmpty && widget.model.likesVisible ? Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("좋아요 ${widget.model.likes.length}개"))
                                             : Container(),
            widget.model.description != null ? SimpleComment(model: CommentModel(text: widget.model.description!, username: widget.model.username, when: Timestamp.now(), likes: const []), postId: widget.id,) : Container(),
            const Divider(),
            StreamBuilder(stream: _comments, builder: (context, snapshot) {
              if(snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                final comments = snapshot.data?.docs.map((d) => CommentModel.fromFirestore(d.data())).toList();
                List<Widget> children = comments?.indexed.map((c) => SimpleComment(model: c.$2, likable: true, id: snapshot.data?.docs[c.$1].id, postId: widget.id,) as Widget).toList() ?? [];
                if(comments?.isNotEmpty ?? false) {
                  children.add(Skeletonizer(enabled: comments == null, child: TextButton(
                  onPressed: () => showModalBottomSheet(context: context, builder: (context) => Comments(postId: widget.id)),
                  child: Text(comments != null ? "댓글 ${comments.length}개 모두 보기" : "댓글 ?개 모두 보기")
                  )));
                }
                return Skeletonizer(enabled: !snapshot.hasData, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)
            );
              }
            }),
            Skeletonizer(enabled: !_dateFormattable, child: Text(_dateFormattable ? DateFormat.MMMd("ko_KR").add_Hm().format(widget.model.when.toDate()) : "post.when.toString()", style: const TextStyle(color: Colors.grey),)),
          ],
        );
  }
}
