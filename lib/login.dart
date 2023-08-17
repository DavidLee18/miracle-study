import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
