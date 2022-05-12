import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Convention.Ninja',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingPage(),
          '/test': (context) => const PageWrapper(
              title: 'Convention.Ninja', navigation: {}, child: Text('test')),
          '/home': (context) => const MyHomePage(title: 'asdfasdf'),
        });
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(mainAxisSize: MainAxisSize.min, children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(25.0),
                  child: SizedBox(
                      width: 400,
                      child: TextField(
                          decoration: InputDecoration(
                        labelText: 'Username',
                      ))),
                )
              ]),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: SizedBox(
                        width: 400,
                        child: TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ))),
                  )
                ],
              ),
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(
                  width: 400,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () {}, child: const Text('Login')),
                    ),
                  ),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}

class PageWrapper extends StatelessWidget {
  const PageWrapper(
      {Key? key,
      required this.title,
      required this.navigation,
      required this.child})
      : super(key: key);

  final String title;
  final Map<String, Widget?> navigation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Row(children: <Widget>[
          NavigationRail(
            selectedIndex: 0,
            extended: true,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.close), label: Text('Other'))
            ],
          ),
          Column(children: const [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Expanded(child: Text('test 2')))
          ])
        ]));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Text('asdf');
  }
}
