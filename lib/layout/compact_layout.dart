import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/add_post_page.dart';
import 'package:miracle_study/feed.dart';
import 'package:miracle_study/profile_page.dart';
import 'package:miracle_study/search_page.dart';
import 'package:miracle_study/stories.dart';

class CompactLayout extends StatefulWidget {
  const CompactLayout({super.key});

  @override
  State<CompactLayout> createState() => _CompactLayoutState();
}

class _CompactLayoutState extends State<CompactLayout> {
  var _index = 0;

  final pages = [
      Column(children: [
            AppBar(title: const Text("Miracle Study")),
            const Stories(),
            const Feed()
            ]
      ),
      const SearchPage(),
      const ProfilePage()
    ];
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _index != 2 ? null : AppBar(actions: [ Tooltip(message: "로그아웃", child: IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout_outlined))) ],),
    body: SafeArea(child: pages[_index]),
    bottomNavigationBar: NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home), label: "홈"),
        NavigationDestination(icon: Icon(Icons.search), label: "검색"),
        NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "프로필")
      ],
      selectedIndex: _index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (value) => setState(() => _index = value),
    ),
    floatingActionButton: _index == 0 || _index == 2 ? FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPostPage())),
      child: const Icon(Icons.add),
    ) : null,
  );
}
