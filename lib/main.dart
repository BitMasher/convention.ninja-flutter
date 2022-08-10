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

class _UserValue {
  final User? firebaseUser;
  final us.User? cnUser;
  final bool loading;

  _UserValue({required this.loading, this.firebaseUser, this.cnUser});

  @override
  String toString() {
    return '_UserValue{firebaseUser: $firebaseUser, cnUser: $cnUser, loading: $loading}';
  }
}

class MyAppState extends State<MyApp> {
  final GlobalKey _listenerKey = GlobalKey();
  late StreamController<bool> _userLoader;
  final ValueNotifier<_UserValue> _authNotifier =
      ValueNotifier<_UserValue>(_UserValue(loading: true));

  final routerDelegate = BeamerDelegate(
    transitionDelegate: const NoAnimationTransitionDelegate(),
    locationBuilder: (routeInformation, _) => HomeLocation(routeInformation),
  );

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
      if (fbUser != null) {
        final cnUser = await us.UserService.me();
        _authNotifier.value =
            _UserValue(loading: false, firebaseUser: fbUser, cnUser: cnUser);
      } else {
        _authNotifier.value = _UserValue(loading: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return ValueListenableBuilder<_UserValue>(
        key: _listenerKey,
        valueListenable: _authNotifier,
        builder: (_, userValue, child) {
          if (userValue.loading) {
            return const Center(
                child: Text(
              'loading...',
              textDirection: TextDirection.ltr,
            ));
          }
          return child!;
        },
        child: MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
          debugShowCheckedModeBanner: false,
          title: 'Convention.Ninja',
          /*darkTheme: ThemeData.from(
                      colorScheme: ColorScheme.dark(),*/ /*fromSwatch(
                          primarySwatch: Colors.deepOrange,
                          brightness: Brightness.dark),*/ /*
                      useMaterial3: true),
                  themeMode: ThemeMode.dark,*/
        ));
  }
}
