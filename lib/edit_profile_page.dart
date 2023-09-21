import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miracle_study/main.dart';
import 'package:miracle_study/model/user_model.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final Uint8List? image;
  final UserModel? model;
  const EditProfilePage({super.key, required this.username, this.image, this.model});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _username;
  var _bio = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _image;
  UserModel? _model;

  @override
  void initState() {
    super.initState();
    setState(() { _username = TextEditingController(text: widget.username); });
    _init();
  }

  Future<void> _init() async {

    if (widget.model == null) {
      final model = await FirebaseFirestore.instance.collection("users").doc(widget.username).get();
      if(mounted) { setState(() { _model = UserModel.fromFirestore(widget.username, model.data()!); }); }
    } else {
      if(mounted) { setState(() { _model = widget.model; }); }
    }

    if(mounted) { setState(() { _bio = TextEditingController(text: _model!.bio); }); }

    if (widget.image == null) {
      if (_model!.profilePath != null) {
        final image = await FirebaseStorage.instance.ref(_model!.profilePath!).getData();
        if(mounted) { setState(() { _image = image; }); }
      }
    } else {
      if(mounted) { setState(() { _image = widget.image; }); }
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if(image != null) {
        var data = await image.readAsBytes();
        if(mounted) { setState(() { _image = data; }); }
      } else { if(mounted) { setState(() { _image = null; }); } }
    } on PlatformException catch (e) {
      logger.e(e.message, error: e.details);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("이미지 선택이 실패했습니다. 다른 이미지를 골라 주세요")));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
      title: const Text("프로필 편집"),
    ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
                    Skeletonizer(
                      enabled: _image == null && (_model?.profilePath != null),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.amber,
                        backgroundImage: _image != null ? MemoryImage(_image!) : null,
                      ),
                    ),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: FloatingActionButton.small(
                            onPressed: _pickImage,
                            child: const Icon(Icons.add_a_photo_outlined)
                        )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "사용자 이름"),
                keyboardType: TextInputType.text,
                controller: _username,
                readOnly: true,
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "소개"),
                keyboardType: TextInputType.text,
                maxLines: 2,
                controller: _bio,
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () async {
                    final userData = FirebaseFirestore.instance.collection("users").doc(_username.text);
                    try {
                      String? profilePath;
                      if (_image != null) {
                        final ref = FirebaseStorage.instance.ref("profiles/${_username.text}");
                        await ref.putData(_image!, SettableMetadata());
                        profilePath = ref.fullPath;
                      }

                      userData.update({
                        "bio": _bio.text,
                        "profilePath": profilePath
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("회원가입이 완료되었습니다. 로그인해 주세요")));
                    } catch(e) {
                      logger.e(e, error: e);
                    }
                },
                style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all(const Size.fromWidth(500))),
                child: const Text("수정하기"),
              ),
              const SizedBox(height: 30),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all(const Size.fromWidth(500))),
                child: const Text("취소"),
              ),
            ],
          ),
        ),
      );
}
