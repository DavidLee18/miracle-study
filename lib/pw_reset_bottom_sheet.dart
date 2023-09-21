import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/main.dart';

class PasswordResetBottomSheet extends StatefulWidget {
  const PasswordResetBottomSheet({super.key});

  @override
  State<PasswordResetBottomSheet> createState() => _PasswordResetBottomSheetState();
}

class _PasswordResetBottomSheetState extends State<PasswordResetBottomSheet> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Form(
      key: _form,
      child: Center(child: Column(
        children: [
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
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                try {
                  FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
                } on FirebaseAuthException catch (e) {
                  logger.e(e.message, error: e, stackTrace: e.stackTrace);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(switch(e.code) {
                      "email-invalid" => "잘못된 e-mail입니다",
                      "user-not-found" => "해당 e-mail의 계정이 존재하지 않습니다",
                      _ => "알 수 없는 오류입니다"
                    }))
                  );
                }
              }
            },
            style: ButtonStyle(
                fixedSize:
                    MaterialStateProperty.all(const Size.fromWidth(500))),
            child: const Text("로그인"),
          ),
        ],
      )),
    ),
  );
}