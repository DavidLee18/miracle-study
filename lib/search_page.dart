import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/main.dart';
import 'package:miracle_study/model/post_model.dart';
import 'package:miracle_study/model/user_model.dart';
import 'package:miracle_study/profile_page.dart';
import 'package:miracle_study/single_post_page.dart';
import 'package:miracle_study/type/either.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchInput = TextEditingController();
  var _query = "";

  @override
  void initState() {
    super.initState();
    _searchInput.addListener(() => setState(() {
      _query = _searchInput.text;
    }));
  }

  @override
  Widget build(BuildContext context) => Column(children: [
      TextField(
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
        controller: _searchInput,
      ),
      Expanded(
        child: StreamBuilder(
          stream: Rx.zip2(
            FirebaseFirestore.instance.collection("posts").snapshots().map((c) => _query.trim().isEmpty ? c.docs : c.docs.where((d) => d.get("description")?.contains(_query) ?? false).toList()),
            FirebaseFirestore.instance.collection("users").snapshots().map((c) => _query.trim().isEmpty ? c.docs : c.docs.where((d) => d.id.contains(_query)).toList()),
            (p, u) => p.map((e) => Left<QueryDocumentSnapshot<Map<String, dynamic>>, QueryDocumentSnapshot<Map<String, dynamic>>>(e) as Either<QueryDocumentSnapshot<Map<String, dynamic>>, QueryDocumentSnapshot<Map<String, dynamic>>>).toList()
                      ..addAll(u.map((e) => Right(e)))
                      ..shuffle()
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.e(snapshot.error, error: snapshot.error);
              return Center(child: Text("${snapshot.error}"),);
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) => snapshot.hasData ? switch(snapshot.data![index]) {
                    Left(val: var p) => FutureBuilder(future: FirebaseStorage.instance.ref(PostModel.fromFirestore(p.data()).picturesPath[0]).getData(), builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        logger.e(snapshot.error, error: snapshot.error, stackTrace: snapshot.stackTrace);
                        return const Center(child: Icon(Icons.error_outline),);
                      } else {
                        return Skeletonizer(enabled: !snapshot.hasData, child: snapshot.hasData
                        ? GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePostPage(id: p.id, model: PostModel.fromFirestore(p.data()),))), child: AspectRatio(aspectRatio: 1, child: Image.memory(snapshot.data!)))
                        : AspectRatio(aspectRatio: 1, child: Image.asset("assets/sulbing.jpeg"),));
                      }
                    },),
                    Right(val: var u) => FutureBuilder(future: FirebaseStorage.instance.ref(u.get("profilePath")).getData(), builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        logger.e(snapshot.error, error: snapshot.error, stackTrace: snapshot.stackTrace);
                        return const Center(child: Icon(Icons.error_outline),);
                      } else {
                        return Skeletonizer(enabled: !snapshot.hasData, child: snapshot.hasData
                        ? GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Scaffold(appBar: AppBar(leading: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios)
                            ),), body: SafeArea(child: ProfilePage(username: u.id, image: snapshot.data!, model: UserModel.fromFirestore(u.id, u.data()),))))),
                            child: AspectRatio(aspectRatio: 1, child: CircleAvatar(backgroundImage: MemoryImage(snapshot.data!),))
                          )
                        : const AspectRatio(aspectRatio: 1, child: CircleAvatar(backgroundImage: AssetImage("assets/sulbing.jpeg"),),));
                      }
                    },)
                  } : Skeletonizer(enabled: true, child: AspectRatio(aspectRatio: 1, child: Image.asset("assets/sulbing.jpeg"),))
              );
            }
          }
        ),
      )
    ],);
}