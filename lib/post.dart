import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_circle),
              Spacer(),
              Text(
                "djwodus",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(
                flex: 50,
              )
            ],
          ),
          AspectRatio(
              aspectRatio: 1.0,
              child: Image.asset(
                "assets/sulbing.jpeg",
                fit: BoxFit.cover,
              )),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline)),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.comment_outlined)),
              Spacer(
                flex: 20,
              )
            ],
          ),
          const Text("친구들과 설빙"),
          const Divider()
        ],
      );
}
