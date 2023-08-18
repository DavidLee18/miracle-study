import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "E-mail"),
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
              FilledButton(
                onPressed: () {},
                child: Text("Login"),
                style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(500))),
              )
            ],
          ),
        )),
      );
}
