import 'package:flutter/material.dart';
import 'package:miracle_study/add_post_page.dart';
import 'package:miracle_study/feed.dart';
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
      const Text("search"),
      const Text("notifications"),
      const Text("profile")
    ];
  
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: pages[_index]),
    bottomNavigationBar: NavigationBar(
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home), label: "홈"),
        NavigationDestination(icon: Icon(Icons.search), label: "검색"),
        NavigationDestination(icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications), label: "알림"),
        NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "프로필")
      ],
      selectedIndex: _index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (value) => setState(() => _index = value),
    ),
    floatingActionButton: _index == 0 || _index == 3 ? FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPostPage())),
      child: const Icon(Icons.add),
    ) : null,
  );
}
