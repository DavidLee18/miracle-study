import 'package:flutter/material.dart';
import 'package:miracle_study/post.dart';
import 'package:miracle_study/stories.dart';

class CompactLayout extends StatefulWidget {
  const CompactLayout({super.key});

  @override
  State<CompactLayout> createState() => _CompactLayoutState();
}

class _CompactLayoutState extends State<CompactLayout> {
  var _index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: ListView.builder(
          itemBuilder: (c, i) {
            switch (i) {
              case 0:
                return AppBar(
                  foregroundColor:
                      Theme.of(context).appBarTheme.foregroundColor,
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  shadowColor: Theme.of(context).appBarTheme.shadowColor,
                  title: const Text("Miracle Study"),
                );
              case 1:
                return const Stories();
              default:
                return const Post();
            }
          },
        )),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.search), label: "Search"),
            NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(Icons.account_circle),
                label: "Account")
          ],
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (value) => setState(() => _index = value),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );
}
