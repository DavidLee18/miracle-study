import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miracle_study/model/post_model.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<XFile> _images = [];
  List<Uint8List> _datas = [];
  final _description = TextEditingController();
  final _picker = ImagePicker();
  final _imagePages = PageController();
  var _commentsEnabled = true;
  var _likesVisible = true;
  var _currentPage = 0;
  var _loading = false;

  Future<void> _pickImages() async {
    try {
      var images = await _picker.pickMultiImage();
      setState(() { _images = images; });
      if(images.isEmpty) { setState(() { _datas = []; }); } else {
        _datas = [];
        for (var image in images) {
          var data = await image.readAsBytes();
          setState(() { _datas.add(data); });
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      title: const Text("새 게시물"),
      actions: [
        TextButton(onPressed: _datas.isEmpty ? null : () async {
          setState(() { _loading = true; });
          final uid = FirebaseAuth.instance.currentUser!.uid;
          final user = FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: uid);
          final model = PostModel(
            username: (await user.get()).docs.single.id,
            description: _description.text.trim().isEmpty ? null : _description.text,
            picturesPath: const [],
            likes: const [],
            commentsEnabled: _commentsEnabled,
            likesVisible: _likesVisible,
            when: Timestamp.now()
          );
          final docRef = await FirebaseFirestore.instance.collection("posts").add(model.toMap());
          final ref = FirebaseStorage.instance.ref("posts/${docRef.id}");
          List<String> pathes = [];
          for (var i = 0; i < _datas.length; i++) {
            final childRef = ref.child("$i");
            await childRef.putData(_datas[i]);
            pathes.add(childRef.fullPath);
          }
          await docRef.update({ "picturesPath": pathes });
          Navigator.pop(context);
        }, child: const Text("게시"))
      ],
    ),
    body: SafeArea(child: ListView(padding: const EdgeInsets.symmetric(vertical: 30), children: [
      _loading ? const LinearProgressIndicator() : Container(),
      _datas.length == 1 ? GestureDetector(onTap: _pickImages, child: AspectRatio(aspectRatio: 1.0, child: Image.memory(_datas[0])),)
                         : _datas.isEmpty ? IconButton(onPressed: _pickImages, icon: const Icon(Icons.add_a_photo_outlined))
                                          : GestureDetector(onLongPress: _pickImages, child: ConstrainedBox(
                                            constraints: const BoxConstraints.tightForFinite(),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1.0,
                                                  child: PageView(controller: _imagePages,
                                                  children: _datas.map((d) => Image.memory(d)).toList(),
                                                  onPageChanged: (value) => setState(() { _currentPage = value; }),
                                                  ),
                                                ),
                                                Row(mainAxisAlignment: MainAxisAlignment.center, children: _datas.indexed.map((t) => Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                                  child: CircleAvatar(radius: 3, backgroundColor: _currentPage == t.$1 ? Theme.of(context).highlightColor : Theme.of(context).unselectedWidgetColor,),
                                                )).toList())
                                              ]
                                            ),
                                          )),
      Container(
        width: 500,
        padding: const EdgeInsets.all(8),
        child: TextFormField(decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "문구 입력..."),
          maxLength: 60, maxLines: 2, controller: _description, enabled: _datas.isNotEmpty,
        ),),
        SwitchListTile(value: _commentsEnabled, onChanged: _images.isEmpty ? null : (value) => setState(() { _commentsEnabled = value; }), title: const Text("댓글창"),),
        SwitchListTile(value: _likesVisible, onChanged: _images.isEmpty ? null : (value) => setState(() { _likesVisible = value; }), title: const Text("좋아요 수 공개"),),
    ],)),
  );
}