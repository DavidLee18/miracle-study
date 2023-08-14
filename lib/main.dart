import 'package:flutter/material.dart';

void main() => runApp(MainApp(
      lightTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
    ));

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.lightTheme, required this.darkTheme});

  final ThemeData lightTheme;
  final ThemeData darkTheme;

  @override
  _MainAppState createState() => _MainAppState(lightTheme, darkTheme);
}

class _MainAppState extends State<MainApp> {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  ThemeData get currentTheme => _light ? lightTheme : darkTheme;
  bool _light = true;

  _MainAppState(this.lightTheme, this.darkTheme);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _light ? ThemeMode.light : ThemeMode.dark,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: currentTheme.appBarTheme.backgroundColor,
            foregroundColor: currentTheme.appBarTheme.foregroundColor,
            shadowColor: currentTheme.appBarTheme.shadowColor,
            title: const Text(
              "미라클 스터디",
            ),
          ),
          body: Row(children: [
            NavigationRail(
              elevation: 5,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle),
                    label: Text("이재현")),
                NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    label: Text("이현지")),
              ],
              selectedIndex: 0,
              trailing: IconButton(
                  onPressed: () => setState(() {
                        _light = !_light;
                      }),
                  icon: Icon(_light
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined)),
            ),
            const Center(
              child: Text("Hello World!"),
            )
          ]),
        ),
      );
}
