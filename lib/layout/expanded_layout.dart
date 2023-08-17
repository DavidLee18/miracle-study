import 'package:flutter/material.dart';
import 'package:miracle_study/post.dart';
import 'package:miracle_study/stories.dart';

class ExpandedLayout extends StatefulWidget {
  const ExpandedLayout({super.key});

  @override
  State<ExpandedLayout> createState() => _ExpandedLayoutState();
}

class _ExpandedLayoutState extends State<ExpandedLayout> {
  var _index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shadowColor: Theme.of(context).appBarTheme.shadowColor,
          title: const Text("Miracle Study"),
        ),
        body: Row(children: [
          NavigationRail(
            leading: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("Home")),
              NavigationRailDestination(
                  icon: Icon(Icons.search_outlined), label: Text("Search")),
              NavigationRailDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle),
                  label: Text("Account"))
            ],
            selectedIndex: _index,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (value) => setState(() => _index = value),
          ),
          const Spacer(),
          Center(
              child: SizedBox(
            width: 500,
            child: ListView.builder(itemBuilder: (c, i) {
              switch (i) {
                case 0:
                  return const Stories();
                default:
                  return const Post();
              }
            }),
          )),
          const Spacer()
        ]),
      );
}
