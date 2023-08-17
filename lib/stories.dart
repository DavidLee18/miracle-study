import 'package:flutter/material.dart';

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 120,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.filled(
            5,
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 55,
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/sulbing.jpeg')),
            ),
          )),
    );
  }
}
