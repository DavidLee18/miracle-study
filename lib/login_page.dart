import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/pw_reset_bottom_sheet.dart';
import 'package:miracle_study/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Miracle Study",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "E-mail"),
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "값을 입력해 주세요";
                    } else if (!EmailValidator.validate(value)) {
                      return "올바른 e-mail을 입력해 주세요";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "비밀번호"),
                  keyboardType: TextInputType.visiblePassword,
                  controller: _pw,
                  validator: (value) => value == null || value.isEmpty
                      ? "비밀번호를 입력해 주세요"
                      : value.length < 6
                      ? "최소 6자리의 비밀번호를 입력해 주세요"
                      : null,
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: () async {
                    if (_form.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text, password: _pw.text);
                        // TODO: route to posts page
                      } on FirebaseAuthException catch (e) {
                        await showDialog(context: context, builder: (c) => AlertDialog(
                          content: Text(switch(e.code) {
                            "user-disabled" => "해당 사용자는 비활성화 상태입니다",
                            "user-not-found" => "이 e-mail을 사용하는 계정이 존재하지 않습니다",
                            "wrong-password" => "잘못된 비밀번호입니다",
                            _ => "알 수 없는 오류입니다"
                          }),
                          actions: [
                            TextButton(
                              child: const Text('확인'),
                              onPressed: () { Navigator.of(c).pop(); },
                            ),
                          ],
                        ));
                      }
                    }
                  },
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(500))),
                  child: const Text("로그인"),
                ),
                const SizedBox(height: 30),
                FilledButton.tonal(
                  onPressed: () => showModalBottomSheet(context: context, builder: (context) => const PasswordResetBottomSheet()),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size.fromWidth(500))),
                  child: const Text("비밀번호 재설정"),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("계정이 없으신가요?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => const SignupPage()));
                        },
                        child: const Text("회원가입하세요."))
                  ],
                )
              ],
            ),
          ),
        )),
      );
}
