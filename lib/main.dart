import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:convention_ninja/services/user_service.dart' as us;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'locations/home_location.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamController<bool> _userLoader;

  final routerDelegate = BeamerDelegate(
    transitionDelegate: const NoAnimationTransitionDelegate(),
    locationBuilder: (routeInformation, _) => HomeLocation(routeInformation),
  );

  @override
  void initState() {
    super.initState();
    _userLoader = StreamController<bool>(onListen: () async {
      final user = await us.UserService.me();
      if (user == null) {
        _userLoader.add(false);
      } else {
        _userLoader.add(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: Text('loading...', textDirection: TextDirection.ltr,));
          }
          return StreamBuilder<bool>(
              stream: _userLoader.stream,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('loading...', textDirection: TextDirection.ltr));
                }
                return MaterialApp.router(
                  routeInformationParser: BeamerParser(),
                  routerDelegate: routerDelegate,
                  debugShowCheckedModeBanner: false,
                  title: 'Convention.Ninja',
                  /*darkTheme: ThemeData.from(
                      colorScheme: ColorScheme.dark(),*//*fromSwatch(
                          primarySwatch: Colors.deepOrange,
                          brightness: Brightness.dark),*//*
                      useMaterial3: true),
                  themeMode: ThemeMode.dark,*/
                );
              });
        });
  }
}
