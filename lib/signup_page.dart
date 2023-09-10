import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miracle_study/model/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pwAgain = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  final _picker = ImagePicker();
  XFile? _profile;
  Uint8List? _data;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _pwAgain.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() { _profile = image; });
      if(image != null) {
        var data = await image.readAsBytes();
        setState(() { _data = data; });
      } else { setState(() { _data = null; }); }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              children: [
                const Center(
                  child: Text(
                    "Miracle Study에 어서 오세요",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.amber,
                        child: _data != null ? Image.memory(_data!) : null,
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
                      border: OutlineInputBorder(),
                      labelText: "E-mail*",
                    ),
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "값을 입력해 주세요";
                    } else if (!EmailValidator.validate(value)) {
                      return "올바른 e-mail을 입력해 주세요";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "비밀번호*"),
                  keyboardType: TextInputType.visiblePassword,
                  controller: _pw,
                  validator: (value) => value == null || value.isEmpty
                      ? "비밀번호를 입력해 주세요"
                      : value.length < 6
                      ? "최소 6자리의 비밀번호를 입력해 주세요"
                      : null,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "비밀번호 확인*"),
                  keyboardType: TextInputType.visiblePassword,
                  controller: _pwAgain,
                  validator: (value) => value == null || value != _pw.text
                      ? "비밀번호가 일치하지 않습니다"
                      : null,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "사용자 이름*"),
                  keyboardType: TextInputType.text,
                  controller: _username,
                  validator: (value) =>
                      value == null || value.isEmpty ? "값을 입력해 주세요" : null,
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
                    if (_form.currentState!.validate()) {
                      final userData = FirebaseFirestore.instance.collection("users").doc(_username.text);
                      final userSnapshot = await userData.get();
                      if(userSnapshot.exists) {
                        await showDialog(context: context, builder: (c) => AlertDialog(
                          content: const Text("해당 사용자 이름은 이미 존재합니다. 다른 이름을 사용해 주세요"),
                          actions: [
                            TextButton(
                              child: const Text('확인'),
                              onPressed: () { Navigator.of(c).pop(); },
                            ),
                          ],
                        ));
                      }
                      else {
                        try {
                          final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _pw.text);
                          String? profilePath;
                          if (_data != null) {
                            final ref = FirebaseStorage.instance.ref("profiles/${_username.text}");
                            await ref.putData(_data!);
                            profilePath = ref.fullPath;
                          }
                          final model = UserModel(username: _username.text, bio: _bio.text, uid: user.user!.uid, profilePath: profilePath);
                          await userData.set(model.toMap());

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("회원가입이 완료되었습니다. 로그인해 주세요")));
                        } on FirebaseAuthException catch(e) {
                          await showDialog(context: context, builder: (c) => AlertDialog(
                            content: Text(switch (e.code) {
                              "email-already-in-use" => "이미 사용중인 e-mail입니다. 다른 e-mail을 사용해 주세요",
                              _ => e.code,
                            }),
                            actions: [
                              TextButton(
                                child: const Text('확인'),
                                onPressed: () { Navigator.of(c).pop(); },
                              ),
                            ],
                          ));
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(500))),
                  child: const Text("회원가입"),
                ),
                const SizedBox(height: 30),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(500))),
                  child: const Text("취소"),
                ),
              ],
            ),
          ),
        ),
      );
}
