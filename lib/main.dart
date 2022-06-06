import 'dart:async';

import 'package:convention_ninja/pages/landing_page.dart';
import 'package:convention_ninja/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'components/admin_scaffold.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

var _homeRoute = RouteParser.parseRoute('/');
var _loginRoute = RouteParser.parseRoute('/login');
var _dashboardRoute = RouteParser.parseRoute('/dashboard');
var _dashboardOrgNewRoute = RouteParser.parseRoute('/dashboard/new');
var _dashboardOrgRoute = RouteParser.parseRoute('/dashboard/:orgId');
var _inventoryRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory');
var _inventoryCatRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory/categories');
var _inventoryMfgRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory/manufacturers');
var _inventoryModelRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory/models');
var _inventoryAssetRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory/assets');
var _inventoryManifestRoute = RouteParser.parseRoute('/dashboard/:orgId/inventory/manifests');

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<User?> _sub;
  final _navigatorKey = GlobalKey<NavigatorState>();
  late String _organization;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _sub = FirebaseAuth.instance.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
      if(event == null || event.isAnonymous) {
        _navigatorKey.currentState!.pushReplacementNamed('/login');
        return;
      }
      String? currentPath;
      _navigatorKey.currentState?.popUntil((route) {
        currentPath = route.settings.name;
        return true;
      });
      if(currentPath == '/login') {
        _navigatorKey.currentState!.pushReplacementNamed('/dashboard');
        return;
      }
    });
    _organization = '';
  }

  void setOrganization(String organization) {
    setState(() {
      _organization = organization;
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Convention.Ninja',
      navigatorKey: _navigatorKey,
      darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepOrange, brightness: Brightness.dark),
          useMaterial3: true),
      themeMode: ThemeMode.dark,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/dashboard',
      onGenerateRoute: (settings) {
        var routeParams = <String>[];

        if (_homeRoute.getMatch(
            settings.name ?? '', settings.name ?? '', routeParams, false)) {
          return MaterialPageRoute(
              builder: (context) {
                return AdminScaffold(
                    organizationUpdater: setOrganization,
                    organization: _organization,
                    child: const Text('test child'));
              },
              settings: const RouteSettings(name: '/login'));
        } else if (_loginRoute.getMatch(
            settings.name ?? '', settings.name ?? '', routeParams, false)) {
          return MaterialPageRoute(
              builder: (context) {
                return const LandingPage();
              },
              settings: const RouteSettings(name: '/login'));
        } else if (_dashboardRoute.getMatch(
            settings.name ?? '', settings.name ?? '', routeParams, false)) {
          return MaterialPageRoute(
              builder: (context) {
                return AdminScaffold(
                    organizationUpdater: setOrganization,
                    organization: _organization,
                    child: const Text('test child'));
              },
              settings: const RouteSettings(name: '/dashboard'));
        } else if (_dashboardOrgNewRoute.getMatch(
            settings.name ?? '', settings.name ?? '', routeParams, false)) {
          return MaterialPageRoute(
              builder: (context) {
                return SomethingElse(title: settings.name ?? '');
              },
              settings: const RouteSettings(name: '/dashboard/new'));
        } else if (_dashboardOrgRoute.getMatch(
            settings.name ?? '', settings.name ?? '', routeParams, false)) {
          _organization = Uri.decodeFull(routeParams[0]);
          return MaterialPageRoute(
              builder: (context) {
                return AdminScaffold(
                    organizationUpdater: setOrganization,
                    organization: _organization,
                    child: const Text('test child'));
              },
              settings: RouteSettings(name: '/dashboard/${routeParams[0]}'));
        } else {
          return MaterialPageRoute(
              builder: (context) {
                return AdminScaffold(
                    organizationUpdater: setOrganization,
                    organization: _organization,
                    child: Text(settings.name ?? ''));
              },
              settings: RouteSettings(name: settings.name));
        }
      },
    );
  }
}



class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;

  const StatefulWrapper({Key? key, required this.onInit, required this.child}) : super(key: key);

  @override
  StatefulWrapperState createState() => StatefulWrapperState();
}

class StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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

class SomethingElse extends StatelessWidget {
  final String title;

  const SomethingElse({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
          child: Text(title),
          onTap: () {
            FirebaseAuth.instance.signOut();
          }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
          child: Text(widget.title),
          onTap: () {
            FirebaseAuth.instance.signOut();
          }),
    );
  }
}
