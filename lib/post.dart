import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          AspectRatio(
              aspectRatio: 1.0,
              child: Image.asset(
                "assets/sulbing.jpeg",
                fit: BoxFit.cover,
              )),
          const Text("친구들과 설빙")
        ],
      );
}
