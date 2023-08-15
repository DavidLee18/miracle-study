import 'package:flutter/material.dart';
import 'package:miracle_study/layout/compact_layout.dart';
import 'package:miracle_study/layout/expanded_layout.dart';

void main() {
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
      home: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 600
            ? const ExpandedLayout()
            : const CompactLayout(),
      ));
}
