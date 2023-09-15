import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miracle_study/firebase_options.dart';
import 'package:miracle_study/layout/compact_layout.dart';
import 'package:miracle_study/layout/expanded_layout.dart';
import 'package:miracle_study/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp(
    lightTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, brightness: Brightness.dark),
    ),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.lightTheme, required this.darkTheme});

  final ThemeData lightTheme;
  final ThemeData darkTheme;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.active: 
                if (snapshot.hasData) {
                  return LayoutBuilder(
                    builder: (context, constraints) => constraints.maxWidth > 600
                        ? const ExpandedLayout()
                        : const CompactLayout(),
                  );
                } else if(snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"),);
                } else {
                  return const LoginPage();
                }
              case ConnectionState.waiting: 
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor),);
              default: 
                return const LoginPage();
            } 
          }
        )
      );
}
